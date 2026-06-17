import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../core/storage/local_preferences.dart';
import '../core/storage/token_storage.dart';
import '../core/utils/date_utils.dart';
import 'dashboard/data/dashboard_repository.dart';
import 'food_entry/data/food_entry_repository.dart';
import 'food_entry/domain/nutrition_models.dart';
import 'foods/data/foods_repository.dart';
import 'history/data/history_repository.dart';
import 'meal_logs/data/meal_repository.dart';
import 'profile/data/profile_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const TokenStorage(FlutterSecureStorage()),
);

final localPreferencesProvider = Provider<LocalPreferences>((ref) {
  throw StateError('LocalPreferences must be overridden in main.dart');
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(() async {
    if (AppConfig.hasSupabaseConfig) {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token != null && token.isNotEmpty) return token;
    }
    return ref.read(tokenStorageProvider).readToken();
  }),
);

final dashboardRepositoryProvider = Provider(
  (ref) => DashboardRepository(ref.read(apiClientProvider)),
);
final foodEntryRepositoryProvider = Provider(
  (ref) => FoodEntryRepository(ref.read(apiClientProvider)),
);
final mealRepositoryProvider = Provider(
  (ref) => MealRepository(ref.read(apiClientProvider)),
);
final foodsRepositoryProvider = Provider(
  (ref) => FoodsRepository(ref.read(apiClientProvider)),
);
final historyRepositoryProvider = Provider(
  (ref) => HistoryRepository(ref.read(apiClientProvider)),
);
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.read(apiClientProvider)),
);

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    required this.onboardingComplete,
  });

  final bool isAuthenticated;
  final bool onboardingComplete;

  AuthState copyWith({bool? isAuthenticated, bool? onboardingComplete}) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final preferences = ref.read(localPreferencesProvider);
    return AuthState(
      isAuthenticated: false,
      onboardingComplete: preferences.onboardingComplete,
    );
  }

  Future<void> signInMock() async {
    final preferences = ref.read(localPreferencesProvider);
    state = state.copyWith(
      isAuthenticated: true,
      onboardingComplete: preferences.onboardingComplete,
    );
  }

  Future<void> completeOnboarding() async {
    await ref.read(localPreferencesProvider).setOnboardingComplete(true);
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> signOut() async {
    await ref.read(localPreferencesProvider).setOnboardingComplete(false);
    state = const AuthState(isAuthenticated: false, onboardingComplete: false);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final onboardingControllerProvider = Provider(
  (ref) => ref.read(authControllerProvider),
);

final dashboardControllerProvider = FutureProvider<DashboardData>((ref) {
  final date = AppDateUtils.apiDate(DateTime.now());
  return ref.read(dashboardRepositoryProvider).load(date);
});

class FoodEntryState {
  const FoodEntryState({
    this.mealType = MealType.lunch,
    this.text = '',
    this.parsed = const [],
    this.preview,
    this.lowConfidence = false,
  });

  final MealType mealType;
  final String text;
  final List<ParsedFoodItem> parsed;
  final NutritionPreview? preview;
  final bool lowConfidence;

  FoodEntryState copyWith({
    MealType? mealType,
    String? text,
    List<ParsedFoodItem>? parsed,
    NutritionPreview? preview,
    bool? lowConfidence,
  }) => FoodEntryState(
    mealType: mealType ?? this.mealType,
    text: text ?? this.text,
    parsed: parsed ?? this.parsed,
    preview: preview ?? this.preview,
    lowConfidence: lowConfidence ?? this.lowConfidence,
  );
}

class FoodEntryController extends Notifier<AsyncValue<FoodEntryState>> {
  late final FoodEntryRepository _repository;

  @override
  AsyncValue<FoodEntryState> build() {
    _repository = ref.read(foodEntryRepositoryProvider);
    return const AsyncData(FoodEntryState());
  }

  void setMealType(MealType type) {
    final current = state.value ?? const FoodEntryState();
    state = AsyncData(current.copyWith(mealType: type));
  }

  Future<FoodEntryState> analyze(String text) async {
    final current = state.value ?? const FoodEntryState();
    state = const AsyncLoading();
    try {
      final parsed = await _repository.parseFood(text);
      final preview = parsed.isEmpty ? null : await _repository.preview(parsed);
      final lowConfidence =
          parsed.isEmpty ||
          preview == null ||
          preview.items.isEmpty ||
          preview.items.every(
            (item) => item.calories <= 0 || item.confidence <= 0,
          );
      final next = current.copyWith(
        text: text,
        parsed: parsed,
        preview: preview,
        lowConfidence: lowConfidence,
      );
      state = AsyncData(next);
      return next;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final foodEntryControllerProvider =
    NotifierProvider<FoodEntryController, AsyncValue<FoodEntryState>>(
      FoodEntryController.new,
    );

class MealController extends Notifier<AsyncValue<void>> {
  late final MealRepository _repository;

  @override
  AsyncValue<void> build() {
    _repository = ref.read(mealRepositoryProvider);
    return const AsyncData(null);
  }

  Future<void> save({
    required MealType mealType,
    required List<NutritionPreviewItem> items,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () async => _repository.saveMeal(
        date: AppDateUtils.apiDate(DateTime.now()),
        mealType: mealType,
        items: items,
      ),
    );
    state = result.hasError
        ? AsyncError(result.error!, result.stackTrace ?? StackTrace.current)
        : const AsyncData(null);
  }
}

final mealControllerProvider =
    NotifierProvider<MealController, AsyncValue<void>>(MealController.new);

final mealsForDateProvider = FutureProvider.family<List<MealLog>, String>((
  ref,
  date,
) {
  return ref.read(mealRepositoryProvider).mealsForDate(date);
});

final historyControllerProvider = FutureProvider<HistoryData>((ref) async {
  final today = DateTime.now();
  final from = AppDateUtils.apiDate(today.subtract(const Duration(days: 6)));
  final to = AppDateUtils.apiDate(today);
  return ref.read(historyRepositoryProvider).load(from: from, to: to);
});

final foodsControllerProvider = FutureProvider.family<List<PublicFood>, String>(
  (ref, query) {
    return ref.read(foodsRepositoryProvider).search(query);
  },
);

final profileControllerProvider = FutureProvider<UserProfile>((ref) {
  return ref.read(profileRepositoryProvider).getProfile();
});
