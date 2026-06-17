import type { Context } from "hono";
import type { ContentfulStatusCode } from "hono/utils/http-status";

export function ok(c: Context, data: unknown, status: ContentfulStatusCode = 200): Response {
  return c.json(data, status);
}

export function fail(c: Context, status: ContentfulStatusCode, code: string, message: string): Response {
  return c.json(
    {
      error: {
        code,
        message,
      },
    },
    status,
  );
}
