part of '../../../../app.dart';

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
