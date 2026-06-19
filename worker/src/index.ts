import { Hono } from "hono";
import { apiDocsHtml, openApiSpec } from "./docs";
import { requireAuth } from "./middleware/auth.middleware";
import { corsMiddleware } from "./middleware/cors.middleware";
import { loggerMiddleware } from "./middleware/logger.middleware";
import { authRoutes } from "./routes/auth.routes";
import { debugRoutes } from "./routes/debug.routes";
import { foodRoutes, foodSearchHandler } from "./routes/food.routes";
import { historyRoutes } from "./routes/history.routes";
import { mealRoutes } from "./routes/meal.routes";
import { profileRoutes } from "./routes/profile.routes";
import { summaryRoutes } from "./routes/summary.routes";
import type { AppEnv } from "./types";
import { fail, ok } from "./utils/response";
import { parseFoodText } from "./services/ai.service";
import { estimateNutrition } from "./services/estimation.service";
import { validateParseFoodRequest } from "./utils/validators";

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
app.route("/auth", authRoutes);

// Temporary: test endpoint for parse without auth
app.post("/parse", async (c) => {
  const body = await c.req.json().catch(() => null);
  const validation = validateParseFoodRequest(body);
  if (!validation.ok) return fail(c, 400, "BAD_REQUEST", validation.message);

  const { text, locale } = validation.value;
  const parseResult = await parseFoodText(c.env, text, locale ?? "en-US");

  const items = await Promise.all(parseResult.items.map(async (item) => {
    const nutrition = await estimateNutrition(
      c.env,
      item.canonicalName,
      item.unit ?? null,
      item.quantity ?? 1,
      item.estimatedGrams ?? null,
    );
    return {
      ...item,
      nutrition: {
        calories: nutrition.calories,
        proteinG: nutrition.proteinG,
        carbsG: nutrition.carbsG,
        fatG: nutrition.fatG,
        fiberG: nutrition.fiberG,
        sugarG: nutrition.sugarG,
        sodiumMg: nutrition.sodiumMg,
        calciumMg: nutrition.calciumMg,
        ironMg: nutrition.ironMg,
        potassiumMg: nutrition.potassiumMg,
        saturatedFatG: nutrition.saturatedFatG,
        transFatG: nutrition.transFatG,
        cholesterolMg: nutrition.cholesterolMg,
        vitaminDMcg: nutrition.vitaminDMcg,
        vitaminEMg: nutrition.vitaminEMg,
        vitaminKMcg: nutrition.vitaminKMcg,
        folateMcg: nutrition.folateMcg,
        caffeineMg: nutrition.caffeineMg,
      },
      nutritionSource: nutrition.source,
      nutritionConfidence: nutrition.confidence,
    };
  }));

  return ok(c, { items });
});

app.use("/api/*", requireAuth);
app.route("/api/food", foodRoutes);
app.get("/api/foods/search", foodSearchHandler);
app.route("/api/meals", mealRoutes);
app.route("/api/daily-summary", summaryRoutes);
app.route("/api/history", historyRoutes);
app.route("/api/profile", profileRoutes);

export default app;
