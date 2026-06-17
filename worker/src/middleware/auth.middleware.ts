import type { MiddlewareHandler } from "hono";
import type { AppEnv } from "../types";
import { fail } from "../utils/response";
import { verifyClerkJwt } from "../services/clerk-auth.service";

export const requireAuth: MiddlewareHandler<AppEnv> = async (c, next) => {
  const authorization = c.req.header("Authorization");
  if (!authorization) return fail(c, 401, "UNAUTHORIZED", "Missing Authorization header");

  const [scheme, token] = authorization.split(" ");
  if (scheme !== "Bearer" || !token) return fail(c, 401, "UNAUTHORIZED", "Invalid Authorization header");

  try {
    const authUser = await verifyClerkJwt(c.env, token);
    // TODO: Add admin role extraction and checks when admin APIs are introduced.
    c.set("authUser", authUser);
    await next();
  } catch {
    return fail(c, 401, "UNAUTHORIZED", "Invalid or expired token");
  }
};
