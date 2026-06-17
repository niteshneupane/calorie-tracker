part of '../../../app.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);
    return AppShell(
      currentIndex: 1,
      child: history.when(
        loading: () => const AppLoading(label: 'Loading history...'),
        error: (error, stackTrace) => AppErrorView(
          message: error.toString(),
          stackTrace: stackTrace.toString(),
          onRetry: () => ref.invalidate(historyControllerProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(historyControllerProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const HeaderRow(title: 'History', subtitle: 'Weekly intake'),
              const SizedBox(height: 16),
              WeeklyCalendarStrip(items: data.items),
              const SizedBox(height: 14),
              WeeklyTrendChart(items: data.items),
              const SizedBox(height: 14),
              ...data.items.map(
                (day) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DailyHistoryCard(
                    day: day,
                    onTap: day.mealCount == 0
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryDayDetailScreen(
                                date: day.date,
                                calories: day.calories,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
