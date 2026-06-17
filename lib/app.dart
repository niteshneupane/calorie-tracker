import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_utils.dart';
import 'core/utils/formatters.dart';
import 'features/app_providers.dart';
import 'features/food_entry/domain/nutrition_models.dart';
import 'features/mock_data.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/app_card.dart';
import 'shared/widgets/app_empty_state.dart';
import 'shared/widgets/app_error_view.dart';
import 'shared/widgets/app_loading.dart';
import 'shared/widgets/app_text_field.dart';

class AaharLogApp extends ConsumerWidget {
  const AaharLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: buildAppRoutes(),
      initialRoute: RouteNames.splash,
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      final route = !auth.isAuthenticated
          ? RouteNames.signIn
          : auth.onboardingComplete
          ? RouteNames.today
          : RouteNames.onboardingProfile;
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, size: 76, color: AppColors.primary),
              SizedBox(height: 18),
              Text(AppConstants.appName, style: AppTextStyles.title),
              SizedBox(height: 6),
              Text(AppConstants.tagline, style: AppTextStyles.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 52,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          const Text(AppConstants.appName, style: AppTextStyles.title),
          const SizedBox(height: 8),
          const Text(
            'Log meals in your own words.',
            style: TextStyle(fontSize: 18, color: AppColors.muted),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signInMock();
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.onboardingProfile,
                );
              }
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Continue with Email',
            icon: Icons.mail_outline_rounded,
            secondary: true,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signInMock();
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.onboardingProfile,
                );
              }
            },
          ),
          const SizedBox(height: 18),
          Text(
            !AppConfig.hasClerkPublishableKey
                ? 'Your food logs stay private. Add CLERK_PUBLISHABLE_KEY for real Clerk sign-in.'
                : 'Your food logs stay private.',
            style: AppTextStyles.muted,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final age = TextEditingController(text: '25');
  final height = TextEditingController(text: '170');
  final weight = TextEditingController(text: '70');
  String sex = 'male';
  String activity = 'moderate';
  String goal = 'maintain';

  @override
  void dispose() {
    age.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListView(
        children: [
          const StepLabel(text: 'Step 1 of 2'),
          const SizedBox(height: 8),
          const Text('Tell us about you', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          AppTextField(
            controller: age,
            hintText: '25',
            labelText: 'Age',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SegmentedField(
            label: 'Sex',
            value: sex,
            values: const ['male', 'female', 'other'],
            onChanged: (value) => setState(() => sex = value),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: height,
            hintText: '170',
            labelText: 'Height (cm)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: weight,
            hintText: '70',
            labelText: 'Weight (kg)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SegmentedField(
            label: 'Activity level',
            value: activity,
            values: const ['light', 'moderate', 'active'],
            onChanged: (value) => setState(() => activity = value),
          ),
          const SizedBox(height: 12),
          SegmentedField(
            label: 'Goal',
            value: goal,
            values: const ['lose weight', 'maintain', 'gain muscle'],
            onChanged: (value) => setState(() => goal = value),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Continue',
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.onboardingGoals),
          ),
        ],
      ),
    );
  }
}

class OnboardingGoalPreviewScreen extends ConsumerStatefulWidget {
  const OnboardingGoalPreviewScreen({super.key});

  @override
  ConsumerState<OnboardingGoalPreviewScreen> createState() =>
      _OnboardingGoalPreviewScreenState();
}

