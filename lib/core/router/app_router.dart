import 'package:flutter/material.dart';

import '../../app.dart';
import 'route_names.dart';

Map<String, WidgetBuilder> buildAppRoutes() => {
  RouteNames.splash: (_) => const SplashScreen(),
  RouteNames.signIn: (_) => const SignInScreen(),
  RouteNames.onboardingProfile: (_) => const OnboardingProfileScreen(),
  RouteNames.onboardingGoals: (_) => const OnboardingGoalPreviewScreen(),
  RouteNames.today: (_) => const TodayDashboardScreen(),
  RouteNames.addFood: (_) => const AddFoodScreen(),
  RouteNames.foodAnalyzing: (_) => const FoodAnalyzingScreen(),
  RouteNames.foodConfirmation: (_) => const FoodConfirmationScreen(),
  RouteNames.multipleFoodConfirmation: (_) =>
      const MultipleFoodConfirmationScreen(),
  RouteNames.mealSaved: (_) => const MealSavedScreen(),
  RouteNames.history: (_) => const HistoryScreen(),
  RouteNames.foods: (_) => const FoodsScreen(),
  RouteNames.customFood: (_) => const CustomFoodScreen(),
  RouteNames.profile: (_) => const ProfileScreen(),
};
