import type { AuthUser, Bindings, UserProfile } from "../types";
import { nowIso } from "../utils/date";
import * as userRepo from "../repositories/user.repository";

export async function getProfile(env: Bindings, userId: string): Promise<UserProfile | null> {
  const row = await userRepo.findById(env, userId);
  return row ? mapUserRow(row) : null;
}

export async function upsertProfile(env: Bindings, userId: string, authUser: AuthUser, body: Record<string, unknown>): Promise<UserProfile> {
  const existing = await userRepo.findCreatedAtById(env, userId);
  const timestamp = nowIso();

  await userRepo.upsert(env, {
    id: userId,
    authUid: userId,
    name: stringOrNull(body.name) ?? authUser.name ?? null,
    email: stringOrNull(body.email) ?? authUser.email ?? null,
    age: numberOrNull(body.age),
    sex: stringOrNull(body.sex),
    heightCm: numberOrNull(body.heightCm),
    weightKg: numberOrNull(body.weightKg),
    activityLevel: stringOrNull(body.activityLevel),
    goal: stringOrNull(body.goal),
    dailyCalorieGoal: numberOrNull(body.dailyCalorieGoal),
    proteinGoalG: numberOrNull(body.proteinGoalG),
    carbsGoalG: numberOrNull(body.carbsGoalG),
    fatGoalG: numberOrNull(body.fatGoalG),
    createdAt: existing?.created_at ?? timestamp,
    updatedAt: timestamp,
  });

  const profile = await getProfile(env, userId);
  if (!profile) throw new Error("Profile upsert failed");
  return profile;
}

function mapUserRow(row: userRepo.UserRow): UserProfile {
  return {
    id: row.id,
    authProvider: row.auth_provider,
    authUid: row.auth_uid,
    name: row.name,
    email: row.email,
    age: row.age,
    sex: row.sex,
    heightCm: row.height_cm,
    weightKg: row.weight_kg,
    activityLevel: row.activity_level,
    goal: row.goal,
    dailyCalorieGoal: row.daily_calorie_goal,
    proteinGoalG: row.protein_goal_g,
    carbsGoalG: row.carbs_goal_g,
    fatGoalG: row.fat_goal_g,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function stringOrNull(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function numberOrNull(value: unknown): number | null {
  return typeof value === "number" ? value : null;
}
