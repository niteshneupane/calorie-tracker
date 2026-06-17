export type Bindings = {
  DB: D1Database;
  FOOD_PARSE_CACHE: KVNamespace;
  AI: Ai;
  SUPABASE_URL: string;
  SUPABASE_PUBLISHABLE_KEY: string;
  /** Free USDA FoodData Central key — sign up at fdc.nal.usda.gov/api-key-signup */
  USDA_API_KEY: string;
};

export type Variables = {
  authUser: AuthUser;
};

export type AppEnv = {
  Bindings: Bindings;
  Variables: Variables;
};

export type AuthUser = {
  sub: string;
  email?: string;
  name?: string;
  claims: Record<string, unknown>;
};

export type ParsedFoodItem = {
  rawText: string;
  canonicalName: string;
  quantity: number;
  unit: string;
  estimatedGrams: number | null;
  estimatedMl: number | null;
  confidence: number;
  possibleVariants: string[];
};

export type ParseFoodResponse = {
  items: ParsedFoodItem[];
};

export type FoodRow = {
  id: string;
  name: string;
  aliases: string | null;
  region: string | null;
  category: string | null;
  default_serving_name: string | null;
  default_serving_grams: number | null;
  calories_per_100g: number;
  protein_per_100g: number | null;
  carbs_per_100g: number | null;
  fat_per_100g: number | null;
  fiber_per_100g: number | null;
  sugar_per_100g: number | null;
  sodium_mg_per_100g: number | null;
  calcium_mg_per_100g: number | null;
  iron_mg_per_100g: number | null;
  potassium_mg_per_100g: number | null;
  vitamin_a_mcg_per_100g: number | null;
  vitamin_c_mg_per_100g: number | null;
  vitamin_b12_mcg_per_100g: number | null;
  source: string | null;
  confidence: number | null;
  created_at: string;
  updated_at: string;
};

export type PublicFood = {
  id: string;
  name: string;
  aliases: string[];
  defaultServingName: string | null;
  defaultServingGrams: number | null;
  caloriesPer100g: number;
  proteinPer100g: number;
  carbsPer100g: number;
  fatPer100g: number;
};

export type NutritionValues = {
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
  vitaminAMcg?: number;
  vitaminCMg?: number;
  vitaminB12Mcg?: number;
};

export type NutritionPreviewItem = NutritionValues & {
  foodId: string | null;
  name: string | null;
  inputName: string;
  grams: number | null;
  confidence: number;
  isEstimate: boolean;
  needsManualSelection: boolean;
};

export type NutritionPreviewResponse = {
  items: NutritionPreviewItem[];
  total: NutritionValues;
};

export type SaveMealItem = NutritionValues & {
  foodId?: string | null;
  foodName: string;
  quantity?: number | null;
  unit?: string | null;
  grams: number;
  isEstimate?: boolean;
  confidence?: number | null;
};

export type SaveMealRequest = {
  date: string;
  mealType: MealType;
  notes?: string;
  items: SaveMealItem[];
};

export type MealType = "breakfast" | "lunch" | "dinner" | "snack" | "other";

export type MealLogResponse = {
  id: string;
  date: string;
  mealType: string;
  notes?: string | null;
  items: Array<SaveMealItem & { id: string }>;
};

export type DailySummary = NutritionValues & {
  date: string;
};

export type HistoryDay = {
  date: string;
  calories: number;
  proteinG: number;
  mealCount: number;
};

export type HistoryResponse = {
  from: string;
  to: string;
  items: HistoryDay[];
};

export type UserProfile = {
  id: string;
  authProvider: string;
  authUid: string;
  name: string | null;
  email: string | null;
  age: number | null;
  sex: string | null;
  heightCm: number | null;
  weightKg: number | null;
  activityLevel: string | null;
  goal: string | null;
  dailyCalorieGoal: number | null;
  proteinGoalG: number | null;
  carbsGoalG: number | null;
  fatGoalG: number | null;
  createdAt: string;
  updatedAt: string;
};
