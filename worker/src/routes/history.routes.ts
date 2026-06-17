import { Hono } from "hono";
import type { AppEnv } from "../types";
import { getHistory } from "../services/history.service";
import { fail, ok } from "../utils/response";
import { validateDateYYYYMMDD } from "../utils/validators";

export const historyRoutes = new Hono<AppEnv>();

historyRoutes.get("/", async (c) => {
  const auth = c.get("authUser");
  const from = c.req.query("from");
  const to = c.req.query("to");
  if (!validateDateYYYYMMDD(from)) return fail(c, 400, "BAD_REQUEST", "Valid from date is required");
  if (!validateDateYYYYMMDD(to)) return fail(c, 400, "BAD_REQUEST", "Valid to date is required");
  if (from > to) return fail(c, 400, "BAD_REQUEST", "from must be before or equal to to");

  return ok(c, await getHistory(c.env, auth.sub, from, to));
});
