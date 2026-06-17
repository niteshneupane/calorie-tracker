part of '../../../../app.dart';

class WeeklyTrendChart extends StatelessWidget {
  const WeeklyTrendChart({super.key, required this.items});

  final List<HistoryDay> items;

  @override
  Widget build(BuildContext context) {
    final chartItems = items.reversed.toList();
    return AppCard(
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: AppColors.primary,
                barWidth: 4,
                spots: [
                  for (var i = 0; i < chartItems.length; i++)
                    FlSpot(i.toDouble(), chartItems[i].calories),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
