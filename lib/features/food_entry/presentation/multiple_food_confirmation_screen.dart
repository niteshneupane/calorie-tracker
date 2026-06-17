part of '../../../app.dart';

class MultipleFoodConfirmationScreen extends ConsumerWidget {
  const MultipleFoodConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(foodEntryControllerProvider).value;
    final items = entry?.preview?.items ?? const <NutritionPreviewItem>[];
    if (entry == null || items.isEmpty) {
      return AppShell(
        currentIndex: 0,
        showBottomNav: false,
        child: AppEmptyState(
          title: 'No foods to confirm',
          message: 'Add food from the dashboard to create real meal logs.',
          buttonLabel: 'Add Food',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, RouteNames.addFood),
        ),
      );
    }
    final total = items.fold<double>(0, (sum, item) => sum + item.calories);
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: HeaderRow(
              title: 'Confirm foods',
              subtitle: 'Review each parsed item',
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) => AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(items[index].name ?? items[index].inputName),
                  subtitle: Text(
                    '${items[index].grams?.round() ?? 0} g portion',
                  ),
                  trailing: Text(
                    AppFormatters.kcal(items[index].calories, estimated: true),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: AppTextStyles.cardTitle),
                        Text(AppFormatters.kcal(total, estimated: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Confirm & Save',
                      onPressed: () async {
                        await ref
                            .read(mealControllerProvider.notifier)
                            .save(mealType: entry.mealType, items: items);
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.mealSaved,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
