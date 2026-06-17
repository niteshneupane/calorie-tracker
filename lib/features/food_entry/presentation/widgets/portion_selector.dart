part of '../../../../app.dart';

class PortionSelector extends StatelessWidget {
  const PortionSelector({super.key, required this.grams});
  final double grams;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portion', style: AppTextStyles.cardTitle),
          const SizedBox(height: 10),
          Text(
            '${grams.round()} g estimated from the parsed meal text',
            style: AppTextStyles.muted,
          ),
        ],
      ),
    );
  }
}
