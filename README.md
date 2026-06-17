# AaharLog

AaharLog is a Flutter mobile calorie tracker for logging meals in natural text,
such as `chowmin 1 plate`, `dal bhat 1 thali`, or `2 boiled eggs`.

The app is structured with Riverpod controllers, repository classes, a Dio API
client, Material 3 theming, reusable design-system widgets, and mock data mode
enabled by default.

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

Mock mode is on by default so the UI can be tested without Clerk or backend
tokens:

```dart
AppConfig.useMockData == true
```

Use the real backend with:

```bash
flutter run \
  --dart-define=USE_MOCK_DATA=false \
  --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_xxx
```

Only the Clerk publishable key belongs in Flutter. Do not put Clerk secret keys
in the mobile app.

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
`Authorization: Bearer <clerk_jwt>`. The backend derives user identity from the
JWT, so request bodies do not include `userId`.

## Notes

- `clerk_flutter` is included at the latest compatible beta found during setup:
  `^0.0.16-beta`.
- The current sign-in screen uses a local mock sign-in flow while mock mode is
  enabled. Wire the screen to Clerk's current widgets/session API when switching
  real authentication on.
- `freezed`, `json_serializable`, `auto_route`, and Riverpod generator
  dependencies are present for production code generation, while this checked-in
  pass keeps models and routing manual so the app analyzes and tests cleanly.
