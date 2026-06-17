import 'food_entry/domain/nutrition_models.dart';

class MockData {
  static const goal = MacroGoal(
    calories: 2200,
    proteinG: 120,
    carbsG: 250,
    fatG: 70,
  );

  static const consumed = NutritionValues(
    calories: 1450,
    proteinG: 62,
    carbsG: 180,
    fatG: 48,
    fiberG: 18,
    sugarG: 34,
    sodiumMg: 1850,
    calciumMg: 520,
    ironMg: 9.4,
    potassiumMg: 2100,
  );

  static const remaining = MacroGoal(
    calories: 750,
    proteinG: 58,
    carbsG: 70,
    fatG: 22,
  );

  static const previewItem = NutritionPreviewItem(
    calories: 525,
    proteinG: 14,
    carbsG: 72,
    fatG: 18,
    fiberG: 5,
    sugarG: 6,
    sodiumMg: 850,
    calciumMg: 80,
    ironMg: 2.1,
    potassiumMg: 420,
    foodId: 'food_veg_chowmein',
    name: 'Vegetable Chowmein',
    inputName: 'vegetable chowmein',
    grams: 350,
    confidence: 0.72,
    isEstimate: true,
    needsManualSelection: false,
  );

  static const foods = [
    PublicFood(
      id: 'food_veg_chowmein',
      name: 'Vegetable Chowmein',
      aliases: ['chowmin', 'veg chowmein', 'noodles'],
      defaultServingName: 'medium plate',
      defaultServingGrams: 350,
      caloriesPer100g: 150,
      proteinPer100g: 4,
      carbsPer100g: 21,
      fatPer100g: 5,
    ),
    PublicFood(
      id: 'food_dal_bhat',
      name: 'Dal Bhat',
      aliases: ['dal bhat', 'rice lentils'],
      defaultServingName: '1 thali',
      defaultServingGrams: 520,
      caloriesPer100g: 118,
      proteinPer100g: 4.5,
      carbsPer100g: 22,
      fatPer100g: 1.8,
    ),
    PublicFood(
      id: 'food_momo',
      name: 'Chicken Momo',
      aliases: ['momo', 'dumpling'],
      defaultServingName: '10 pcs',
      defaultServingGrams: 300,
      caloriesPer100g: 190,
      proteinPer100g: 10,
      carbsPer100g: 24,
      fatPer100g: 6,
    ),
    PublicFood(
      id: 'food_egg',
      name: 'Boiled Egg',
      aliases: ['egg', 'boiled egg'],
      defaultServingName: '1 egg',
      defaultServingGrams: 50,
      caloriesPer100g: 155,
      proteinPer100g: 13,
      carbsPer100g: 1.1,
      fatPer100g: 11,
    ),
  ];

  static const meals = [
    MealLog(
      id: 'meal_lunch',
      date: '2026-06-17',
      mealType: 'lunch',
      notes: 'Office lunch',
      items: [previewItem],
    ),
  ];

  static const user = UserProfile(
    id: 'mock_user',
    name: 'Demo User',
    email: 'demo@example.com',
    age: 25,
    sex: 'male',
    heightCm: 170,
    weightKg: 70,
    activityLevel: 'moderate',
    goal: 'maintain',
    dailyCalorieGoal: 2200,
    proteinGoalG: 120,
    carbsGoalG: 250,
    fatGoalG: 70,
  );
}
