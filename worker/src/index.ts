import { Hono } from "hono";
import { apiDocsHtml, openApiSpec } from "./docs";
import { requireAuth } from "./middleware/auth.middleware";
import { corsMiddleware } from "./middleware/cors.middleware";
import { loggerMiddleware } from "./middleware/logger.middleware";
import { foodRoutes, foodSearchHandler } from "./routes/food.routes";
import { historyRoutes } from "./routes/history.routes";
import { mealRoutes } from "./routes/meal.routes";
import { profileRoutes } from "./routes/profile.routes";
import { summaryRoutes } from "./routes/summary.routes";
import type { AppEnv } from "./types";
import { fail, ok } from "./utils/response";

const app = new Hono<AppEnv>();

app.use("*", corsMiddleware);
app.use("*", loggerMiddleware);

app.onError((error, c) => {
  console.error(error);
  return fail(c, 500, "INTERNAL_SERVER_ERROR", "Unexpected server error");
});

app.notFound((c) => fail(c, 404, "NOT_FOUND", "Route not found"));

app.get("/", (c) =>
  ok(c, {
    ok: true,
    name: "calorie-tracker-api",
  }),
);

app.get("/docs", (c) => c.html(apiDocsHtml()));
app.get("/openapi.json", (c) => c.json(openApiSpec(new URL(c.req.url).origin)));

app.use("/api/*", requireAuth);
app.route("/api/food", foodRoutes);
app.get("/api/foods/search", foodSearchHandler);
app.route("/api/meals", mealRoutes);
app.route("/api/daily-summary", summaryRoutes);
app.route("/api/history", historyRoutes);
app.route("/api/profile", profileRoutes);

export default app;
