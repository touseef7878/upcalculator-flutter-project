import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum CalcButtonType { number, operator, function, equals, clear, special }

class CalcButton extends StatefulWidget {
  final String label;
  final String? sublabel;
  final CalcButtonType type;
  final VoidCallback onTap;
  final double? fontSize;
  final int flex;
  final Color? overrideColor;

  const CalcButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.sublabel,
    this.fontSize,
    this.flex = 1,
    this.overrideColor,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    if (widget.overrideColor != null) return widget.overrideColor!;
    switch (widget.type) {
      case CalcButtonType.number:   return AppTheme.btnNumber;
      case CalcButtonType.operator: return AppTheme.btnOperator;
      case CalcButtonType.function: return AppTheme.btnFunction;
      case CalcButtonType.equals:   return AppTheme.btnEquals;
      case CalcButtonType.clear:    return AppTheme.btnClear;
      case CalcButtonType.special:  return AppTheme.btnSpecial;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case CalcButtonType.equals:   return AppTheme.background;
      case CalcButtonType.operator: return AppTheme.accent;
      case CalcButtonType.function: return AppTheme.accentAlt;
      case CalcButtonType.clear:    return AppTheme.danger;
      case CalcButtonType.special:  return AppTheme.success;
      default:                      return AppTheme.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
              _controller.forward();
            },
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.type == CalcButtonType.equals
                      ? AppTheme.accent.withValues(alpha: 0.3)
                      : AppTheme.divider,
                  width: 1,
                ),
                boxShadow: widget.type == CalcButtonType.equals
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: widget.fontSize ?? 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.sublabel != null)
                    Text(
                      widget.sublabel!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
