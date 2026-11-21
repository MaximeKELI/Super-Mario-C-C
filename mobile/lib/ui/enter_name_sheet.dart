import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/secure_store.dart';
import '../theme/app_theme.dart';
import 'widgets/parallax_sky.dart';

class EnterNameSheet {
  static Future<String?> show(
    BuildContext context,
    int score, {
    String defaultName = 'PIP',
  }) async {
    final controller = TextEditingController(
      text: SecureStore.sanitizeName(defaultName, fallback: 'PIP'),
    );
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
                  '${SecureStore.clampScore(score)} pts',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLength: SecureStore.maxNameLen,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9 _\-'.]")),
                    LengthLimitingTextInputFormatter(SecureStore.maxNameLen),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                PremiumButton(
                  label: 'SAVE',
                  onPressed: () => Navigator.pop(
                    context,
                    SecureStore.sanitizeName(controller.text, fallback: ''),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
