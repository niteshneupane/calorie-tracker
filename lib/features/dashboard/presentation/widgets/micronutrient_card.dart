part of '../../../../app.dart';

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
