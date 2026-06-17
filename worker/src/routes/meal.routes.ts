import { Hono } from "hono";
import type { AppEnv } from "../types";
import { deleteMeal, getMealsByDate, saveMeal } from "../services/meal.service";
import { fail, ok } from "../utils/response";
import { validateDateYYYYMMDD, validateSaveMealRequest } from "../utils/validators";

export const mealRoutes = new Hono<AppEnv>();

mealRoutes.post("/", async (c) => {
  const auth = c.get("authUser");
  const validation = validateSaveMealRequest(await c.req.json().catch(() => null));
  if (!validation.ok) return fail(c, 400, "BAD_REQUEST", validation.message);

  const result = await saveMeal(c.env, auth.sub, validation.value);
  return ok(c, result, 201);
});

mealRoutes.get("/", async (c) => {
  const auth = c.get("authUser");
  const date = c.req.query("date");
  if (!validateDateYYYYMMDD(date)) return fail(c, 400, "BAD_REQUEST", "Valid date is required");

  const items = await getMealsByDate(c.env, auth.sub, date);
  return ok(c, { items });
});

mealRoutes.delete("/:id", async (c) => {
  const auth = c.get("authUser");
  const mealId = c.req.param("id");
  const date = c.req.query("date");
  if (!validateDateYYYYMMDD(date)) return fail(c, 400, "BAD_REQUEST", "Valid date is required");

  const dailySummary = await deleteMeal(c.env, auth.sub, mealId, date);
  if (!dailySummary) return fail(c, 404, "NOT_FOUND", "Meal not found");
  return ok(c, { deleted: true, dailySummary });
});
