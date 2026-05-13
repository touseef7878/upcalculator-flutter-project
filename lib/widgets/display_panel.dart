import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DisplayPanel extends StatelessWidget {
  final String expression;
  final String result;
  final String? error;
  final List<String> history;

  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    this.error,
    this.history = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // History preview (last 2 entries)
          if (history.isNotEmpty)
            ...history.reversed.take(2).map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    h,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                )),

          const SizedBox(height: 8),

          // Expression
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: expression));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppTheme.surfaceHigh,
                ),
              );
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: TextStyle(
                  color: error != null
                      ? AppTheme.danger
                      : AppTheme.textSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Result
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: result));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Result copied'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppTheme.surfaceHigh,
                ),
              );
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                error ?? result,
                style: TextStyle(
                  color: error != null ? AppTheme.danger : AppTheme.textPrimary,
                  fontSize: error != null ? 18 : 42,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
