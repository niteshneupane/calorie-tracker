import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import 'features/history/data/history_repository.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/app_card.dart';
import 'shared/widgets/app_empty_state.dart';
import 'shared/widgets/app_error_view.dart';
import 'shared/widgets/app_loading.dart';
import 'shared/widgets/app_text_field.dart';

part 'features/auth/presentation/splash_screen.dart';
part 'features/auth/presentation/sign_in_screen.dart';
part 'features/onboarding/presentation/onboarding_profile_screen.dart';
part 'features/onboarding/presentation/onboarding_goal_preview_screen.dart';
part 'features/dashboard/presentation/today_dashboard_screen.dart';
part 'features/dashboard/presentation/widgets/calorie_progress_card.dart';
part 'features/dashboard/presentation/widgets/macro_progress_card.dart';
part 'features/dashboard/presentation/widgets/micronutrient_card.dart';
part 'features/dashboard/presentation/widgets/meal_section_card.dart';
part 'features/dashboard/presentation/widgets/empty_dashboard_state.dart';
part 'features/food_entry/presentation/add_food_screen.dart';
part 'features/food_entry/presentation/food_analyzing_screen.dart';
part 'features/food_entry/presentation/food_confirmation_screen.dart';
part 'features/food_entry/presentation/multiple_food_confirmation_screen.dart';
part 'features/food_entry/presentation/meal_saved_screen.dart';
part 'features/food_entry/presentation/widgets/meal_type_selector.dart';
part 'features/food_entry/presentation/widgets/food_confirmation_card.dart';
part 'features/food_entry/presentation/widgets/nutrition_preview_card.dart';
part 'features/food_entry/presentation/widgets/portion_selector.dart';
part 'features/food_entry/presentation/widgets/low_confidence_state.dart';
part 'features/food_entry/presentation/widgets/food_entry_helpers.dart';
part 'features/history/presentation/history_screen.dart';
part 'features/history/presentation/history_day_detail_screen.dart';
part 'features/history/presentation/widgets/weekly_calendar_strip.dart';
part 'features/history/presentation/widgets/weekly_trend_chart.dart';
part 'features/history/presentation/widgets/daily_history_card.dart';
part 'features/foods/presentation/foods_screen.dart';
part 'features/foods/presentation/widgets/food_list_card.dart';
part 'features/profile/presentation/profile_screen.dart';
part 'features/profile/presentation/widgets/nutrition_goal_card.dart';
part 'features/profile/presentation/widgets/settings_list_tile.dart';
part 'shared/widgets/app_shell.dart';
part 'shared/widgets/screen_helpers.dart';

class MyCalorieApp extends ConsumerWidget {
  const MyCalorieApp({super.key});

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
