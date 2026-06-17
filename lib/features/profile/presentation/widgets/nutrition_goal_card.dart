part of '../../../../app.dart';

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
