part of '../../../../app.dart';

class WeeklyCalendarStrip extends StatelessWidget {
  const WeeklyCalendarStrip({super.key, required this.items});

  final List<HistoryDay> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final item = items.reversed.toList()[index];
        final date = DateTime.tryParse(item.date);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: index == 3 ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(date == null ? '-' : ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1]),
                Text(date == null ? item.date.substring(8) : '${date.day}'),
              ],
            ),
          ),
        );
      }),
    );
  }
}