class _OnboardingGoalPreviewScreenState
    extends ConsumerState<OnboardingGoalPreviewScreen> {
  final calories = TextEditingController(text: '2200');
  final protein = TextEditingController(text: '120');
  final carbs = TextEditingController(text: '250');
  final fat = TextEditingController(text: '70');

  @override
  void dispose() {
    calories.dispose();
    protein.dispose();
    carbs.dispose();
    fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListView(
        children: [
          const StepLabel(text: 'Step 2 of 2'),
          const SizedBox(height: 8),
          const Text('Daily targets', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          AppTextField(
            controller: calories,
            hintText: '2200',
            labelText: 'Calories',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: protein,
            hintText: '120',
            labelText: 'Protein (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: carbs,
            hintText: '250',
            labelText: 'Carbs (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: fat,
            hintText: '70',
            labelText: 'Fat (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Start Tracking',
            onPressed: () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .completeOnboarding();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.today,
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class TodayDashboardScreen extends ConsumerWidget {
  const TodayDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardControllerProvider);
    return AppShell(
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.addFood),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Food'),
      ),
      child: data.when(
        loading: () => const AppLoading(label: 'Loading today...'),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardControllerProvider),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardControllerProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              HeaderRow(
                title: 'Today',
                subtitle: AppDateUtils.displayDate(DateTime.now()),
                trailing: IconButton.filledTonal(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.profile),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              if (dashboard.meals.isEmpty)
                EmptyDashboardState(
                  onAdd: () => Navigator.pushNamed(context, RouteNames.addFood),
                )
              else ...[
                CalorieProgressCard(summary: dashboard.summary),
                const SizedBox(height: 14),
                MacroProgressGrid(summary: dashboard.summary),
                const SizedBox(height: 14),
                MicronutrientGrid(values: dashboard.summary.consumed),
                const SizedBox(height: 14),
                MealSections(meals: dashboard.meals),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> analyze() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pushNamed(context, RouteNames.foodAnalyzing);
    final result = await ref
        .read(foodEntryControllerProvider.notifier)
        .analyze(text);
    if (!mounted) return;
    Navigator.pop(context);
    if (result.lowConfidence) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const LowConfidenceState(),
      );
      return;
    }
    final route = (result.preview?.items.length ?? 0) > 1
        ? RouteNames.multipleFoodConfirmation
        : RouteNames.foodConfirmation;
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(foodEntryControllerProvider).value ?? const FoodEntryState();
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HeaderRow(
            title: 'Add food',
            subtitle: "Type what you ate. We'll estimate it.",
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: controller,
            hintText: 'e.g. chowmin 1 plate, 2 boiled eggs',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          MealTypeSelector(
            selected: state.mealType,
            onSelected: ref
                .read(foodEntryControllerProvider.notifier)
                .setMealType,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.quickEntries
                .map(
                  (entry) => ActionChip(
                    label: Text(entry),
                    onPressed: () => controller.text = entry,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Analyze food', onPressed: analyze),
          const SizedBox(height: 12),
          AppButton(
            label: 'Search manually',
            secondary: true,
            onPressed: () => Navigator.pushNamed(context, RouteNames.foods),
          ),
        ],
      ),
    );
  }
}

class FoodAnalyzingScreen extends StatelessWidget {
  const FoodAnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Analyzing your food...', style: AppTextStyles.heading),
              SizedBox(height: 6),
              Text(
                'Estimating portion and nutrients',
                style: AppTextStyles.muted,
              ),
              SizedBox(height: 24),
              SkeletonCard(),
              SizedBox(height: 12),
              SkeletonCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodConfirmationScreen extends ConsumerWidget {
  const FoodConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(foodEntryControllerProvider).value;
    final item = entry?.preview?.items.firstOrNull ?? MockData.previewItem;
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HeaderRow(
            title: 'Confirm food',
            subtitle: 'Review the estimate',
          ),
          const SizedBox(height: 14),
          FoodConfirmationCard(item: item),
          const SizedBox(height: 14),
          PortionSelector(grams: item.grams ?? 350),
          const SizedBox(height: 14),
          VariantSelector(
            variants:
                entry?.parsed.firstOrNull?.possibleVariants ??
                const [
                  'Vegetable Chowmein',
                  'Chicken Chowmein',
                  'Egg Chowmein',
                ],
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Confirm & Save',
            onPressed: () async {
              await ref
                  .read(mealControllerProvider.notifier)
                  .save(
                    mealType: entry?.mealType ?? MealType.lunch,
                    items: [item],
                  );
              ref.invalidate(dashboardControllerProvider);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, RouteNames.mealSaved);
              }
            },
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Edit Manually', secondary: true, onPressed: () {}),
        ],
      ),
    );
  }
}

