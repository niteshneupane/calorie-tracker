import type { Bindings, DailySummary, NutritionValues } from "../types";
import { zeroDailySummary } from "./nutrition.service";

type DailySummaryRow = {
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

type GoalRow = {
  daily_calorie_goal: number | null;
  protein_goal_g: number | null;
  carbs_goal_g: number | null;
  fat_goal_g: number | null;
};

export async function getDailySummary(env: Bindings, userId: string, date: string): Promise<{
  date: string;
  goal: { calories: number; proteinG: number; carbsG: number; fatG: number } | null;
  consumed: DailySummary;
  remaining: { calories: number; proteinG: number; carbsG: number; fatG: number } | null;
}> {
  const summaryRow = await env.DB.prepare("SELECT * FROM daily_summaries WHERE user_id = ? AND date = ? LIMIT 1").bind(userId, date).first<DailySummaryRow>();
  const consumed = summaryRow ? mapSummaryRow(summaryRow) : zeroDailySummary(date);

  const profile = await env.DB.prepare("SELECT daily_calorie_goal, protein_goal_g, carbs_goal_g, fat_goal_g FROM users WHERE id = ? LIMIT 1")
    .bind(userId)
    .first<GoalRow>();

  const goal = profile && profile.daily_calorie_goal !== null
    ? {
        calories: profile.daily_calorie_goal,
        proteinG: profile.protein_goal_g ?? 0,
        carbsG: profile.carbs_goal_g ?? 0,
        fatG: profile.fat_goal_g ?? 0,
      }
    : null;

  const remaining = goal
    ? {
        calories: goal.calories - consumed.calories,
        proteinG: goal.proteinG - consumed.proteinG,
        carbsG: goal.carbsG - consumed.carbsG,
        fatG: goal.fatG - consumed.fatG,
      }
    : null;

  return { date, goal, consumed, remaining };
}

function mapSummaryRow(row: DailySummaryRow): DailySummary {
  const values: NutritionValues = {
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
  return { date: row.date, ...values };
}
