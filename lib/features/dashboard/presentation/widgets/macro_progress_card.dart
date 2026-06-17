part of '../../../../app.dart';

class MacroProgressGrid extends StatelessWidget {
  const MacroProgressGrid({super.key, required this.summary});
  final DailySummaryResponse summary;

  @override
  Widget build(BuildContext context) {
    final consumed = summary.consumed;
    final goal = summary.goal;
    if (goal == null) {
      return const AppCard(
        child: Text('No macro targets set', style: AppTextStyles.muted),
      );
    }
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