class MultipleFoodConfirmationScreen extends ConsumerWidget {
  const MultipleFoodConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(foodEntryControllerProvider).value;
    final items =
        entry?.preview?.items ??
        const [MockData.previewItem, MockData.previewItem];
    final total = items.fold<double>(0, (sum, item) => sum + item.calories);
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: HeaderRow(
              title: 'Confirm foods',
              subtitle: 'Review each parsed item',
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) => AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(items[index].name ?? items[index].inputName),
                  subtitle: Text(
                    '${items[index].grams?.round() ?? 0} g portion',
                  ),
                  trailing: Text(
                    AppFormatters.kcal(items[index].calories, estimated: true),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: AppTextStyles.cardTitle),
                        Text(AppFormatters.kcal(total, estimated: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Confirm & Save',
                      onPressed: () async {
                        await ref
                            .read(mealControllerProvider.notifier)
                            .save(
                              mealType: entry?.mealType ?? MealType.lunch,
                              items: items,
                            );
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.mealSaved,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealSavedScreen extends StatelessWidget {
  const MealSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 86,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Text('Meal saved', style: AppTextStyles.heading),
          const SizedBox(height: 8),
          const Text('1,450 / 2,200 kcal', style: AppTextStyles.muted),
          const SizedBox(height: 28),
          AppButton(
            label: 'Back to Today',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.today,
              (_) => false,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Add another food',
            secondary: true,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, RouteNames.addFood),
          ),
        ],
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meal = MockData.meals.first;
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          HeaderRow(title: meal.mealType.toUpperCase(), subtitle: meal.date),
          const SizedBox(height: 14),
          ...meal.items.map((item) => FoodConfirmationCard(item: item)),
          const SizedBox(height: 14),
          NutritionPreviewCard(values: MockData.previewItem),
          const SizedBox(height: 20),
          AppButton(label: 'Edit meal', secondary: true, onPressed: () {}),
          const SizedBox(height: 12),
          AppButton(label: 'Delete meal', secondary: true, onPressed: () {}),
        ],
      ),
    );
  }
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppShell(
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HeaderRow(title: 'History', subtitle: 'Weekly intake'),
          const SizedBox(height: 16),
          const WeeklyCalendarStrip(),
          const SizedBox(height: 14),
          const WeeklyTrendChart(),
          const SizedBox(height: 14),
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DailyHistoryCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodsScreen extends ConsumerStatefulWidget {
  const FoodsScreen({super.key});

  @override
  ConsumerState<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends ConsumerState<FoodsScreen> {
  final search = TextEditingController();
  String query = '';
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodsControllerProvider(query));
    return AppShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          HeaderRow(
            title: 'Foods',
            subtitle: 'Search and manage foods',
            trailing: IconButton.filled(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.customFood),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: search,
            decoration: const InputDecoration(
              hintText: 'Search foods',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 300), () {
                setState(() => query = value);
              });
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All Foods')),
              ButtonSegment(value: 'mine', label: Text('My Foods')),
            ],
            selected: const {'all'},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(height: 14),
          foods.when(
            loading: () => const AppLoading(label: 'Searching...'),
            error: (error, _) => Text(error.toString()),
            data: (items) => Column(
              children: [
                ...items.map(
                  (food) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FoodListCard(food: food),
                  ),
                ),
                AppButton(
                  label: 'Add Custom Food',
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.customFood),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFoodScreen extends StatefulWidget {
  const CustomFoodScreen({super.key});

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final fields = List.generate(13, (_) => TextEditingController());

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      'Food name',
      'Serving size',
      'Grams',
      'Calories',
      'Protein',
      'Carbs',
      'Fat',
      'Fiber',
      'Sugar',
      'Sodium',
      'Calcium',
      'Iron',
      'Potassium',
    ];
    return AppShell(
      currentIndex: 2,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HeaderRow(
            title: 'Custom food',
            subtitle: 'Add nutrition values',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < labels.length; i++) ...[
            AppTextField(
              controller: fields[i],
              hintText: labels[i],
              labelText: labels[i],
              keyboardType: i > 1 ? TextInputType.number : TextInputType.text,
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Save Custom Food',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return AppShell(
      currentIndex: 3,
      child: profile.when(
        loading: () => const AppLoading(),
        error: (error, _) => Text(error.toString()),
        data: (user) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'AaharLog user',
                          style: AppTextStyles.cardTitle,
                        ),
                        Text(
                          user.email ?? 'Signed in with Clerk',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NutritionGoalCard(user: user),
            const SizedBox(height: 14),
            SettingsListTile(icon: Icons.edit_rounded, label: 'Edit profile'),
            SettingsListTile(
              icon: Icons.flag_rounded,
              label: 'Nutrition goals',
            ),
            SettingsListTile(
              icon: Icons.lock_outline_rounded,
              label: 'Privacy',
            ),
            SettingsListTile(
              icon: Icons.download_rounded,
              label: 'Export data',
            ),
            SettingsListTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.signIn,
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showBottomNav = true,
    this.floatingActionButton,
  });

  final Widget child;
  final int currentIndex;
  final bool showBottomNav;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                final route = [
                  RouteNames.today,
                  RouteNames.history,
                  RouteNames.foods,
                  RouteNames.profile,
                ][index];
                if (index != currentIndex) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today_rounded),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Foods',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.muted),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class StepLabel extends StatelessWidget {
  const StepLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.primary));
  }
}

