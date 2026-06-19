import type { Bindings } from "../types";

export type UserRow = {
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

export type GoalRow = {
  daily_calorie_goal: number | null;
  protein_goal_g: number | null;
  carbs_goal_g: number | null;
  fat_goal_g: number | null;
};

export async function findById(env: Bindings, userId: string): Promise<UserRow | null> {
  return env.DB.prepare("SELECT * FROM users WHERE id = ? LIMIT 1").bind(userId).first<UserRow>();
}

export async function findCreatedAtById(env: Bindings, userId: string): Promise<{ created_at: string } | null> {
  return env.DB.prepare("SELECT created_at FROM users WHERE id = ? LIMIT 1").bind(userId).first<{ created_at: string }>();
}

export async function findGoalsById(env: Bindings, userId: string): Promise<GoalRow | null> {
  return env.DB.prepare("SELECT daily_calorie_goal, protein_goal_g, carbs_goal_g, fat_goal_g FROM users WHERE id = ? LIMIT 1")
    .bind(userId)
    .first<GoalRow>();
}

export async function upsert(
  env: Bindings,
  params: {
    id: string;
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
  },
): Promise<void> {
  await env.DB.prepare(
    `INSERT INTO users (
      id, auth_provider, auth_uid, name, email, age, sex, height_cm, weight_kg, activity_level, goal,
      daily_calorie_goal, protein_goal_g, carbs_goal_g, fat_goal_g, created_at, updated_at
    ) VALUES (?, 'supabase', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      auth_provider = 'supabase',
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
      params.id,
      params.authUid,
      params.name,
      params.email,
      params.age,
      params.sex,
      params.heightCm,
      params.weightKg,
      params.activityLevel,
      params.goal,
      params.dailyCalorieGoal,
      params.proteinGoalG,
      params.carbsGoalG,
      params.fatGoalG,
      params.createdAt,
      params.updatedAt,
    )
    .run();
}

export async function ensureExists(env: Bindings, userId: string, timestamp: string): Promise<void> {
  await env.DB.prepare(
    "INSERT INTO users (id, auth_provider, auth_uid, created_at, updated_at) VALUES (?, 'supabase', ?, ?, ?) ON CONFLICT(id) DO NOTHING",
  )
    .bind(userId, userId, timestamp, timestamp)
    .run();
}
