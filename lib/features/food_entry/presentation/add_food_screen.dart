part of '../../../app.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> analyze() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pushNamed(context, RouteNames.foodAnalyzing);
    final result = await ref
        .read(foodEntryControllerProvider.notifier)
        .analyze(text);
    if (!mounted) return;
    Navigator.pop(context);
    if (result.lowConfidence) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const LowConfidenceState(),
      );
      return;
    }
    final route = (result.preview?.items.length ?? 0) > 1
        ? RouteNames.multipleFoodConfirmation
        : RouteNames.foodConfirmation;
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(foodEntryControllerProvider).value ?? const FoodEntryState();
    return AppShell(
      currentIndex: 0,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HeaderRow(
            title: 'Add food',
            subtitle: "Type what you ate. We'll estimate it.",
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: controller,
            hintText: 'e.g. chowmin 1 plate, 2 boiled eggs',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          MealTypeSelector(
            selected: state.mealType,
            onSelected: ref
                .read(foodEntryControllerProvider.notifier)
                .setMealType,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.quickEntries
                .map(
                  (entry) => ActionChip(
                    label: Text(entry),
                    onPressed: () => controller.text = entry,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Analyze food', onPressed: analyze),
          const SizedBox(height: 12),
          AppButton(
            label: 'Search manually',
            secondary: true,
            onPressed: () => Navigator.pushNamed(context, RouteNames.foods),
          ),
        ],
      ),
    );
  }
}
