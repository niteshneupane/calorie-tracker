import type { Bindings, ParseFoodResponse } from "../types";

export async function parseFoodText(env: Bindings, text: string, locale = "en-US"): Promise<ParseFoodResponse> {
  const cacheKey = normalizeCacheKey(text, locale);
  const cached = await env.FOOD_PARSE_CACHE.get(cacheKey, "json");
  if (cached && isParseFoodResponse(cached)) return cached;

  const aiResult = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
    messages: [
      {
        role: "system",
        content: "You parse food text into strict JSON for a nutrition app.",
      },
      {
        role: "user",
        content: buildFoodParserPrompt(text, locale),
      },
    ],
  });

  const parsed = safeJsonParseAiResponse(aiResult);
  if (!isParseFoodResponse(parsed)) throw new Error("AI response did not include a valid items array");

  await env.FOOD_PARSE_CACHE.put(cacheKey, JSON.stringify(parsed), { expirationTtl: 60 * 60 * 24 * 30 });
  return parsed;
}

export function buildFoodParserPrompt(text: string, locale = "en-US"): string {
  return [
    "Return only valid JSON. Do not include markdown. Do not explain.",
    "Do not calculate nutrition. Do not invent calories, macros, micronutrients, or minerals.",
    "Normalize common misspellings. Use South Asian and Nepali food context.",
    "Estimate grams only for vague portions like plate, bowl, cup, piece, serving, thali.",
    "Include confidence between 0 and 1. Include possible variants when ambiguous.",
    `Locale: ${locale}`,
    `Input: ${text}`,
    "JSON shape:",
    '{"items":[{"rawText":"string","canonicalName":"string","quantity":1,"unit":"string","estimatedGrams":350,"estimatedMl":null,"confidence":0.7,"possibleVariants":["string"]}]}',
  ].join("\n");
}

export function safeJsonParseAiResponse(response: unknown): unknown {
  const candidate = extractResponseText(response);
  if (typeof candidate !== "string") return candidate;
  const withoutFences = candidate.replace(/```(?:json)?/gi, "```").replace(/```/g, "").trim();

  try {
    return JSON.parse(withoutFences);
  } catch {
    const extracted = extractFirstJsonObject(withoutFences);
    if (!extracted) throw new Error("Unable to parse AI JSON response");
    return JSON.parse(extracted);
  }
}

export function normalizeCacheKey(text: string, locale = "en-US"): string {
  const normalized = text.trim().toLowerCase().replace(/\s+/g, " ");
  return `food-parse:${locale.toLowerCase()}:${normalized}`;
}

function extractResponseText(response: unknown): unknown {
  if (typeof response === "string") return response;
  if (!response || typeof response !== "object") return response;
  const object = response as Record<string, unknown>;
  if (typeof object.response === "string") return object.response;
  if (object.response && typeof object.response === "object") return object.response;
  return response;
}

function extractFirstJsonObject(text: string): string | null {
  const start = text.indexOf("{");
  if (start === -1) return null;

  let depth = 0;
  let inString = false;
  let escaped = false;
  for (let index = start; index < text.length; index += 1) {
    const char = text[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === '"') {
        inString = false;
      }
      continue;
    }
    if (char === '"') inString = true;
    if (char === "{") depth += 1;
    if (char === "}") depth -= 1;
    if (depth === 0) return text.slice(start, index + 1);
  }
  return null;
}

function isParseFoodResponse(value: unknown): value is ParseFoodResponse {
  return Boolean(value && typeof value === "object" && Array.isArray((value as ParseFoodResponse).items));
}
