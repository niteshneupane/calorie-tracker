part of '../../../../app.dart';

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