class SegmentedField extends StatelessWidget {
  const SegmentedField({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.muted),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (item) => ChoiceChip(
                  label: Text(item),
                  selected: item == value,
                  onSelected: (_) => onChanged(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class CalorieProgressCard extends StatelessWidget {
  const CalorieProgressCard({super.key, required this.summary});

  final DailySummaryResponse summary;

  @override
  Widget build(BuildContext context) {
    final goal = summary.goal?.calories ?? 2200;
    final consumed = summary.consumed.calories;
    final remaining = math.max(0, goal - consumed);
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            height: 136,
            width: 136,
            child: CustomPaint(
              painter: CalorieRingPainter(
                progress: (consumed / goal).clamp(0, 1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      consumed.round().toString(),
                      style: AppTextStyles.heading,
                    ),
                    const Text('kcal', style: AppTextStyles.muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${consumed.round()} / ${goal.round()} kcal',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  '${remaining.round()} kcal remaining',
                  style: AppTextStyles.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CalorieRingPainter extends CustomPainter {
  CalorieRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final rect = Offset.zero & size;
    final background = Paint()
      ..color = AppColors.surfaceTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final foreground = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(stroke),
      -math.pi / 2,
      math.pi * 2,
      false,
      background,
    );
    canvas.drawArc(
      rect.deflate(stroke),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class MacroProgressGrid extends StatelessWidget {
  const MacroProgressGrid({super.key, required this.summary});
  final DailySummaryResponse summary;

  @override
  Widget build(BuildContext context) {
    final goal = summary.goal ?? MockData.goal;
    final consumed = summary.consumed;
    return Column(
      children: [
        MacroProgressCard(
          label: 'Protein',
          value: consumed.proteinG,
          goal: goal.proteinG,
        ),
        const SizedBox(height: 10),
        MacroProgressCard(
          label: 'Carbs',
          value: consumed.carbsG,
          goal: goal.carbsG,
        ),
        const SizedBox(height: 10),
        MacroProgressCard(label: 'Fat', value: consumed.fatG, goal: goal.fatG),
      ],
    );
  }
}

class MacroProgressCard extends StatelessWidget {
  const MacroProgressCard({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
  });

  final String label;
  final double value;
  final double goal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.cardTitle),
              Text(
                '${value.round()} / ${goal.round()} g',
                style: AppTextStyles.muted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: (value / goal).clamp(0, 1)),
        ],
      ),
    );
  }
}

class MicronutrientGrid extends StatelessWidget {
  const MicronutrientGrid({super.key, required this.values});
  final NutritionValues values;

  @override
  Widget build(BuildContext context) {
    final micros = [
      ('Fiber', '${values.fiberG.round()} g'),
      ('Sodium', AppFormatters.mg(values.sodiumMg)),
      ('Calcium', AppFormatters.mg(values.calciumMg)),
      ('Iron', '${values.ironMg.toStringAsFixed(1)} mg'),
      ('Potassium', AppFormatters.mg(values.potassiumMg)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: micros.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(micros[index].$1, style: AppTextStyles.muted),
            const Spacer(),
            Text(micros[index].$2, style: AppTextStyles.cardTitle),
          ],
        ),
      ),
    );
  }
}

class MealSections extends StatelessWidget {
  const MealSections({super.key, required this.meals});
  final List<MealLog> meals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Meals', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        for (final type in MealType.values.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(type.label, style: AppTextStyles.cardTitle),
                subtitle: Text(
                  type == MealType.lunch
                      ? 'Vegetable Chowmein'
                      : 'No meals logged',
                ),
                trailing: Text(type == MealType.lunch ? '~525 kcal' : ''),
                onTap: type == MealType.lunch
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MealDetailScreen(),
                        ),
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyDashboardState extends StatelessWidget {
  const EmptyDashboardState({super.key, required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppEmptyState(
            title: 'No meals logged yet',
            message: 'Start by typing what you ate.',
            buttonLabel: 'Add Food',
            onPressed: onAdd,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.quickEntries
                .map((entry) => Chip(label: Text(entry)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class MealTypeSelector extends StatelessWidget {
  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MealType selected;
  final ValueChanged<MealType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: MealType.values
          .take(4)
          .map(
            (type) => ChoiceChip(
              label: Text(type.label),
              selected: selected == type,
              onSelected: (_) => onSelected(type),
            ),
          )
          .toList(),
    );
  }
}

class FoodConfirmationCard extends StatelessWidget {
  const FoodConfirmationCard({super.key, required this.item});
  final NutritionPreviewItem item;

  @override
  Widget build(BuildContext context) {
    final grams = item.grams?.round() ?? 350;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name ?? item.inputName,
                  style: AppTextStyles.heading,
                ),
              ),
              const Chip(label: Text('Estimated')),
            ],
          ),
          const SizedBox(height: 4),
          Text('Medium confidence', style: AppTextStyles.muted),
          const SizedBox(height: 12),
          Text('1 medium plate • $grams g'),
          const SizedBox(height: 10),
          Text(
            'Estimated from $grams g medium plate',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 14),
          NutritionPreviewCard(values: item),
        ],
      ),
    );
  }
}

