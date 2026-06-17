import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.restaurant_menu_rounded, size: 48),
        const SizedBox(height: 12),
        Text(title, style: AppTextStyles.cardTitle),
        const SizedBox(height: 4),
        Text(message, style: AppTextStyles.muted, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        AppButton(label: buttonLabel, onPressed: onPressed),
      ],
    );
  }
}
