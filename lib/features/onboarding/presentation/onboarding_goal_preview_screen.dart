part of '../../../app.dart';

class OnboardingGoalPreviewScreen extends ConsumerStatefulWidget {
  const OnboardingGoalPreviewScreen({super.key});

  @override
  ConsumerState<OnboardingGoalPreviewScreen> createState() =>
      _OnboardingGoalPreviewScreenState();
}

class _OnboardingGoalPreviewScreenState
    extends ConsumerState<OnboardingGoalPreviewScreen> {
  final calories = TextEditingController(text: '2200');
  final protein = TextEditingController(text: '120');
  final carbs = TextEditingController(text: '250');
  final fat = TextEditingController(text: '70');

  @override
  void dispose() {
    calories.dispose();
    protein.dispose();
    carbs.dispose();
    fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft =
        ModalRoute.of(context)?.settings.arguments as UserProfile? ??
        const UserProfile();
    return AuthScaffold(
      child: ListView(
        children: [
          const StepLabel(text: 'Step 2 of 2'),
          const SizedBox(height: 8),
          const Text('Daily targets', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          AppTextField(
            controller: calories,
            hintText: '2200',
            labelText: 'Calories',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: protein,
            hintText: '120',
            labelText: 'Protein (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: carbs,
            hintText: '250',
            labelText: 'Carbs (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: fat,
            hintText: '70',
            labelText: 'Fat (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Start Tracking',
            onPressed: () async {
              await ref
                  .read(profileRepositoryProvider)
                  .saveProfile(
                    UserProfile(
                      name: draft.name,
                      age: draft.age,
                      sex: draft.sex,
                      heightCm: draft.heightCm,
                      weightKg: draft.weightKg,
                      activityLevel: draft.activityLevel,
                      goal: draft.goal,
                      dailyCalorieGoal: double.tryParse(calories.text),
                      proteinGoalG: double.tryParse(protein.text),
                      carbsGoalG: double.tryParse(carbs.text),
                      fatGoalG: double.tryParse(fat.text),
                    ),
                  );
              await ref
                  .read(authControllerProvider.notifier)
                  .completeOnboarding();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.today,
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
