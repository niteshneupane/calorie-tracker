part of '../../../../app.dart';

class MealSections extends StatelessWidget {
  const MealSections({super.key, required this.meals});
  final List<MealLog> meals;

  @override
  Widget build(BuildContext context) {
    final mealsByType = <MealType, List<MealLog>>{
      for (final type in MealType.values) type: [],
    };
    for (final meal in meals) {
      final type = MealType.values.firstWhere(
        (value) => value.name == meal.mealType,
        orElse: () => MealType.other,
      );
      mealsByType[type]!.add(meal);
    }

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
                subtitle: Text(_mealNames(mealsByType[type]!)),
                trailing: mealsByType[type]!.isEmpty
                    ? null
                    : Text(
                        AppFormatters.kcal(_mealCalories(mealsByType[type]!)),
                      ),
              ),
            ),
          ),
      ],
    );
  }

  String _mealNames(List<MealLog> meals) {
    if (meals.isEmpty) return 'No meals logged';
    return meals
        .expand((meal) => meal.items)
        .map((item) => item.name ?? item.inputName)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
  }

  double _mealCalories(List<MealLog> meals) =>
      meals.fold(0, (total, meal) => total + meal.calories);
}
