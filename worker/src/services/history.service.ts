import type { Bindings, HistoryDay, HistoryResponse } from "../types";

type HistoryRow = {
  date: string;
  calories: number | null;
  protein_g: number | null;
  meal_count: number | null;
};

export async function getHistory(env: Bindings, userId: string, from: string, to: string): Promise<HistoryResponse> {
  const rows = await env.DB.prepare(
    `SELECT
      ds.date,
      COALESCE(ds.calories, 0) AS calories,
      COALESCE(ds.protein_g, 0) AS protein_g,
      COALESCE(COUNT(ml.id), 0) AS meal_count
    FROM daily_summaries ds
    LEFT JOIN meal_logs ml ON ml.user_id = ds.user_id AND ml.date = ds.date
    WHERE ds.user_id = ? AND ds.date >= ? AND ds.date <= ?
    GROUP BY ds.date, ds.calories, ds.protein_g
    ORDER BY ds.date DESC`,
  )
    .bind(userId, from, to)
    .all<HistoryRow>();

  const byDate = new Map<string, HistoryDay>();
  for (const row of rows.results ?? []) {
    byDate.set(row.date, {
      date: row.date,
      calories: Math.round(row.calories ?? 0),
      proteinG: Math.round(row.protein_g ?? 0),
      mealCount: Math.round(row.meal_count ?? 0),
    });
  }

  const items = enumerateDates(from, to)
    .reverse()
    .map((date) => byDate.get(date) ?? { date, calories: 0, proteinG: 0, mealCount: 0 });

  return { from, to, items };
}

function enumerateDates(from: string, to: string): string[] {
  const dates: string[] = [];
  const cursor = new Date(`${from}T00:00:00.000Z`);
  const end = new Date(`${to}T00:00:00.000Z`);
  while (cursor <= end) {
    dates.push(cursor.toISOString().slice(0, 10));
    cursor.setUTCDate(cursor.getUTCDate() + 1);
  }
  return dates;
}
