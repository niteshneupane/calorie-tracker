part of '../../../app.dart';

class TodayDashboardScreen extends ConsumerWidget {
  const TodayDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardControllerProvider);
    return AppShell(
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.addFood),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Food'),
      ),
      child: data.when(
        loading: () => const AppLoading(label: 'Loading today...'),
        error: (error, stackTrace) => AppErrorView(
          stackTrace: stackTrace.toString(),
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardControllerProvider),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardControllerProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              HeaderRow(
                title: 'Today',
                subtitle: AppDateUtils.displayDate(DateTime.now()),
                trailing: IconButton.filledTonal(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.profile),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              if (dashboard.meals.isEmpty)
                EmptyDashboardState(
                  onAdd: () => Navigator.pushNamed(context, RouteNames.addFood),
                )
              else ...[
                CalorieProgressCard(summary: dashboard.summary),
                const SizedBox(height: 14),
                MacroProgressGrid(summary: dashboard.summary),
                const SizedBox(height: 14),
                MicronutrientGrid(values: dashboard.summary.consumed),
                const SizedBox(height: 14),
                MealSections(meals: dashboard.meals),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
