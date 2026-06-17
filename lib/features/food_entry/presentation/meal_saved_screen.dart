part of '../../../app.dart';

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
