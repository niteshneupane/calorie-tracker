part of '../../../../app.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(height: 18, color: AppColors.surfaceTint),
          const SizedBox(height: 12),
          Container(height: 70, color: AppColors.surfaceTint),
        ],
      ),
    );
  }
}
