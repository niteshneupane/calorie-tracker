import type { Bindings, DailySummary, MealLogResponse, SaveMealRequest } from "../types";
import { nowIso } from "../utils/date";
import { createId } from "../utils/id";
import { zeroDailySummary } from "./nutrition.service";

type SummaryRow = {
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

type MealRow = {
  id: string;
  date: string;
  meal_type: string;
  notes: string | null;
};

type MealItemRow = {
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

export async function saveMeal(env: Bindings, userId: string, request: SaveMealRequest): Promise<{ mealId: string; saved: true; dailySummary: DailySummary }> {
  await ensureUser(env, userId);

  const timestamp = nowIso();
  const mealId = createId("meal");
  await env.DB.prepare("INSERT INTO meal_logs (id, user_id, date, meal_type, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)")
    .bind(mealId, userId, request.date, request.mealType, request.notes ?? null, timestamp, timestamp)
    .run();

  for (const item of request.items) {
    await env.DB.prepare(
      `INSERT INTO meal_items (
        id, meal_log_id, food_id, food_name, quantity, unit, grams, calories, protein_g, carbs_g, fat_g,
        fiber_g, sugar_g, sodium_mg, calcium_mg, iron_mg, potassium_mg, vitamin_a_mcg, vitamin_c_mg,
        vitamin_b12_mcg, is_estimate, confidence
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
      .bind(
        createId("meal_item"),
        mealId,
        item.foodId ?? null,
        item.foodName,
        item.quantity ?? null,
        item.unit ?? null,
        item.grams,
        item.calories,
        item.proteinG,
        item.carbsG,
        item.fatG,
        item.fiberG,
        item.sugarG,
        item.sodiumMg,
        item.calciumMg,
        item.ironMg,
        item.potassiumMg,
        item.vitaminAMcg ?? null,
        item.vitaminCMg ?? null,
        item.vitaminB12Mcg ?? null,
        item.isEstimate === false ? 0 : 1,
        item.confidence ?? null,
      )
      .run();
  }

  const dailySummary = await recalculateDailySummary(env, userId, request.date);
  return { mealId, saved: true, dailySummary };
}

export async function getMealsByDate(env: Bindings, userId: string, date: string): Promise<MealLogResponse[]> {
  const meals = await env.DB.prepare("SELECT id, date, meal_type, notes FROM meal_logs WHERE user_id = ? AND date = ? ORDER BY created_at ASC")
    .bind(userId, date)
    .all<MealRow>();

  const responses: MealLogResponse[] = [];
  for (const meal of meals.results ?? []) {
    const items = await env.DB.prepare("SELECT * FROM meal_items WHERE meal_log_id = ? ORDER BY id ASC").bind(meal.id).all<MealItemRow>();
    responses.push({
      id: meal.id,
      date: meal.date,
      mealType: meal.meal_type,
      notes: meal.notes,
      items: (items.results ?? []).map(mapMealItemRow),
    });
  }
  return responses;
}

export async function deleteMeal(env: Bindings, userId: string, mealId: string, date: string): Promise<DailySummary | null> {
  const meal = await env.DB.prepare("SELECT id FROM meal_logs WHERE id = ? AND user_id = ? AND date = ? LIMIT 1").bind(mealId, userId, date).first<{ id: string }>();
  if (!meal) return null;

  await env.DB.prepare("DELETE FROM meal_items WHERE meal_log_id = ?").bind(mealId).run();
  await env.DB.prepare("DELETE FROM meal_logs WHERE id = ? AND user_id = ?").bind(mealId, userId).run();
  return recalculateDailySummary(env, userId, date);
}

export async function recalculateDailySummary(env: Bindings, userId: string, date: string): Promise<DailySummary> {
  const row = await env.DB.prepare(
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
    .first<SummaryRow>();

  const summary = row ? mapSummaryRow(row) : zeroDailySummary(date);
  await upsertDailySummary(env, userId, summary);
  return summary;
}

async function ensureUser(env: Bindings, userId: string): Promise<void> {
  const timestamp = nowIso();
  await env.DB.prepare(
    `INSERT INTO users (id, auth_provider, auth_uid, created_at, updated_at)
     VALUES (?, 'supabase', ?, ?, ?)
     ON CONFLICT(id) DO NOTHING`,
  )
    .bind(userId, userId, timestamp, timestamp)
    .run();
}

async function upsertDailySummary(env: Bindings, userId: string, summary: DailySummary): Promise<void> {
  await env.DB.prepare(
    `INSERT INTO daily_summaries (
      id, user_id, date, calories, protein_g, carbs_g, fat_g, fiber_g, sugar_g, sodium_mg, calcium_mg,
      iron_mg, potassium_mg, vitamin_a_mcg, vitamin_c_mg, vitamin_b12_mcg, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(user_id, date) DO UPDATE SET
      calories = excluded.calories,
      protein_g = excluded.protein_g,
      carbs_g = excluded.carbs_g,
      fat_g = excluded.fat_g,
      fiber_g = excluded.fiber_g,
      sugar_g = excluded.sugar_g,
      sodium_mg = excluded.sodium_mg,
      calcium_mg = excluded.calcium_mg,
      iron_mg = excluded.iron_mg,
      potassium_mg = excluded.potassium_mg,
      vitamin_a_mcg = excluded.vitamin_a_mcg,
      vitamin_c_mg = excluded.vitamin_c_mg,
      vitamin_b12_mcg = excluded.vitamin_b12_mcg,
      updated_at = excluded.updated_at`,
  )
    .bind(
      createId("summary"),
      userId,
      summary.date,
      summary.calories,
      summary.proteinG,
      summary.carbsG,
      summary.fatG,
      summary.fiberG,
      summary.sugarG,
      summary.sodiumMg,
      summary.calciumMg,
      summary.ironMg,
      summary.potassiumMg,
      summary.vitaminAMcg ?? 0,
      summary.vitaminCMg ?? 0,
      summary.vitaminB12Mcg ?? 0,
      nowIso(),
    )
    .run();
}

function mapSummaryRow(row: SummaryRow): DailySummary {
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

function mapMealItemRow(row: MealItemRow): MealLogResponse["items"][number] {
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
