import { Hono } from "hono";
import type { AppEnv } from "../types";
import { getProfile, upsertProfile } from "../services/profile.service";
import { fail, ok } from "../utils/response";
import { validateProfileRequest } from "../utils/validators";

export const profileRoutes = new Hono<AppEnv>();

profileRoutes.get("/", async (c) => {
  const auth = c.get("authUser");
  const profile =
    (await getProfile(c.env, auth.sub)) ??
    (await upsertProfile(c.env, auth.sub, auth, {}));
  return ok(c, profile);
});

profileRoutes.put("/", async (c) => {
  const auth = c.get("authUser");
  const validation = validateProfileRequest(await c.req.json().catch(() => null));
  if (!validation.ok) return fail(c, 400, "BAD_REQUEST", validation.message);

  const profile = await upsertProfile(c.env, auth.sub, auth, validation.value);
  return ok(c, profile);
});
