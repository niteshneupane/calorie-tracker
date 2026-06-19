import type { Bindings } from "../types";

export type MealRow = {
  id: string;
  date: string;
  meal_type: string;
  notes: string | null;
};

export type MealItemRow = {
  id: string;
  meal_log_id: string;
  food_id: string | null;
  food_name: string;
  quantity: number | null;
  unit: string | null;
  grams: number;
  calories: number;
  protein_g: number;
  carbs_g: number;
  fat_g: number;
  fiber_g: number;
  sugar_g: number;
  sodium_mg: number;
  calcium_mg: number;
  iron_mg: number;
  potassium_mg: number;
  vitamin_a_mcg: number | null;
  vitamin_c_mg: number | null;
  vitamin_b12_mcg: number | null;
  is_estimate: number | null;
  confidence: number | null;
};

export type SummaryAggRow = {
  date: string;
  calories: number | null;
  protein_g: number | null;
  carbs_g: number | null;
  fat_g: number | null;
  fiber_g: number | null;
  sugar_g: number | null;
  sodium_mg: number | null;
  calcium_mg: number | null;
  iron_mg: number | null;
  potassium_mg: number | null;
  vitamin_a_mcg: number | null;
  vitamin_c_mg: number | null;
  vitamin_b12_mcg: number | null;
};

export async function insertLog(
  env: Bindings,
  params: { id: string; userId: string; date: string; mealType: string; notes: string | null; createdAt: string; updatedAt: string },
): Promise<void> {
  await env.DB.prepare("INSERT INTO meal_logs (id, user_id, date, meal_type, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)")
    .bind(params.id, params.userId, params.date, params.mealType, params.notes, params.createdAt, params.updatedAt)
    .run();
}

export async function insertItem(
  env: Bindings,
  params: {
    id: string;
    mealLogId: string;
    foodId: string | null;
    foodName: string;
    quantity: number | null;
    unit: string | null;
    grams: number;
    calories: number;
    proteinG: number;
    carbsG: number;
    fatG: number;
    fiberG: number;
    sugarG: number;
    sodiumMg: number;
    calciumMg: number;
    ironMg: number;
    potassiumMg: number;
    vitaminAMcg: number | null;
    vitaminCMg: number | null;
    vitaminB12Mcg: number | null;
    isEstimate: number;
    confidence: number | null;
  },
): Promise<void> {
  await env.DB.prepare(
    `INSERT INTO meal_items (
      id, meal_log_id, food_id, food_name, quantity, unit, grams, calories, protein_g, carbs_g, fat_g,
      fiber_g, sugar_g, sodium_mg, calcium_mg, iron_mg, potassium_mg, vitamin_a_mcg, vitamin_c_mg,
      vitamin_b12_mcg, is_estimate, confidence
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
  )
    .bind(
      params.id,
      params.mealLogId,
      params.foodId,
      params.foodName,
      params.quantity,
      params.unit,
      params.grams,
      params.calories,
      params.proteinG,
      params.carbsG,
      params.fatG,
      params.fiberG,
      params.sugarG,
      params.sodiumMg,
      params.calciumMg,
      params.ironMg,
      params.potassiumMg,
      params.vitaminAMcg,
      params.vitaminCMg,
      params.vitaminB12Mcg,
      params.isEstimate,
      params.confidence,
    )
    .run();
}

export async function findByUserIdAndDate(env: Bindings, userId: string, date: string): Promise<MealRow[]> {
  const result = await env.DB.prepare("SELECT id, date, meal_type, notes FROM meal_logs WHERE user_id = ? AND date = ? ORDER BY created_at ASC")
    .bind(userId, date)
    .all<MealRow>();
  return result.results ?? [];
}

export async function findItemsByMealLogId(env: Bindings, mealLogId: string): Promise<MealItemRow[]> {
  const result = await env.DB.prepare("SELECT * FROM meal_items WHERE meal_log_id = ? ORDER BY id ASC")
    .bind(mealLogId)
    .all<MealItemRow>();
  return result.results ?? [];
}

export async function findLogById(env: Bindings, mealId: string, userId: string, date: string): Promise<{ id: string } | null> {
  return env.DB.prepare("SELECT id FROM meal_logs WHERE id = ? AND user_id = ? AND date = ? LIMIT 1")
    .bind(mealId, userId, date)
    .first<{ id: string }>();
}

export async function deleteItemsByMealLogId(env: Bindings, mealLogId: string): Promise<void> {
  await env.DB.prepare("DELETE FROM meal_items WHERE meal_log_id = ?").bind(mealLogId).run();
}

export async function deleteLog(env: Bindings, mealId: string, userId: string): Promise<void> {
  await env.DB.prepare("DELETE FROM meal_logs WHERE id = ? AND user_id = ?").bind(mealId, userId).run();
}

export async function aggregateByUserIdAndDate(env: Bindings, userId: string, date: string): Promise<SummaryAggRow | null> {
  return env.DB.prepare(
    `SELECT
      ? AS date,
      COALESCE(SUM(mi.calories), 0) AS calories,
      COALESCE(SUM(mi.protein_g), 0) AS protein_g,
      COALESCE(SUM(mi.carbs_g), 0) AS carbs_g,
      COALESCE(SUM(mi.fat_g), 0) AS fat_g,
      COALESCE(SUM(mi.fiber_g), 0) AS fiber_g,
      COALESCE(SUM(mi.sugar_g), 0) AS sugar_g,
      COALESCE(SUM(mi.sodium_mg), 0) AS sodium_mg,
      COALESCE(SUM(mi.calcium_mg), 0) AS calcium_mg,
      COALESCE(SUM(mi.iron_mg), 0) AS iron_mg,
      COALESCE(SUM(mi.potassium_mg), 0) AS potassium_mg,
      COALESCE(SUM(mi.vitamin_a_mcg), 0) AS vitamin_a_mcg,
      COALESCE(SUM(mi.vitamin_c_mg), 0) AS vitamin_c_mg,
      COALESCE(SUM(mi.vitamin_b12_mcg), 0) AS vitamin_b12_mcg
    FROM meal_logs ml
    JOIN meal_items mi ON mi.meal_log_id = ml.id
    WHERE ml.user_id = ? AND ml.date = ?`,
  )
    .bind(date, userId, date)
    .first<SummaryAggRow>();
}
