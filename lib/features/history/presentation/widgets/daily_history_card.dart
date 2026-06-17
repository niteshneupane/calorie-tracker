part of '../../../../app.dart';

class DailyHistoryCard extends StatelessWidget {
  const DailyHistoryCard({super.key, required this.day, this.onTap});

  final HistoryDay day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(day.date),
        subtitle: Text(
          'Protein ${day.proteinG.round()} g • ${day.mealCount} meals',
        ),
        trailing: Text('${day.calories.round()} kcal'),
        onTap: onTap,
      ),
    );
  }
}
