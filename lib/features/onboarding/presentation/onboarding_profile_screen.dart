part of '../../../app.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final name = TextEditingController();
  final age = TextEditingController(text: '25');
  final height = TextEditingController(text: '170');
  final weight = TextEditingController(text: '70');
  String sex = 'male';
  String activity = 'moderate';
  String goal = 'maintain';

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListView(
        children: [
          const StepLabel(text: 'Step 1 of 2'),
          const SizedBox(height: 8),
          const Text('Tell us about you', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          AppTextField(
            controller: name,
            hintText: 'Nitesh',
            labelText: 'Name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: age,
            hintText: '25',
            labelText: 'Age',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SegmentedField(
            label: 'Sex',
            value: sex,
            values: const ['male', 'female', 'other'],
            onChanged: (value) => setState(() => sex = value),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: height,
            hintText: '170',
            labelText: 'Height (cm)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: weight,
            hintText: '70',
            labelText: 'Weight (kg)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SegmentedField(
            label: 'Activity level',
            value: activity,
            values: const ['light', 'moderate', 'active'],
            onChanged: (value) => setState(() => activity = value),
          ),
          const SizedBox(height: 12),
          SegmentedField(
            label: 'Goal',
            value: goal,
            values: const ['lose weight', 'maintain', 'gain muscle'],
            onChanged: (value) => setState(() => goal = value),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Continue',
            onPressed: () => Navigator.pushNamed(
              context,
              RouteNames.onboardingGoals,
              arguments: UserProfile(
                name: name.text.trim().isEmpty ? null : name.text.trim(),
                age: double.tryParse(age.text),
                sex: sex,
                heightCm: double.tryParse(height.text),
                weightKg: double.tryParse(weight.text),
                activityLevel: activity,
                goal: goal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
