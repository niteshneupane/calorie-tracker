import { Hono } from "hono";
import type { Context } from "hono";
import type { AppEnv, NutritionPreviewItem } from "../types";
import { parseFoodText } from "../services/ai.service";
import { findFoodByNameOrAlias, listFoods, searchFoods } from "../services/food.service";
import { calculateNutrition, sumNutrition, zeroNutritionValues } from "../services/nutrition.service";
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
    const food = await findFoodByNameOrAlias(c.env, item.canonicalName);
    if (!food) {
      items.push({
        ...zeroNutritionValues(),
        foodId: null,
        name: null,
        inputName: item.canonicalName,
        grams: item.grams ?? null,
        confidence: 0,
        isEstimate: true,
        needsManualSelection: true,
      });
      continue;
    }

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
