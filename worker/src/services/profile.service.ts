import type { AuthUser, Bindings, UserProfile } from "../types";
import { nowIso } from "../utils/date";

type UserRow = {
  id: string;
  auth_provider: string;
  auth_uid: string;
  name: string | null;
  email: string | null;
  age: number | null;
  sex: string | null;
  height_cm: number | null;
  weight_kg: number | null;
  activity_level: string | null;
  goal: string | null;
  daily_calorie_goal: number | null;
  protein_goal_g: number | null;
  carbs_goal_g: number | null;
  fat_goal_g: number | null;
  created_at: string;
  updated_at: string;
};

export async function getProfile(env: Bindings, userId: string): Promise<UserProfile | null> {
  const row = await env.DB.prepare("SELECT * FROM users WHERE id = ? LIMIT 1").bind(userId).first<UserRow>();
  return row ? mapUserRow(row) : null;
}

export async function upsertProfile(env: Bindings, userId: string, authUser: AuthUser, body: Record<string, unknown>): Promise<UserProfile> {
  const existing = await env.DB.prepare("SELECT created_at FROM users WHERE id = ? LIMIT 1").bind(userId).first<{ created_at: string }>();
  const timestamp = nowIso();
  await env.DB.prepare(
    `INSERT INTO users (
      id, auth_provider, auth_uid, name, email, age, sex, height_cm, weight_kg, activity_level, goal,
      daily_calorie_goal, protein_goal_g, carbs_goal_g, fat_goal_g, created_at, updated_at
    ) VALUES (?, 'clerk', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      auth_provider = 'clerk',
      auth_uid = excluded.auth_uid,
      name = excluded.name,
      email = excluded.email,
      age = excluded.age,
      sex = excluded.sex,
      height_cm = excluded.height_cm,
      weight_kg = excluded.weight_kg,
      activity_level = excluded.activity_level,
      goal = excluded.goal,
      daily_calorie_goal = excluded.daily_calorie_goal,
      protein_goal_g = excluded.protein_goal_g,
      carbs_goal_g = excluded.carbs_goal_g,
      fat_goal_g = excluded.fat_goal_g,
      updated_at = excluded.updated_at`,
  )
    .bind(
      userId,
      userId,
      stringOrNull(body.name) ?? authUser.name ?? null,
      stringOrNull(body.email) ?? authUser.email ?? null,
      numberOrNull(body.age),
      stringOrNull(body.sex),
      numberOrNull(body.heightCm),
      numberOrNull(body.weightKg),
      stringOrNull(body.activityLevel),
      stringOrNull(body.goal),
      numberOrNull(body.dailyCalorieGoal),
      numberOrNull(body.proteinGoalG),
      numberOrNull(body.carbsGoalG),
      numberOrNull(body.fatGoalG),
      existing?.created_at ?? timestamp,
      timestamp,
    )
    .run();

  const profile = await getProfile(env, userId);
  if (!profile) throw new Error("Profile upsert failed");
  return profile;
}

function mapUserRow(row: UserRow): UserProfile {
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
