import type { Bindings, FoodRow } from "../types";

export async function findByName(env: Bindings, name: string): Promise<FoodRow | null> {
  return env.DB.prepare("SELECT * FROM foods WHERE lower(name) = ? LIMIT 1").bind(name).first<FoodRow>();
}

export async function findByAliasLike(env: Bindings, alias: string): Promise<FoodRow[]> {
  const result = await env.DB.prepare("SELECT * FROM foods WHERE lower(aliases) LIKE ? ESCAPE '\\' LIMIT 50")
    .bind(`%${alias}%`)
    .all<FoodRow>();
  return result.results ?? [];
}

export async function search(env: Bindings, query: string): Promise<FoodRow[]> {
  const result = await env.DB.prepare("SELECT * FROM foods WHERE lower(name) LIKE ? OR lower(aliases) LIKE ? ORDER BY name LIMIT 20")
    .bind(`%${query}%`, `%${query}%`)
    .all<FoodRow>();
  return result.results ?? [];
}

export async function list(env: Bindings, limit = 20): Promise<FoodRow[]> {
  const result = await env.DB.prepare("SELECT * FROM foods ORDER BY name LIMIT ?").bind(limit).all<FoodRow>();
  return result.results ?? [];
}
