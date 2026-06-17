part of '../../../app.dart';

class HistoryDayDetailScreen extends ConsumerWidget {
  const HistoryDayDetailScreen({
    super.key,
    required this.date,
    required this.calories,
  });

  final String date;
  final double calories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsForDateProvider(date));
    return AppShell(
      currentIndex: 1,
      showBottomNav: false,
      child: meals.when(
        loading: () => const AppLoading(label: 'Loading meals...'),
        error: (error, stackTrace) => AppErrorView(
          message: error.toString(),
          stackTrace: stackTrace.toString(),
          onRetry: () => ref.invalidate(mealsForDateProvider(date)),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            HeaderRow(title: date, subtitle: '${calories.round()} kcal logged'),
            const SizedBox(height: 16),
            if (items.isEmpty)
              AppEmptyState(
                title: 'No meals found',
                message: 'This day has no meal logs in the database.',
                buttonLabel: 'Back',
                onPressed: () => Navigator.pop(context),
              )
            else
              ...items.map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HistoryMealCard(meal: meal),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HistoryMealCard extends StatelessWidget {
  const HistoryMealCard({super.key, required this.meal});

  final MealLog meal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal.mealType.toUpperCase(), style: AppTextStyles.cardTitle),
              Text(AppFormatters.kcal(meal.calories)),
            ],
          ),
          if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(meal.notes!, style: AppTextStyles.muted),
          ],
          const SizedBox(height: 12),
          ...meal.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name ?? item.inputName),
                        Text(
                          '${item.grams?.round() ?? 0} g • '
                          'P ${item.proteinG.round()} g '
                          'C ${item.carbsG.round()} g '
                          'F ${item.fatG.round()} g',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
                  ),
                  Text(AppFormatters.kcal(item.calories)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
