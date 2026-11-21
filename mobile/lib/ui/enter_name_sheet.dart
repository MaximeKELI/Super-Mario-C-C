import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'widgets/parallax_sky.dart';

class EnterNameSheet {
  static Future<String?> show(
    BuildContext context,
    int score, {
    String defaultName = 'PIP',
  }) async {
    final controller = TextEditingController(text: defaultName);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.yellow, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEW HIGH SCORE!', style: Theme.of(context).textTheme.headlineMedium),
                Text(
                  '$score pts',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                PremiumButton(
                  label: 'SAVE',
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
