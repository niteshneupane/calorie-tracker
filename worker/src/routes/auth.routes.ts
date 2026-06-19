import { Hono } from "hono";
import type { AppEnv } from "../types";
import { fail, ok } from "../utils/response";

export const authRoutes = new Hono<AppEnv>();

authRoutes.post("/login", async (c) => {
  const { email, password } = await c.req.json().catch(() => ({}));
  if (!email || !password) return fail(c, 400, "BAD_REQUEST", "email and password are required");

  const response = await fetch(`${c.env.SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: c.env.SUPABASE_PUBLISHABLE_KEY,
    },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    const err = await response.json().catch(() => ({}));
    return fail(c, 401, "UNAUTHORIZED", (err as { error_description?: string }).error_description ?? "Invalid credentials");
  }

  const data = (await response.json()) as {
    access_token: string;
    token_type: string;
    expires_in: number;
    refresh_token: string;
    user: { id: string; email?: string };
  };

  return ok(c, {
    token: data.access_token,
    tokenType: data.token_type,
    expiresIn: data.expires_in,
    refreshToken: data.refresh_token,
    user: { id: data.user.id, email: data.user.email },
  });
});

authRoutes.post("/signup", async (c) => {
  const { email, password } = await c.req.json().catch(() => ({}));
  if (!email || !password) return fail(c, 400, "BAD_REQUEST", "email and password are required");
  if (password.length < 6) return fail(c, 400, "BAD_REQUEST", "password must be at least 6 characters");

  const response = await fetch(`${c.env.SUPABASE_URL}/auth/v1/signup`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: c.env.SUPABASE_PUBLISHABLE_KEY,
    },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    const err = await response.json().catch(() => ({}));
    return fail(c, 400, "BAD_REQUEST", (err as { msg?: string }).msg ?? "Signup failed");
  }

  const data = (await response.json()) as {
    id: string;
    email?: string;
    access_token?: string;
    token_type?: string;
    expires_in?: number;
  };

  return ok(c, {
    user: { id: data.id, email: data.email },
    ...(data.access_token ? { token: data.access_token, tokenType: data.token_type, expiresIn: data.expires_in } : {}),
  });
});