class NutritionPreviewCard extends StatelessWidget {
  const NutritionPreviewCard({super.key, required this.values});
  final NutritionValues values;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Calories', AppFormatters.kcal(values.calories, estimated: true)),
      ('Protein', AppFormatters.grams(values.proteinG)),
      ('Carbs', AppFormatters.grams(values.carbsG)),
      ('Fat', AppFormatters.grams(values.fatG)),
      ('Fiber', AppFormatters.grams(values.fiberG)),
      ('Sodium', AppFormatters.mg(values.sodiumMg)),
      ('Calcium', AppFormatters.mg(values.calciumMg)),
      ('Iron', '${values.ironMg.toStringAsFixed(1)} mg'),
      ('Potassium', AppFormatters.mg(values.potassiumMg)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rows
          .map(
            (row) => Container(
              width: 134,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.$1, style: AppTextStyles.muted),
                  const SizedBox(height: 4),
                  Text(row.$2, style: AppTextStyles.cardTitle),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class PortionSelector extends StatelessWidget {
  const PortionSelector({super.key, required this.grams});
  final double grams;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portion', style: AppTextStyles.cardTitle),
          const SizedBox(height: 10),
          SegmentedField(
            label: '',
            value: 'Medium plate - 350 g',
            values: const [
              'Small plate - 250 g',
              'Medium plate - 350 g',
              'Large plate - 500 g',
              'Custom',
            ],
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

class VariantSelector extends StatelessWidget {
  const VariantSelector({super.key, required this.variants});
  final List<String> variants;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SegmentedField(
        label: 'Variant',
        value: variants.first,
        values: variants,
        onChanged: (_) {},
      ),
    );
  }
}

class LowConfidenceState extends StatelessWidget {
  const LowConfidenceState({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We need a bit more detail',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your meal was too vague to estimate accurately.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 12),
            const Text('Example: "normal lunch"', style: AppTextStyles.muted),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('dal bhat')),
                Chip(label: Text('rice and curry')),
                Chip(label: Text('noodles')),
                Chip(label: Text('custom food')),
              ],
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Try again',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Search manually',
              secondary: true,
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, RouteNames.foods),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(height: 18, color: AppColors.surfaceTint),
          const SizedBox(height: 12),
          Container(height: 70, color: AppColors.surfaceTint),
        ],
      ),
    );
  }
}

