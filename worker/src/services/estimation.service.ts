/**
 * estimation.service.ts
 *
 * Fallback nutrition for foods not in the local DB.
 *
 * Chain:
 *   1. USDA FoodData Central — food/748967-style detailed endpoint, pulls
 *      only the ~10 nutrient IDs we care about from foodNutrients[].
 *   2. Cloudflare Workers AI (Llama 3.1 8B) — tight prompt, returns a
 *      single line of comma-separated numbers. No stories, no JSON essays.
 *   3. Zero + needsManualSelection if both fail.
 *
 * Portions are sanity-checked via portion-sanity.ts.
 */

import type { Bindings, NutritionValues } from "../types";
import { sanitiseGrams, isAmbiguousPortion } from "../utils/portion-sanity";

// ---------------------------------------------------------------------------
// Public types & entry point
// ---------------------------------------------------------------------------

export type EstimatedNutrition = NutritionValues & {
  estimatedGrams: number;
  confidence: number;
  source: "usda" | "llm" | "none";
  isAmbiguous: boolean;
};

export async function estimateNutrition(
  env: Bindings,
  canonicalName: string,
  unit: string | null,
  quantity: number,
  inputGrams: number | null,
): Promise<EstimatedNutrition> {
  const key = `est2:${canonicalName.toLowerCase().replace(/\s+/g, "_")}`;
  const cached = await env.FOOD_PARSE_CACHE.get(key, "json").catch(() => null);
  if (cached && isPer100g(cached)) {
    return toEstimate(cached, canonicalName, unit, quantity, inputGrams);
  }

  const usda = await usdaLookup(env, canonicalName);
  if (usda) {
    await env.FOOD_PARSE_CACHE.put(key, JSON.stringify(usda), { expirationTtl: 60 * 60 * 24 * 90 });
    return toEstimate(usda, canonicalName, unit, quantity, inputGrams);
  }

  const llm = await llmEstimate(env, canonicalName);
  if (llm) {
    await env.FOOD_PARSE_CACHE.put(key, JSON.stringify(llm), { expirationTtl: 60 * 60 * 24 * 30 });
    return toEstimate(llm, canonicalName, unit, quantity, inputGrams);
  }

  const { grams } = sanitiseGrams(canonicalName, unit, quantity, inputGrams);
  return { ...zero(), estimatedGrams: grams, confidence: 0, source: "none", isAmbiguous: true };
}

// ---------------------------------------------------------------------------
// Per-100g cache shape
// ---------------------------------------------------------------------------

type Per100g = {
  cal: number; pro: number; carb: number; fat: number;
  fib: number; sug: number; sod: number; cal_mg: number;
  iron: number; pot: number;
  confidence: number; source: "usda" | "llm";
};

function isPer100g(v: unknown): v is Per100g {
  return Boolean(v && typeof v === "object" && "cal" in (v as object) && "source" in (v as object));
}

// ---------------------------------------------------------------------------
// 1. USDA FoodData Central
//    Uses /foods/search to find the best match, then reads foodNutrients[].
//    Pulls only the nutrient IDs we care about — ignores everything else.
//    Requires env.USDA_API_KEY binding (free key from fdc.nal.usda.gov).
// ---------------------------------------------------------------------------

/** USDA nutrient IDs → our short keys */
const NID: Record<number, keyof Omit<Per100g, "confidence" | "source">> = {
  1008: "cal",   // Energy kcal
  1003: "pro",   // Protein
  1005: "carb",  // Carbohydrate
  1004: "fat",   // Total fat
  1079: "fib",   // Fiber
  2000: "sug",   // Sugars
  1093: "sod",   // Sodium mg
  1087: "cal_mg",// Calcium mg
  1089: "iron",  // Iron mg
  1092: "pot",   // Potassium mg
};

