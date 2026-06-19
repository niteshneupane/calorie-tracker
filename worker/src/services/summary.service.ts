import type { Bindings, DailySummary, NutritionValues } from "../types";
import { zeroDailySummary } from "./nutrition.service";
import * as summaryRepo from "../repositories/summary.repository";
import * as userRepo from "../repositories/user.repository";

export async function getDailySummary(env: Bindings, userId: string, date: string): Promise<{
  date: string;
  goal: { calories: number; proteinG: number; carbsG: number; fatG: number } | null;
  consumed: DailySummary;
  remaining: { calories: number; proteinG: number; carbsG: number; fatG: number } | null;
}> {
  const summaryRow = await summaryRepo.findByUserIdAndDate(env, userId, date);
  const consumed = summaryRow ? mapSummaryRow(summaryRow) : zeroDailySummary(date);

  const profile = await userRepo.findGoalsById(env, userId);

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

function mapSummaryRow(row: summaryRepo.DailySummaryRow): DailySummary {
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
