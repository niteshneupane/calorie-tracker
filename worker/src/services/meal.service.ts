import type { Bindings, DailySummary, MealLogResponse, SaveMealRequest } from "../types";
import { nowIso } from "../utils/date";
import { createId } from "../utils/id";
import { zeroDailySummary } from "./nutrition.service";
import * as mealRepo from "../repositories/meal.repository";
import * as userRepo from "../repositories/user.repository";
import * as summaryRepo from "../repositories/summary.repository";

export async function saveMeal(env: Bindings, userId: string, request: SaveMealRequest): Promise<{ mealId: string; saved: true; dailySummary: DailySummary }> {
  await userRepo.ensureExists(env, userId, nowIso());

  const timestamp = nowIso();
  const mealId = createId("meal");
  await mealRepo.insertLog(env, { id: mealId, userId, date: request.date, mealType: request.mealType, notes: request.notes ?? null, createdAt: timestamp, updatedAt: timestamp });

  for (const item of request.items) {
    await mealRepo.insertItem(env, {
      id: createId("meal_item"),
      mealLogId: mealId,
      foodId: item.foodId ?? null,
      foodName: item.foodName,
      quantity: item.quantity ?? null,
      unit: item.unit ?? null,
      grams: item.grams,
      calories: item.calories,
      proteinG: item.proteinG,
      carbsG: item.carbsG,
      fatG: item.fatG,
      fiberG: item.fiberG,
      sugarG: item.sugarG,
      sodiumMg: item.sodiumMg,
      calciumMg: item.calciumMg,
      ironMg: item.ironMg,
      potassiumMg: item.potassiumMg,
      vitaminAMcg: item.vitaminAMcg ?? null,
      vitaminCMg: item.vitaminCMg ?? null,
      vitaminB12Mcg: item.vitaminB12Mcg ?? null,
      isEstimate: item.isEstimate === false ? 0 : 1,
      confidence: item.confidence ?? null,
    });
  }

  const dailySummary = await recalculateDailySummary(env, userId, request.date);
  return { mealId, saved: true, dailySummary };
}

export async function getMealsByDate(env: Bindings, userId: string, date: string): Promise<MealLogResponse[]> {
  const meals = await mealRepo.findByUserIdAndDate(env, userId, date);

  const responses: MealLogResponse[] = [];
  for (const meal of meals) {
    const items = await mealRepo.findItemsByMealLogId(env, meal.id);
    responses.push({
      id: meal.id,
      date: meal.date,
      mealType: meal.meal_type,
      notes: meal.notes,
      items: items.map(mapMealItemRow),
    });
  }
  return responses;
}

export async function deleteMeal(env: Bindings, userId: string, mealId: string, date: string): Promise<DailySummary | null> {
  const meal = await mealRepo.findLogById(env, mealId, userId, date);
  if (!meal) return null;

  await mealRepo.deleteItemsByMealLogId(env, mealId);
  await mealRepo.deleteLog(env, mealId, userId);
  return recalculateDailySummary(env, userId, date);
}

export async function recalculateDailySummary(env: Bindings, userId: string, date: string): Promise<DailySummary> {
  const row = await mealRepo.aggregateByUserIdAndDate(env, userId, date);
  const summary = row ? mapAggRow(row) : zeroDailySummary(date);
  await summaryRepo.upsert(env, {
    id: createId("summary"),
    userId,
    date: summary.date,
    calories: summary.calories,
    proteinG: summary.proteinG,
    carbsG: summary.carbsG,
    fatG: summary.fatG,
    fiberG: summary.fiberG,
    sugarG: summary.sugarG,
    sodiumMg: summary.sodiumMg,
    calciumMg: summary.calciumMg,
    ironMg: summary.ironMg,
    potassiumMg: summary.potassiumMg,
    vitaminAMcg: summary.vitaminAMcg ?? 0,
    vitaminCMg: summary.vitaminCMg ?? 0,
    vitaminB12Mcg: summary.vitaminB12Mcg ?? 0,
    updatedAt: nowIso(),
  });
  return summary;
}

function mapAggRow(row: mealRepo.SummaryAggRow): DailySummary {
  return {
    date: row.date,
    calories: Math.round(row.calories ?? 0),
    proteinG: Math.round(row.protein_g ?? 0),
    carbsG: Math.round(row.carbs_g ?? 0),
    fatG: Math.round(row.fat_g ?? 0),
    fiberG: Math.round(row.fiber_g ?? 0),
    sugarG: Math.round(row.sugar_g ?? 0),
    sodiumMg: Math.round(row.sodium_mg ?? 0),
    calciumMg: Math.round(row.calcium_mg ?? 0),
    ironMg: Math.round((row.iron_mg ?? 0) * 10) / 10,
    potassiumMg: Math.round(row.potassium_mg ?? 0),
    vitaminAMcg: Math.round((row.vitamin_a_mcg ?? 0) * 10) / 10,
    vitaminCMg: Math.round((row.vitamin_c_mg ?? 0) * 10) / 10,
    vitaminB12Mcg: Math.round((row.vitamin_b12_mcg ?? 0) * 10) / 10,
  };
}

function mapMealItemRow(row: mealRepo.MealItemRow): MealLogResponse["items"][number] {
  return {
    id: row.id,
    foodId: row.food_id,
    foodName: row.food_name,
    quantity: row.quantity,
    unit: row.unit,
    grams: row.grams,
    calories: row.calories,
    proteinG: row.protein_g,
    carbsG: row.carbs_g,
    fatG: row.fat_g,
    fiberG: row.fiber_g,
    sugarG: row.sugar_g,
    sodiumMg: row.sodium_mg,
    calciumMg: row.calcium_mg,
    ironMg: row.iron_mg,
    potassiumMg: row.potassium_mg,
    vitaminAMcg: row.vitamin_a_mcg ?? undefined,
    vitaminCMg: row.vitamin_c_mg ?? undefined,
    vitaminB12Mcg: row.vitamin_b12_mcg ?? undefined,
    isEstimate: row.is_estimate !== 0,
    confidence: row.confidence,
  };
}
