part of '../../../../app.dart';

class CalorieProgressCard extends StatelessWidget {
  const CalorieProgressCard({super.key, required this.summary});

  final DailySummaryResponse summary;

  @override
  Widget build(BuildContext context) {
    final consumed = summary.consumed.calories;
    final goal = summary.goal?.calories;
    final remaining = goal == null ? null : math.max(0, goal - consumed);
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            height: 136,
            width: 136,
            child: CustomPaint(
              painter: CalorieRingPainter(
                progress: goal == null || goal <= 0
                    ? 0
                    : (consumed / goal).clamp(0, 1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      consumed.round().toString(),
                      style: AppTextStyles.heading,
                    ),
                    const Text('kcal', style: AppTextStyles.muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal == null
                      ? '${consumed.round()} kcal'
                      : '${consumed.round()} / ${goal.round()} kcal',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  remaining == null
                      ? 'No calorie target set'
                      : '${remaining.round()} kcal remaining',
                  style: AppTextStyles.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CalorieRingPainter extends CustomPainter {
  CalorieRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final rect = Offset.zero & size;
    final background = Paint()
      ..color = AppColors.surfaceTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final foreground = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(stroke),
      -math.pi / 2,
      math.pi * 2,
      false,
      background,
    );
    canvas.drawArc(
      rect.deflate(stroke),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
