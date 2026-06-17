import type { AuthUser, Bindings } from "../types";

type SupabaseUserResponse = {
  id: string;
  email?: string;
  user_metadata?: Record<string, unknown>;
  app_metadata?: Record<string, unknown>;
  [key: string]: unknown;
};

export async function verifySupabaseJwt(env: Bindings, token: string): Promise<AuthUser> {
  if (!env.SUPABASE_URL || !env.SUPABASE_PUBLISHABLE_KEY) {
    throw new Error("Supabase auth is not configured");
  }

  const response = await fetch(`${trimTrailingSlash(env.SUPABASE_URL)}/auth/v1/user`, {
    headers: {
      apikey: env.SUPABASE_PUBLISHABLE_KEY,
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) throw new Error("Invalid Supabase token");

  const user = (await response.json()) as SupabaseUserResponse;
  if (!user.id) throw new Error("Supabase user id missing");

  const metadata = user.user_metadata ?? {};
  return {
    sub: user.id,
    email: user.email ?? extractString(metadata, ["email"]),
    name: extractString(metadata, ["name", "full_name", "display_name"]),
    claims: user as Record<string, unknown>,
  };
}

function trimTrailingSlash(value: string): string {
  return value.endsWith("/") ? value.slice(0, -1) : value;
}

function extractString(source: Record<string, unknown>, names: string[]): string | undefined {
  for (const name of names) {
    const value = source[name];
    if (typeof value === "string" && value.length > 0) return value;
  }
  return undefined;
}
