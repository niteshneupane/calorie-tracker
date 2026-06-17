# Calorie Tracker API

Backend foundation for a calorie intake tracker app. Users can enter natural food text, preview nutrition from a D1 food database, save confirmed meals, and read daily summaries scoped to their Supabase identity.

## Tech Stack

- Cloudflare Workers
- TypeScript
- Hono
- Cloudflare D1
- Cloudflare KV
- Cloudflare Workers AI
- Supabase authentication
- Wrangler

## Setup

```bash
cd worker
npm install
```

Copy `wrangler.toml` values to match your Cloudflare account and Supabase project.

## Create Cloudflare D1 Database

```bash
npx wrangler d1 create calorie_tracker_db
```

Copy the returned `database_id` into `wrangler.toml`.

## Create Cloudflare KV Namespace

```bash
npx wrangler kv namespace create FOOD_PARSE_CACHE
```

Copy the returned namespace `id` into `wrangler.toml`.

## Configure Supabase

Set these values in `wrangler.toml` or Cloudflare dashboard environment variables:

```toml
SUPABASE_URL = "https://YOUR_PROJECT_REF.supabase.co"
SUPABASE_PUBLISHABLE_KEY = "YOUR_SUPABASE_PUBLISHABLE_KEY"
```

## Apply Schema Locally

```bash
npm run db:migrate:local
```

## Seed Locally

```bash
npm run db:seed:local
```

Seed nutrition values are approximate MVP estimates marked with `source = "seed_estimate"` and `confidence = 0.7`. Replace them later with verified nutrition data.

## Run Dev Server

```bash
npm run dev
```

## Deploy

```bash
npm run db:migrate:remote
npm run db:seed:remote
npm run deploy
```

## Browser API Docs

Swagger UI is available at:

```text
https://<your-worker-domain>/docs
```

The OpenAPI JSON document is available at:

```text
https://<your-worker-domain>/openapi.json
```

Use the Swagger `Authorize` button to paste a Supabase access token before trying protected endpoints.

## Curl Examples

Health check:

```bash
curl http://localhost:8787/
```

All API requests except `GET /` require:

```http
Authorization: Bearer <supabase_access_token>
```

Parse food text:

```bash
curl -X POST http://localhost:8787/api/food/parse \
  -H "Authorization: Bearer <supabase_access_token>" \
  -H "Content-Type: application/json" \
  -d '{"text":"chowmin 1 plate","locale":"ne-NP"}'
```

Preview nutrition:

```bash
curl -X POST http://localhost:8787/api/food/preview \
  -H "Authorization: Bearer <supabase_access_token>" \
  -H "Content-Type: application/json" \
  -d '{"items":[{"canonicalName":"vegetable chowmein","quantity":1,"unit":"plate","grams":350}]}'
```

Search foods:

```bash
curl "http://localhost:8787/api/food/search?q=chowmein" \
  -H "Authorization: Bearer <supabase_access_token>"
```

The alias route is also available:

```bash
curl "http://localhost:8787/api/foods/search?q=chowmein" \
  -H "Authorization: Bearer <supabase_access_token>"
```

Save meal:

```bash
curl -X POST http://localhost:8787/api/meals \
  -H "Authorization: Bearer <supabase_access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "date":"2026-06-17",
    "mealType":"lunch",
    "items":[{
      "foodId":"food_veg_chowmein",
      "foodName":"Vegetable Chowmein",
      "quantity":1,
      "unit":"plate",
      "grams":350,
      "calories":525,
      "proteinG":14,
      "carbsG":72,
      "fatG":18,
      "fiberG":5,
      "sugarG":6,
      "sodiumMg":850,
      "calciumMg":80,
      "ironMg":2.1,
      "potassiumMg":420,
      "isEstimate":true,
      "confidence":0.8
    }]
  }'
```

Get meals by date:

```bash
curl "http://localhost:8787/api/meals?date=2026-06-17" \
  -H "Authorization: Bearer <supabase_access_token>"
```

Delete meal:

```bash
curl -X DELETE "http://localhost:8787/api/meals/meal_xxx?date=2026-06-17" \
  -H "Authorization: Bearer <supabase_access_token>"
```

Daily summary:

```bash
curl "http://localhost:8787/api/daily-summary?date=2026-06-17" \
  -H "Authorization: Bearer <supabase_access_token>"
```

Get profile:

```bash
curl http://localhost:8787/api/profile \
  -H "Authorization: Bearer <supabase_access_token>"
```

Upsert profile:

```bash
curl -X PUT http://localhost:8787/api/profile \
  -H "Authorization: Bearer <supabase_access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Demo User",
    "email":"demo@example.com",
    "age":25,
    "sex":"male",
    "heightCm":170,
    "weightKg":70,
    "activityLevel":"moderate",
    "goal":"maintain",
    "dailyCalorieGoal":2200,
    "proteinGoalG":120,
    "carbsGoalG":250,
    "fatGoalG":70
  }'
```

## Security Notes

The API never accepts `userId` from request bodies or query strings. User-owned data is scoped by the verified Supabase access token `sub` claim. AI is used only for food parsing and normalization; nutrition calculations use stored D1 food values.
