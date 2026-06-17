part of '../../../../app.dart';

class EmptyDashboardState extends StatelessWidget {
  const EmptyDashboardState({super.key, required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppEmptyState(
            title: 'No meals logged yet',
            message: 'Start by typing what you ate.',
            buttonLabel: 'Add Food',
            onPressed: onAdd,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.quickEntries
                .map((entry) => Chip(label: Text(entry)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
