import type { Bindings, HistoryDay, HistoryResponse } from "../types";
import * as summaryRepo from "../repositories/summary.repository";

export async function getHistory(env: Bindings, userId: string, from: string, to: string): Promise<HistoryResponse> {
  const rows = await summaryRepo.getHistory(env, userId, from, to);

  const byDate = new Map<string, HistoryDay>();
  for (const row of rows) {
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
