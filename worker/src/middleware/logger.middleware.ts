import type { MiddlewareHandler } from "hono";

export const loggerMiddleware: MiddlewareHandler = async (c, next) => {
  const start = Date.now();
  await next();
  const durationMs = Date.now() - start;
  console.log(`${c.req.method} ${c.req.path} ${c.res.status} ${durationMs}ms`);
};
