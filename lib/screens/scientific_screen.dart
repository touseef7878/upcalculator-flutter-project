import 'dart:async';
import 'package:flutter/material.dart';
import '../core/math_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_panel.dart';

class ScientificScreen extends StatefulWidget {
  const ScientificScreen({super.key});

  @override
  State<ScientificScreen> createState() => _ScientificScreenState();
}

class _ScientificScreenState extends State<ScientificScreen> {
  String _expression = '';
  String _result = '0';
  String? _error;
  final List<String> _history = [];
  bool _justEvaluated = false;
  bool _isDeg = true;
  bool _isInverse = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onButton(String value) {
    setState(() {
      _error = null;
      switch (value) {
        case 'C':
          _expression = '';
          _result = '0';
          _justEvaluated = false;
          return;
        case '⌫':
          if (_expression.isNotEmpty) {
            // Smart backspace: remove whole function token if at end
            _expression = _smartBackspace(_expression);
            _justEvaluated = false;
            _tryLiveEval();
          }
          return;
        case '=':
          _evaluate();
          return;
        case 'DEG':
          _isDeg = !_isDeg;
          return;
        case 'INV':
          _isInverse = !_isInverse;
          return;
      }

      if (_justEvaluated && _isDigitOrDot(value)) {
        _expression = value;
        _justEvaluated = false;
        _tryLiveEval();
        return;
      }
      if (_justEvaluated && _isOperator(value)) {
        _expression = _result + value;
        _justEvaluated = false;
        _tryLiveEval();
        return;
      }
      _justEvaluated = false;
      _expression += _mapFunction(value);
      _tryLiveEval();
    });
  }

  /// Smart backspace — removes whole token like "sin(" not just "("
  String _smartBackspace(String expr) {
    const tokens = ['asin(', 'acos(', 'atan(', 'sin(', 'cos(', 'tan(',
        'sqrt(', 'cbrt(', 'abs(', 'log10(', 'log(', 'ln('];
    for (final t in tokens) {
      if (expr.endsWith(t)) return expr.substring(0, expr.length - t.length);
    }
    return expr.substring(0, expr.length - 1);
  }

  /// Map button label to expression string inserted into the expression.
  String _mapFunction(String v) {
    switch (v) {
      // Trig — forward
      case 'sin':   return 'sin(';
      case 'cos':   return 'cos(';
      case 'tan':   return 'tan(';
      // Trig — inverse (INV mode)
      case 'asin':  return 'asin(';
      case 'acos':  return 'acos(';
      case 'atan':  return 'atan(';
      // Logs
      case 'log':   return 'log10(';   // log base 10
      case 'ln':    return 'ln(';      // natural log
      // Powers
      case 'x²':    return '^2';
      case 'xⁿ':    return '^';
      case '√':     return 'sqrt(';
      case '∛':     return 'cbrt(';
      case '1/x':   return '1/(';
      case 'EXP':   return 'e';        // Euler's e constant, not scientific notation
      // Constants
      case 'π':     return 'π';
      case 'e':     return 'e';
      // Misc
      case 'n!':    return '!';
      case '|x|':   return 'abs(';
      case 'mod':   return ' mod ';
      case '(':     return '(';
      case ')':     return ')';
      case '+/-':
        if (_expression.isNotEmpty) {
          if (_expression.startsWith('-')) {
            _expression = _expression.substring(1);
          } else {
            _expression = '-$_expression';
          }
        }
        return '';
      case '%':
        try {
          final v2 = MathEngine.evalSci(_expression, degrees: _isDeg);
          _expression = _fmtDisplay(v2 / 100);
        } catch (_) {}
        return '';
      default:      return v;
    }
  }

