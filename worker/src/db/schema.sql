PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  auth_provider TEXT NOT NULL DEFAULT 'clerk',
  auth_uid TEXT NOT NULL UNIQUE,
  name TEXT,
  email TEXT,
  age INTEGER,
  sex TEXT,
  height_cm REAL,
  weight_kg REAL,
  activity_level TEXT,
  goal TEXT,
  daily_calorie_goal REAL,
  protein_goal_g REAL,
  carbs_goal_g REAL,
  fat_goal_g REAL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS foods (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  aliases TEXT,
  region TEXT,
  category TEXT,
  default_serving_name TEXT,
  default_serving_grams REAL,
  calories_per_100g REAL NOT NULL,
  protein_per_100g REAL,
  carbs_per_100g REAL,
  fat_per_100g REAL,
  fiber_per_100g REAL,
  sugar_per_100g REAL,
  sodium_mg_per_100g REAL,
  calcium_mg_per_100g REAL,
  iron_mg_per_100g REAL,
  potassium_mg_per_100g REAL,
  vitamin_a_mcg_per_100g REAL,
  vitamin_c_mg_per_100g REAL,
  vitamin_b12_mcg_per_100g REAL,
  source TEXT,
  confidence REAL DEFAULT 0.8,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS serving_sizes (
  id TEXT PRIMARY KEY,
  food_id TEXT NOT NULL,
  name TEXT NOT NULL,
  grams REAL NOT NULL,
  is_default INTEGER DEFAULT 0,
  FOREIGN KEY (food_id) REFERENCES foods(id)
);

CREATE TABLE IF NOT EXISTS meal_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  date TEXT NOT NULL,
  meal_type TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS meal_items (
  id TEXT PRIMARY KEY,
  meal_log_id TEXT NOT NULL,
  food_id TEXT,
  food_name TEXT NOT NULL,
  quantity REAL,
  unit TEXT,
  grams REAL,
  calories REAL,
  protein_g REAL,
  carbs_g REAL,
  fat_g REAL,
  fiber_g REAL,
  sugar_g REAL,
  sodium_mg REAL,
  calcium_mg REAL,
  iron_mg REAL,
  potassium_mg REAL,
  vitamin_a_mcg REAL,
  vitamin_c_mg REAL,
  vitamin_b12_mcg REAL,
  is_estimate INTEGER DEFAULT 1,
  confidence REAL,
  FOREIGN KEY (meal_log_id) REFERENCES meal_logs(id),
  FOREIGN KEY (food_id) REFERENCES foods(id)
);

CREATE TABLE IF NOT EXISTS daily_summaries (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  date TEXT NOT NULL,
  calories REAL DEFAULT 0,
  protein_g REAL DEFAULT 0,
  carbs_g REAL DEFAULT 0,
  fat_g REAL DEFAULT 0,
  fiber_g REAL DEFAULT 0,
  sugar_g REAL DEFAULT 0,
  sodium_mg REAL DEFAULT 0,
  calcium_mg REAL DEFAULT 0,
  iron_mg REAL DEFAULT 0,
  potassium_mg REAL DEFAULT 0,
  vitamin_a_mcg REAL DEFAULT 0,
  vitamin_c_mg REAL DEFAULT 0,
  vitamin_b12_mcg REAL DEFAULT 0,
  updated_at TEXT NOT NULL,
  UNIQUE(user_id, date),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_date ON meal_logs(user_id, date);
CREATE INDEX IF NOT EXISTS idx_meal_items_meal_log ON meal_items(meal_log_id);
CREATE INDEX IF NOT EXISTS idx_daily_summaries_user_date ON daily_summaries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_users_auth_uid ON users(auth_uid);
