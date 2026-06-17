import type { Bindings, FoodRow, PublicFood } from "../types";

export async function findFoodByNameOrAlias(env: Bindings, name: string): Promise<FoodRow | null> {
  const normalized = normalize(name);
  const exact = await env.DB.prepare("SELECT * FROM foods WHERE lower(name) = ? LIMIT 1").bind(normalized).first<FoodRow>();
  if (exact) return exact;

  const candidates = await env.DB.prepare("SELECT * FROM foods WHERE lower(aliases) LIKE ? LIMIT 50").bind(`%${normalized}%`).all<FoodRow>();
  for (const food of candidates.results ?? []) {
    const aliases = parseAliases(food.aliases);
    if (aliases.some((alias) => normalize(alias) === normalized)) return food;
  }

  return null;
}

export async function searchFoods(env: Bindings, query: string): Promise<PublicFood[]> {
  const normalized = normalize(query);
  const result = await env.DB.prepare("SELECT * FROM foods WHERE lower(name) LIKE ? OR lower(aliases) LIKE ? ORDER BY name LIMIT 20")
    .bind(`%${normalized}%`, `%${normalized}%`)
    .all<FoodRow>();
  return (result.results ?? []).map(mapFoodRowToPublicFood);
}

export function mapFoodRowToPublicFood(food: FoodRow): PublicFood {
  return {
    id: food.id,
    name: food.name,
    aliases: parseAliases(food.aliases),
    defaultServingName: food.default_serving_name,
    defaultServingGrams: food.default_serving_grams,
    caloriesPer100g: food.calories_per_100g,
    proteinPer100g: food.protein_per_100g ?? 0,
    carbsPer100g: food.carbs_per_100g ?? 0,
    fatPer100g: food.fat_per_100g ?? 0,
  };
}

export function parseAliases(aliases: string | null): string[] {
  if (!aliases) return [];
  try {
    const parsed = JSON.parse(aliases);
    return Array.isArray(parsed) ? parsed.filter((item): item is string => typeof item === "string") : [];
  } catch {
    return [];
  }
}

function normalize(value: string): string {
  return value.trim().toLowerCase().replace(/\s+/g, " ");
}