  void _tryLiveEval() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      try {
        final expr = _autoClose(_expression);
        final v = MathEngine.evalSci(expr, degrees: _isDeg);
        if (!v.isNaN && !v.isInfinite) {
          setState(() => _result = _fmtDisplay(v));
        }
      } catch (_) {}
    });
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      // Auto-close any unclosed brackets before evaluating
      final expr = _autoClose(_expression);
      final v = MathEngine.evalSci(expr, degrees: _isDeg);
      if (v.isNaN) { _error = 'Undefined'; return; }
      if (v.isInfinite) { _error = v > 0 ? '∞' : '-∞'; return; }
      final res = _fmtDisplay(v);
      _history.add('$_expression = $res');
      if (_history.length > 50) _history.removeAt(0);
      _result = res;
      _expression = res; // show result in expression field
      _justEvaluated = true;
    } catch (e) {
      _error = 'Error';
    }
  }

  /// Auto-close unclosed parentheses
  String _autoClose(String expr) {
    int open = 0;
    for (final ch in expr.split('')) {
      if (ch == '(') open++;
      if (ch == ')') open--;
    }
    if (open > 0) return expr + ')' * open;
    return expr;
  }

  bool _isDigitOrDot(String v) => RegExp(r'^[\d.]$').hasMatch(v);
  bool _isOperator(String v) => '+-×÷^'.contains(v);

  String _fmtDisplay(double v) {
    if (v.isNaN) return 'NaN';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    if (v == v.truncateToDouble() && v.abs() < 1e15) return v.toInt().toString();
    final s = v.toStringAsPrecision(10);
    if (s.contains('.')) {
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DisplayPanel(
          expression: _expression,
          result: _result,
          error: _error,
          history: _history,
        ),
        Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _modeChip(_isDeg ? 'DEG' : 'RAD', () => _onButton('DEG'),
                  color: AppTheme.accent),
              const SizedBox(width: 8),
              _modeChip(_isInverse ? 'INV ON' : 'INV', () => _onButton('INV'),
                  color: _isInverse ? AppTheme.accentAlt : AppTheme.textSecondary),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(
              children: [
                _row([
                  _btn(_isInverse ? 'asin' : 'sin', CalcButtonType.function),
                  _btn(_isInverse ? 'acos' : 'cos', CalcButtonType.function),
                  _btn(_isInverse ? 'atan' : 'tan', CalcButtonType.function),
                  _btn('log', CalcButtonType.function),
                  _btn('ln', CalcButtonType.function),
                ]),
                _row([
                  _btn('x²', CalcButtonType.function),
                  _btn('xⁿ', CalcButtonType.function),
                  _btn('√', CalcButtonType.function),
                  _btn('∛', CalcButtonType.function),
                  _btn('1/x', CalcButtonType.function),
                ]),
                _row([
                  _btn('π', CalcButtonType.special),
                  _btn('e', CalcButtonType.special),
                  _btn('n!', CalcButtonType.function),
                  _btn('|x|', CalcButtonType.function),
                  _btn('mod', CalcButtonType.function),
                ]),
                _row([
                  _btn('(', CalcButtonType.operator),
                  _btn(')', CalcButtonType.operator),
                  _btn('EXP', CalcButtonType.function),
                  _btn('C', CalcButtonType.clear),
                  _btn('⌫', CalcButtonType.clear),
                ]),
                _row([
                  _btn('7', CalcButtonType.number),
                  _btn('8', CalcButtonType.number),
                  _btn('9', CalcButtonType.number),
                  _btn('÷', CalcButtonType.operator),
                  _btn('×', CalcButtonType.operator),
                ]),
                _row([
                  _btn('4', CalcButtonType.number),
                  _btn('5', CalcButtonType.number),
                  _btn('6', CalcButtonType.number),
                  _btn('-', CalcButtonType.operator),
                  _btn('+', CalcButtonType.operator),
                ]),
                _row([
                  _btn('1', CalcButtonType.number),
                  _btn('2', CalcButtonType.number),
                  _btn('3', CalcButtonType.number),
                  _btn('+/-', CalcButtonType.special),
                  _btn('%', CalcButtonType.special),
                ]),
                _row([
                  _btn('0', CalcButtonType.number, flex: 2),
                  _btn('.', CalcButtonType.number),
                  _btn('⌫', CalcButtonType.clear),
                  _btn('=', CalcButtonType.equals),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(List<Widget> children) => Expanded(child: Row(children: children));

  Widget _btn(String label, CalcButtonType type, {int flex = 1}) {
    return CalcButton(
      label: label,
      type: type,
      flex: flex,
      fontSize: label.length > 3 ? 13 : 18,
      onTap: () => _onButton(label),
    );
  }

  Widget _modeChip(String label, VoidCallback onTap, {required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