async function usdaLookup(env: Bindings, query: string): Promise<Per100g | null> {
  const apiKey = (env as unknown as Record<string, string>).USDA_API_KEY;
  if (!apiKey) return null;

  try {
    // Search: get top 5 results, Foundation + SR Legacy only (most complete)
    const searchUrl =
      `https://api.nal.usda.gov/fdc/v1/foods/search` +
      `?api_key=${apiKey}` +
      `&query=${encodeURIComponent(query)}` +
      `&dataType=Foundation,SR%20Legacy` +
      `&pageSize=5`;

    const sr = await fetch(searchUrl, { signal: AbortSignal.timeout(4500) });
    if (!sr.ok) return null;

    const sdata = (await sr.json()) as { foods?: Array<{ fdcId: number; description: string }> };
    const foods = sdata.foods ?? [];
    if (foods.length === 0) return null;

    // Pick the best name match; fall back to rank-1
    const norm = query.toLowerCase();
    const best =
      foods.find((f) => f.description.toLowerCase() === norm) ??
      foods.find((f) => f.description.toLowerCase().startsWith(norm)) ??
      foods[0];
    if (!best) return null;

    // Detail: fetch only the nutrients we need via the abridged format
    const detailUrl =
      `https://api.nal.usda.gov/fdc/v1/food/${best.fdcId}` +
      `?api_key=${apiKey}&format=abridged`;

    const dr = await fetch(detailUrl, { signal: AbortSignal.timeout(4500) });
    if (!dr.ok) return null;

    const ddata = (await dr.json()) as {
      foodNutrients?: Array<{ nutrientId?: number; id?: number; amount?: number; value?: number }>;
    };

    const result: Partial<Per100g> = { confidence: 0.85, source: "usda" };
    for (const n of ddata.foodNutrients ?? []) {
      const nid = n.nutrientId ?? n.id;
      const val = n.amount ?? n.value ?? 0;
      if (nid && NID[nid]) (result as Record<string, unknown>)[NID[nid]] = val;
    }

    if (!result.cal || result.cal <= 0) return null;

    return {
      cal: result.cal ?? 0, pro: result.pro ?? 0, carb: result.carb ?? 0,
      fat: result.fat ?? 0, fib: result.fib ?? 0, sug: result.sug ?? 0,
      sod: result.sod ?? 0, cal_mg: result.cal_mg ?? 0,
      iron: result.iron ?? 0, pot: result.pot ?? 0,
      confidence: 0.85, source: "usda",
    };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// 2. Llama 3.1 8B — tight CSV prompt, no JSON walls
//    Prompt asks for exactly 10 numbers in one line. We parse that line.
//    Example response: "165,31,0,3.6,0,0,74,11,1.0,256"
// ---------------------------------------------------------------------------

async function llmEstimate(env: Bindings, foodName: string): Promise<Per100g | null> {
  try {
    const result = await (env.AI as AiRun).run("@cf/meta/llama-3.1-8b-instruct", {
      messages: [
        {
          role: "system",
          content: "Nutrition expert. Reply with ONLY 10 comma-separated numbers. No text, no units, no explanation.",
        },
        {
          role: "user",
          content:
            `Per 100g of "${foodName}" (South Asian/Nepali context if applicable), give:\n` +
            `kcal, protein_g, carbs_g, fat_g, fiber_g, sugar_g, sodium_mg, calcium_mg, iron_mg, potassium_mg`,
        },
      ],
    });

    const text = extractText(result)?.trim() ?? "";
    // Accept either a plain CSV line or a JSON array like [165,31,0,...]
    const line = text.replace(/[\[\]]/g, "").split("\n")[0].trim();
    const nums = line.split(",").map((s) => Number(s.trim()));

    if (nums.length < 4 || nums.some(isNaN) || (nums[0] ?? 0) <= 0 || (nums[0] ?? 0) > 900) {
      return null;
    }

    return {
      cal:    clamp(nums[0] ?? 0, 0, 900),
      pro:    clamp(nums[1] ?? 0, 0, 100),
      carb:   clamp(nums[2] ?? 0, 0, 100),
      fat:    clamp(nums[3] ?? 0, 0, 100),
      fib:    clamp(nums[4] ?? 0, 0, 50),
      sug:    clamp(nums[5] ?? 0, 0, 100),
      sod:    clamp(nums[6] ?? 0, 0, 5000),
      cal_mg: clamp(nums[7] ?? 0, 0, 1500),
      iron:   clamp(nums[8] ?? 0, 0, 50),
      pot:    clamp(nums[9] ?? 0, 0, 5000),
      confidence: 0.55,
      source: "llm",
    };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Apply grams → actual nutrition values
// ---------------------------------------------------------------------------

function toEstimate(
  p: Per100g,
  canonicalName: string,
  unit: string | null,
  quantity: number,
  inputGrams: number | null,
): EstimatedNutrition {
  const { grams, isAmbiguous } = sanitiseGrams(canonicalName, unit, quantity, inputGrams);
  const f = grams / 100;
  return {
    calories:   Math.round(p.cal  * f),
    proteinG:   r1(p.pro  * f),
    carbsG:     r1(p.carb * f),
    fatG:       r1(p.fat  * f),
    fiberG:     r1(p.fib  * f),
    sugarG:     r1(p.sug  * f),
    sodiumMg:   Math.round(p.sod    * f),
    calciumMg:  Math.round(p.cal_mg * f),
    ironMg:     r1(p.iron * f),
    potassiumMg: Math.round(p.pot   * f),
    estimatedGrams: grams,
    confidence: p.confidence,
    source: p.source,
    isAmbiguous: isAmbiguous || isAmbiguousPortion(unit, canonicalName),
  };
}

// ---------------------------------------------------------------------------
// Tiny helpers
// ---------------------------------------------------------------------------

function zero(): NutritionValues {
  return { calories:0, proteinG:0, carbsG:0, fatG:0, fiberG:0,
           sugarG:0, sodiumMg:0, calciumMg:0, ironMg:0, potassiumMg:0 };
}
function clamp(v: number, mn: number, mx: number) { return Math.min(Math.max(v, mn), mx); }
function r1(v: number) { return Math.round(v * 10) / 10; }
function extractText(r: unknown): string | null {
  if (typeof r === "string") return r;
  if (r && typeof r === "object") {
    const o = r as Record<string, unknown>;
    if (typeof o.response === "string") return o.response;
  }
  return null;
}

interface AiRun {
  run(model: string, opts: { messages: { role: string; content: string }[] }): Promise<unknown>;
}
