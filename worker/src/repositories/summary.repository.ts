import type { Bindings } from "../types";

export type DailySummaryRow = {
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

export type HistoryRow = {
  date: string;
  calories: number | null;
  protein_g: number | null;
  meal_count: number | null;
};

export async function findByUserIdAndDate(env: Bindings, userId: string, date: string): Promise<DailySummaryRow | null> {
  return env.DB.prepare("SELECT * FROM daily_summaries WHERE user_id = ? AND date = ? LIMIT 1")
    .bind(userId, date)
    .first<DailySummaryRow>();
}

export async function upsert(
  env: Bindings,
  params: {
    id: string;
    userId: string;
    date: string;
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
    vitaminAMcg: number;
    vitaminCMg: number;
    vitaminB12Mcg: number;
    updatedAt: string;
  },
): Promise<void> {
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
      params.id,
      params.userId,
      params.date,
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
      params.updatedAt,
    )
    .run();
}

export async function getHistory(env: Bindings, userId: string, from: string, to: string): Promise<HistoryRow[]> {
  const result = await env.DB.prepare(
    `SELECT
      ds.date,
      COALESCE(ds.calories, 0) AS calories,
      COALESCE(ds.protein_g, 0) AS protein_g,
      COALESCE(COUNT(ml.id), 0) AS meal_count
    FROM daily_summaries ds
    LEFT JOIN meal_logs ml ON ml.user_id = ds.user_id AND ml.date = ds.date
    WHERE ds.user_id = ? AND ds.date >= ? AND ds.date <= ?
    GROUP BY ds.date, ds.calories, ds.protein_g
    ORDER BY ds.date DESC`,
  )
    .bind(userId, from, to)
    .all<HistoryRow>();
  return result.results ?? [];
}
