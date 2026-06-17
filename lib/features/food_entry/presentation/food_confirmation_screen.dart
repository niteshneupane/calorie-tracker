part of '../../../app.dart';

class FoodConfirmationScreen extends ConsumerWidget {
  const FoodConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(foodEntryControllerProvider).value;
    final item = entry?.preview?.items.firstOrNull;
    if (entry == null || item == null) {
      return AppShell(
        currentIndex: 0,
        showBottomNav: false,
        child: AppEmptyState(
          title: 'No food to confirm',
          message: 'Add food from the dashboard to create a real meal log.',
          buttonLabel: 'Add Food',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, RouteNames.addFood),
        ),
      );
    }
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HeaderRow(
            title: 'Confirm food',
            subtitle: 'Review the estimate',
          ),
          const SizedBox(height: 14),
          FoodConfirmationCard(item: item),
          const SizedBox(height: 14),
          PortionSelector(grams: item.grams ?? 350),
          const SizedBox(height: 20),
          AppButton(
            label: 'Confirm & Save',
            onPressed: () async {
              await ref
                  .read(mealControllerProvider.notifier)
                  .save(mealType: entry.mealType, items: [item]);
              ref.invalidate(dashboardControllerProvider);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, RouteNames.mealSaved);
              }
            },
          ),
        ],
      ),
    );
  }
}
