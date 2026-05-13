import 'dart:async';
import 'package:flutter/material.dart';
import '../core/math_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_panel.dart';

class StandardScreen extends StatefulWidget {
  const StandardScreen({super.key});

  @override
  State<StandardScreen> createState() => _StandardScreenState();
}

class _StandardScreenState extends State<StandardScreen> {
  String _expression = '';
  String _result = '0';
  String? _error;
  final List<String> _history = [];
  bool _justEvaluated = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onButton(String value) {
    setState(() {
      _error = null;

      if (value == 'C') {
        _expression = '';
        _result = '0';
        _justEvaluated = false;
        return;
      }

      if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _justEvaluated = false;
          _tryLiveEval();
        }
        return;
      }

      if (value == '=') {
        _evaluate();
        return;
      }

      if (value == '%') {
        if (_expression.isNotEmpty) {
          try {
            final v = MathEngine.evalSci(_expression, degrees: false);
            _expression = _fmt(v / 100);
            _result = _expression;
          } catch (_) {
            _expression += '%';
          }
        }
        return;
      }

      if (value == '+/-') {
        if (_expression.isNotEmpty) {
          if (_expression.startsWith('-')) {
            _expression = _expression.substring(1);
          } else {
            _expression = '-$_expression';
          }
          _tryLiveEval();
        }
        return;
      }

      // If just evaluated and user types a number, start fresh
      if (_justEvaluated && _isDigitOrDot(value)) {
        _expression = value;
        _justEvaluated = false;
        _tryLiveEval();
        return;
      }

      // If just evaluated and user types operator, continue from result
      if (_justEvaluated && _isOperator(value)) {
        _expression = _result + value;
        _justEvaluated = false;
        _tryLiveEval();
        return;
      }

      _justEvaluated = false;
      _expression += value;
      _tryLiveEval();
    });
  }

  void _tryLiveEval() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      try {
        final v = MathEngine.evalSci(_expression, degrees: false);
        if (!v.isNaN && !v.isInfinite) {
          setState(() => _result = _fmt(v));
        }
      } catch (_) {}
    });
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      final v = MathEngine.evalSci(_expression, degrees: false);
      if (v.isNaN) { _error = 'Undefined'; return; }
      if (v.isInfinite) { _error = v > 0 ? '∞' : '-∞'; return; }
      final res = _fmt(v);
      _history.add('$_expression = $res');
      if (_history.length > 20) _history.removeAt(0);
      _result = res;
      _justEvaluated = true;
    } catch (e) {
      _error = 'Error';
    }
  }

  bool _isDigitOrDot(String v) => RegExp(r'^[\d.]$').hasMatch(v);
  bool _isOperator(String v) => '+-×÷'.contains(v);

  String _fmt(double v) {
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
        Expanded(
          child: Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              children: [
                _buildRow(['C', '+/-', '%', '÷'],
                    [CalcButtonType.clear, CalcButtonType.special, CalcButtonType.special, CalcButtonType.operator]),
                _buildRow(['7', '8', '9', '×'],
                    [CalcButtonType.number, CalcButtonType.number, CalcButtonType.number, CalcButtonType.operator]),
                _buildRow(['4', '5', '6', '-'],
                    [CalcButtonType.number, CalcButtonType.number, CalcButtonType.number, CalcButtonType.operator]),
                _buildRow(['1', '2', '3', '+'],
                    [CalcButtonType.number, CalcButtonType.number, CalcButtonType.number, CalcButtonType.operator]),
                _buildLastRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> labels, List<CalcButtonType> types) {
    return Expanded(
      child: Row(
        children: List.generate(
          labels.length,
          (i) => CalcButton(
            label: labels[i],
            type: types[i],
            onTap: () => _onButton(labels[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildLastRow() {
    return Expanded(
      child: Row(
        children: [
          CalcButton(
            label: '0',
            type: CalcButtonType.number,
            flex: 2,
            onTap: () => _onButton('0'),
          ),
          CalcButton(
            label: '.',
            type: CalcButtonType.number,
            onTap: () => _onButton('.'),
          ),
          CalcButton(
            label: '=',
            type: CalcButtonType.equals,
            onTap: () => _onButton('='),
          ),
        ],
      ),
    );
  }
}
