import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Widget sectionTitle(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ],
  );
}

Widget resultBox(Widget child) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
    ),
    child: child,
  );
}

Widget errorBox(String msg) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.danger.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
    ),
    child: Text(msg,
        style: const TextStyle(color: AppTheme.danger, fontSize: 14)),
  );
}
