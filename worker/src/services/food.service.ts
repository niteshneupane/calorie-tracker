import type { Bindings, FoodRow, PublicFood } from "../types";
import * as foodRepo from "../repositories/food.repository";

export async function findFoodByNameOrAlias(env: Bindings, name: string) {
  const normalized = normalize(name);
  const exact = await foodRepo.findByName(env, normalized);
  if (exact) return exact;

  const escaped = normalized.replace(/[%_]/g, "\\$&");
  const candidates = await foodRepo.findByAliasLike(env, escaped);
  for (const food of candidates) {
    const aliases = parseAliases(food.aliases);
    if (aliases.some((alias) => normalize(alias) === normalized)) return food;
  }

  return null;
}

export async function searchFoods(env: Bindings, query: string): Promise<PublicFood[]> {
  const normalized = normalize(query);
  const escaped = normalized.replace(/[%_]/g, "\\$&");
  const rows = await foodRepo.search(env, escaped);
  return rows.map(mapFoodRowToPublicFood);
}

export async function listFoods(env: Bindings): Promise<PublicFood[]> {
  const rows = await foodRepo.list(env);
  return rows.map(mapFoodRowToPublicFood);
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
