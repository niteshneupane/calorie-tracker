part of '../../../../app.dart';

class LowConfidenceState extends StatelessWidget {
  const LowConfidenceState({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We need a bit more detail',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your meal was too vague to estimate accurately.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 12),
            const Text('Example: "normal lunch"', style: AppTextStyles.muted),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('dal bhat')),
                Chip(label: Text('rice and curry')),
                Chip(label: Text('noodles')),
              ],
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Try again',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Search manually',
              secondary: true,
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, RouteNames.foods),
            ),
          ],
        ),
      ),
    );
  }
}
