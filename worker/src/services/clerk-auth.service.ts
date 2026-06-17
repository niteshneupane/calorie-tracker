import type { AuthUser, Bindings } from "../types";

type JwtHeader = {
  alg?: string;
  kid?: string;
  typ?: string;
};

type Jwks = {
  keys: Array<JsonWebKey & { kid?: string }>;
};

let cachedJwks: { url: string; fetchedAt: number; jwks: Jwks } | null = null;
const jwksTtlMs = 10 * 60 * 1000;

export async function verifyClerkJwt(env: Bindings, token: string): Promise<AuthUser> {
  const parts = token.split(".");
  if (parts.length !== 3) throw new Error("Invalid JWT");

  const header = decodeJson<JwtHeader>(parts[0]);
  const claims = decodeJson<Record<string, unknown>>(parts[1]);
  if (header.alg !== "RS256") throw new Error("Unsupported JWT algorithm");
  if (!header.kid) throw new Error("Missing JWT kid");

  const jwks = await getJwks(env.CLERK_JWKS_URL);
  const jwk = jwks.keys.find((key) => key.kid === header.kid);
  if (!jwk) throw new Error("JWT signing key not found");

  const key = await crypto.subtle.importKey(
    "jwk",
    jwk,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["verify"],
  );

  const signature = base64UrlToBytes(parts[2]);
  const data = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
  const valid = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", key, signature, data);
  if (!valid) throw new Error("Invalid JWT signature");

  validateClaims(env, claims);

  return {
    sub: claims.sub as string,
    email: extractStringClaim(claims, ["email", "primary_email_address"]),
    name: extractStringClaim(claims, ["name", "full_name"]),
    claims,
  };
}

async function getJwks(url: string): Promise<Jwks> {
  const now = Date.now();
  if (cachedJwks && cachedJwks.url === url && now - cachedJwks.fetchedAt < jwksTtlMs) {
    return cachedJwks.jwks;
  }

  const response = await fetch(url);
  if (!response.ok) throw new Error("Failed to fetch JWKS");
  const jwks = (await response.json()) as Jwks;
  cachedJwks = { url, fetchedAt: now, jwks };
  return jwks;
}

function validateClaims(env: Bindings, claims: Record<string, unknown>): void {
  const nowSeconds = Math.floor(Date.now() / 1000);
  const sub = claims.sub;
  const exp = claims.exp;
  const nbf = claims.nbf;
  const iat = claims.iat;
  const iss = claims.iss;
  const aud = claims.aud;

  if (typeof sub !== "string" || sub.length === 0) throw new Error("Missing subject");
  if (typeof exp !== "number" || exp <= nowSeconds) throw new Error("JWT expired");
  if (typeof nbf === "number" && nbf > nowSeconds) throw new Error("JWT not active yet");
  if (typeof iat === "number" && iat > nowSeconds) throw new Error("JWT issued in future");
  if (iss !== env.CLERK_ISSUER) throw new Error("Invalid issuer");

  if (env.CLERK_AUDIENCE) {
    const expected = env.CLERK_AUDIENCE;
    const audienceMatches = Array.isArray(aud) ? aud.includes(expected) : aud === expected;
    if (!audienceMatches) throw new Error("Invalid audience");
  }
}

function decodeJson<T>(part: string): T {
  const text = new TextDecoder().decode(base64UrlToBytes(part));
  return JSON.parse(text) as T;
}

function base64UrlToBytes(value: string): Uint8Array {
  const padded = value.replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(value.length / 4) * 4, "=");
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index += 1) {
    bytes[index] = binary.charCodeAt(index);
  }
  return bytes;
}

function extractStringClaim(claims: Record<string, unknown>, names: string[]): string | undefined {
  for (const name of names) {
    const value = claims[name];
    if (typeof value === "string" && value.length > 0) return value;
  }
  return undefined;
}
