import { Hono } from "hono";
import type { Context } from "hono";
import type { AppEnv, NutritionPreviewItem } from "../types";
import { parseFoodText } from "../services/ai.service";
import { findFoodByNameOrAlias, listFoods, searchFoods } from "../services/food.service";
import { estimateNutrition } from "../services/estimation.service";
import { calculateNutrition, sumNutrition } from "../services/nutrition.service";
import { isAmbiguousPortion } from "../utils/portion-sanity";
import { fail, ok } from "../utils/response";
import { isNonEmptyString, validateParseFoodRequest, validatePreviewFoodRequest } from "../utils/validators";

export const foodRoutes = new Hono<AppEnv>();

foodRoutes.post("/parse", async (c) => {
  const validation = validateParseFoodRequest(await c.req.json().catch(() => null));
  if (!validation.ok) return fail(c, 400, "BAD_REQUEST", validation.message);

  const result = await parseFoodText(c.env, validation.value.text, validation.value.locale ?? "en-US");
  return ok(c, result);
});

foodRoutes.post("/preview", async (c) => {
  const validation = validatePreviewFoodRequest(await c.req.json().catch(() => null));
  if (!validation.ok) return fail(c, 400, "BAD_REQUEST", validation.message);

  const items: NutritionPreviewItem[] = [];

  for (const item of validation.value.items) {
    // 1. Try local DB first (fastest, most accurate for Nepali foods)
    const food = await findFoodByNameOrAlias(c.env, item.canonicalName);

    if (food) {
      const grams = item.grams ?? food.default_serving_grams ?? 100;
      const nutrition = calculateNutrition(food, grams);
      items.push({
        ...nutrition,
        foodId: food.id,
        name: food.name,
        inputName: item.canonicalName,
        grams,
        confidence: food.confidence ?? 0.8,
        isEstimate: food.source === "seed_estimate",
        needsManualSelection: false,
      });
      continue;
    }

    // 2. Not in local DB — estimate via USDA → Llama fallback chain
    const estimated = await estimateNutrition(
      c.env,
      item.canonicalName,
      item.unit ?? null,
      item.quantity ?? 1,
      item.grams ?? null,
    );

    const ambiguous = estimated.source === "none" ||
      isAmbiguousPortion(item.unit ?? null, item.canonicalName);

    items.push({
      calories: estimated.calories,
      proteinG: estimated.proteinG,
      carbsG: estimated.carbsG,
      fatG: estimated.fatG,
      fiberG: estimated.fiberG,
      sugarG: estimated.sugarG,
      sodiumMg: estimated.sodiumMg,
      calciumMg: estimated.calciumMg,
      ironMg: estimated.ironMg,
      potassiumMg: estimated.potassiumMg,
      foodId: null,
      name: item.canonicalName,
      inputName: item.canonicalName,
      grams: estimated.estimatedGrams,
      confidence: estimated.confidence,
      isEstimate: true,
      needsManualSelection: ambiguous,
    });
  }

  return ok(c, {
    items,
    total: sumNutrition(items),
  });
});

foodRoutes.get("/search", foodSearchHandler);

export async function foodSearchHandler(c: Context<AppEnv>): Promise<Response> {
  const query = c.req.query("q");
  const items = isNonEmptyString(query) ? await searchFoods(c.env, query) : await listFoods(c.env);
  return ok(c, { items });
}