class WeeklyCalendarStrip extends StatelessWidget {
  const WeeklyCalendarStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        7,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: index == 3 ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]),
                Text('${15 + index}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeeklyTrendChart extends StatelessWidget {
  const WeeklyTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: AppColors.primary,
                barWidth: 4,
                spots: const [
                  FlSpot(0, 1200),
                  FlSpot(1, 1600),
                  FlSpot(2, 1450),
                  FlSpot(3, 1900),
                  FlSpot(4, 1720),
                  FlSpot(5, 1500),
                  FlSpot(6, 1800),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyHistoryCard extends StatelessWidget {
  const DailyHistoryCard({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('June ${17 - index}, 2026'),
        subtitle: const Text('Protein 62 g • 3 meals'),
        trailing: Text('${1450 - index * 80} kcal'),
      ),
    );
  }
}

class FoodListCard extends StatelessWidget {
  const FoodListCard({super.key, required this.food});
  final PublicFood food;

  @override
  Widget build(BuildContext context) {
    final grams = food.defaultServingGrams ?? 100;
    final calories = food.caloriesPer100g * grams / 100;
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(food.name, style: AppTextStyles.cardTitle),
        subtitle: Text(
          '${food.defaultServingName ?? '100 g'} • '
          'P ${food.proteinPer100g}g C ${food.carbsPer100g}g F ${food.fatPer100g}g per 100g',
        ),
        trailing: Text(AppFormatters.kcal(calories)),
      ),
    );
  }
}

class NutritionGoalCard extends StatelessWidget {
  const NutritionGoalCard({super.key, required this.user});
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.goal ?? 'maintain', style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          Text(
            '${user.dailyCalorieGoal?.round() ?? 2200} kcal • '
            'P ${user.proteinGoalG?.round() ?? 120} g • '
            'C ${user.carbsGoalG?.round() ?? 250} g • '
            'F ${user.fatGoalG?.round() ?? 70} g',
          ),
          const SizedBox(height: 8),
          Text(
            '${user.heightCm?.round() ?? 170} cm • '
            '${user.weightKg?.round() ?? 70} kg • '
            '${user.activityLevel ?? 'moderate'}',
            style: AppTextStyles.muted,
          ),
        ],
      ),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(label),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
