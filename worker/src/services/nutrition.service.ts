import type { DailySummary, FoodRow, NutritionValues } from "../types";

export function calculateNutrition(food: FoodRow, grams: number): NutritionValues {
  const factor = grams / 100;
  return roundNutrition({
    calories: food.calories_per_100g * factor,
    proteinG: value(food.protein_per_100g) * factor,
    carbsG: value(food.carbs_per_100g) * factor,
    fatG: value(food.fat_per_100g) * factor,
    fiberG: value(food.fiber_per_100g) * factor,
    sugarG: value(food.sugar_per_100g) * factor,
    sodiumMg: value(food.sodium_mg_per_100g) * factor,
    calciumMg: value(food.calcium_mg_per_100g) * factor,
    ironMg: value(food.iron_mg_per_100g) * factor,
    potassiumMg: value(food.potassium_mg_per_100g) * factor,
    vitaminAMcg: value(food.vitamin_a_mcg_per_100g) * factor,
    vitaminCMg: value(food.vitamin_c_mg_per_100g) * factor,
    vitaminB12Mcg: value(food.vitamin_b12_mcg_per_100g) * factor,
  });
}

export function sumNutrition(items: NutritionValues[]): NutritionValues {
  const total = zeroNutritionValues();
  for (const item of items) {
    total.calories += item.calories;
    total.proteinG += item.proteinG;
    total.carbsG += item.carbsG;
    total.fatG += item.fatG;
    total.fiberG += item.fiberG;
    total.sugarG += item.sugarG;
    total.sodiumMg += item.sodiumMg;
    total.calciumMg += item.calciumMg;
    total.ironMg += item.ironMg;
    total.potassiumMg += item.potassiumMg;
    total.vitaminAMcg = (total.vitaminAMcg ?? 0) + (item.vitaminAMcg ?? 0);
    total.vitaminCMg = (total.vitaminCMg ?? 0) + (item.vitaminCMg ?? 0);
    total.vitaminB12Mcg = (total.vitaminB12Mcg ?? 0) + (item.vitaminB12Mcg ?? 0);
  }
  return roundNutrition(total);
}

export function roundNutrition(values: NutritionValues): NutritionValues {
  return {
    calories: Math.round(values.calories),
    proteinG: Math.round(values.proteinG),
    carbsG: Math.round(values.carbsG),
    fatG: Math.round(values.fatG),
    fiberG: Math.round(values.fiberG),
    sugarG: Math.round(values.sugarG),
    sodiumMg: Math.round(values.sodiumMg),
    calciumMg: Math.round(values.calciumMg),
    ironMg: Math.round(values.ironMg * 10) / 10,
    potassiumMg: Math.round(values.potassiumMg),
    vitaminAMcg: Math.round((values.vitaminAMcg ?? 0) * 10) / 10,
    vitaminCMg: Math.round((values.vitaminCMg ?? 0) * 10) / 10,
    vitaminB12Mcg: Math.round((values.vitaminB12Mcg ?? 0) * 10) / 10,
  };
}

export function zeroNutritionValues(): NutritionValues {
  return {
    calories: 0,
    proteinG: 0,
    carbsG: 0,
    fatG: 0,
    fiberG: 0,
    sugarG: 0,
    sodiumMg: 0,
    calciumMg: 0,
    ironMg: 0,
    potassiumMg: 0,
    vitaminAMcg: 0,
    vitaminCMg: 0,
    vitaminB12Mcg: 0,
  };
}

export function zeroDailySummary(date: string): DailySummary {
  return {
    date,
    ...zeroNutritionValues(),
  };
}

function value(input: number | null): number {
  return input ?? 0;
}
