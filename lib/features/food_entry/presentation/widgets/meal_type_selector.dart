part of '../../../../app.dart';

class MealTypeSelector extends StatelessWidget {
  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MealType selected;
  final ValueChanged<MealType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: MealType.values
          .take(4)
          .map(
            (type) => ChoiceChip(
              label: Text(type.label),
              selected: selected == type,
              onSelected: (_) => onSelected(type),
            ),
          )
          .toList(),
    );
  }
}
