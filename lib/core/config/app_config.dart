class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://calorie-tracker-api.developernpne.workers.dev',
  );
  static const useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );
  static const clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  static const hasClerkPublishableKey = clerkPublishableKey != '';
}
