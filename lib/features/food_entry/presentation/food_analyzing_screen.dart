part of '../../../app.dart';

class FoodAnalyzingScreen extends StatelessWidget {
  const FoodAnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Analyzing your food...', style: AppTextStyles.heading),
              SizedBox(height: 6),
              Text(
                'Estimating portion and nutrients',
                style: AppTextStyles.muted,
              ),
              SizedBox(height: 24),
              SkeletonCard(),
              SizedBox(height: 12),
              SkeletonCard(),
            ],
          ),
        ),
      ),
    );
  }
}
