part of '../../../../app.dart';

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
