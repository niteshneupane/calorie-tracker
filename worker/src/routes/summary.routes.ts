import { Hono } from "hono";
import type { AppEnv } from "../types";
import { getDailySummary } from "../services/summary.service";
import { fail, ok } from "../utils/response";
import { validateDateYYYYMMDD } from "../utils/validators";

export const summaryRoutes = new Hono<AppEnv>();

summaryRoutes.get("/", async (c) => {
  const auth = c.get("authUser");
  const date = c.req.query("date");
  if (!validateDateYYYYMMDD(date)) return fail(c, 400, "BAD_REQUEST", "Valid date is required");

  const summary = await getDailySummary(c.env, auth.sub, date);
  return ok(c, summary);
});
