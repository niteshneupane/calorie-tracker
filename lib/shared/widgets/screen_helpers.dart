part of '../../app.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.muted),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class StepLabel extends StatelessWidget {
  const StepLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.primary));
  }
}

class SegmentedField extends StatelessWidget {
  const SegmentedField({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.muted),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (item) => ChoiceChip(
                  label: Text(item),
                  selected: item == value,
                  onSelected: (_) => onChanged(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
