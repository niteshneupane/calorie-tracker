# My Calorie

My Calorie is a Flutter mobile calorie tracker for logging meals in natural text,
such as `chowmin 1 plate`, `dal bhat 1 thali`, or `2 boiled eggs`.

The app is structured with Riverpod controllers, repository classes, a Dio API
client, Material 3 theming, reusable design-system widgets, and Supabase auth.

## Run

```bash
flutter pub get
flutter run
```

Android package and iOS bundle identifiers are generated under:

```text
com.neupanenitesh.aahar_log
```

## Configuration

The backend defaults to:

```text
https://calorie-tracker-api.developernpne.workers.dev
```

Override it with:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

Mock mode is off by default. Enable it when you want to test the UI without
Supabase or backend tokens:

```dart
AppConfig.useMockData == false
```

Run with mock data:

```bash
flutter run --dart-define=USE_MOCK_DATA=true
```

Use the real backend with Supabase:

```bash
flutter run \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

`SUPABASE_URL` defaults to `https://reoakapmucltbdqmrwkt.supabase.co`. Override
it with `--dart-define=SUPABASE_URL=...` only if you switch Supabase projects.


Only the Supabase anon key belongs in Flutter. Do not put service-role keys or
database credentials in the mobile app.

## Backend Integration

The API client uses the documented backend paths:

- `POST /api/food/parse`
- `POST /api/food/preview`
- `GET /api/food/search?q=...`
- `POST /api/meals`
- `GET /api/meals?date=YYYY-MM-DD`
- `DELETE /api/meals/{id}?date=YYYY-MM-DD`
- `GET /api/daily-summary?date=YYYY-MM-DD`
- `GET /api/profile`
- `PUT /api/profile`

When mock mode is off, `AuthInterceptor` attaches
`Authorization: Bearer <supabase_access_token>`. The backend derives user
identity from the token, so request bodies do not include `userId`.

## Notes

- `supabase_flutter` is used for email/password sign-in and sign-up.
- The current sign-in screen uses a local mock sign-in flow only when mock mode
  is explicitly enabled.
- `freezed`, `json_serializable`, `auto_route`, and Riverpod generator
  dependencies are present for production code generation, while this checked-in
  pass keeps models and routing manual so the app analyzes and tests cleanly.
