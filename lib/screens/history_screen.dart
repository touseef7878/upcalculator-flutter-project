import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                onClear();
                Navigator.pop(context);
              },
              child: const Text('Clear',
                  style: TextStyle(color: AppTheme.danger, fontSize: 14)),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: AppTheme.textSecondary, size: 48),
                  SizedBox(height: 12),
                  Text('No history yet',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppTheme.divider, height: 1),
              itemBuilder: (context, index) {
                final entry = history[history.length - 1 - index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  title: Text(
                    entry,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy,
                        color: AppTheme.textSecondary, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: entry));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied'),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppTheme.surfaceHigh,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
