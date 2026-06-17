import { cors } from "hono/cors";

// TODO: Restrict production origins after the Flutter/web client origins are final.
export const corsMiddleware = cors({
  origin: "*",
  allowHeaders: ["Authorization", "Content-Type"],
  allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  maxAge: 86400,
});
