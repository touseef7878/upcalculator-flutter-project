import 'package:flutter/material.dart';
import '../core/math_engine.dart';
import '../theme/app_theme.dart';

class CalculusScreen extends StatefulWidget {
  const CalculusScreen({super.key});

  @override
  State<CalculusScreen> createState() => _CalculusScreenState();
}

class _CalculusScreenState extends State<CalculusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Derivative'),
              Tab(text: 'Integral'),
              Tab(text: 'Limit'),
              Tab(text: 'Taylor'),
              Tab(text: 'ODE'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _DerivativeTab(),
              _IntegralTab(),
              _LimitTab(),
              _TaylorTab(),
              _ODETab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Derivative Tab ───────────────────────────────────────────────────────────

class _DerivativeTab extends StatefulWidget {
  const _DerivativeTab();

  @override
  State<_DerivativeTab> createState() => _DerivativeTabState();
}

class _DerivativeTabState extends State<_DerivativeTab> {
  final _fnCtrl = TextEditingController();
  final _xCtrl = TextEditingController(text: '1');
  final _orderCtrl = TextEditingController(text: '1');
  String _result = '';
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final fn = _fnCtrl.text.trim();
        final x = double.parse(_xCtrl.text.trim());
        final order = int.tryParse(_orderCtrl.text.trim()) ?? 1;
        double res;
        if (order == 1) {
          res = MathEngine.derivative(fn, x);
        } else if (order == 2) {
          res = MathEngine.secondDerivative(fn, x);
        } else {
          // Higher order via repeated differentiation
          res = MathEngine.derivative(fn, x);
          _result = 'f\'(x) at x=$x ≈ ${_fmt(res)}';
          return;
        }
        _result = 'f${order == 2 ? '\'\'(x)' : '\'(x)'} at x=$x ≈ ${_fmt(res)}';
      } catch (e) {
        _error = 'Error: check your function syntax\nUse x as variable, e.g. x^2+3*x';
      }
    });
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsPrecision(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return _CalcForm(
      title: 'Numerical Derivative',
      subtitle: 'Computes f\'(x) or f\'\'(x) at a point using central difference',
      fields: [
        _FormField(label: 'f(x)', hint: 'e.g. x^3 + 2*x', controller: _fnCtrl),
        _FormField(label: 'x value', hint: 'e.g. 2', controller: _xCtrl, isNumber: true),
        _FormField(label: 'Order (1 or 2)', hint: '1', controller: _orderCtrl, isNumber: true),
      ],
      onCalculate: _calculate,
      result: _result,
      error: _error,
    );
  }
}

// ─── Integral Tab ─────────────────────────────────────────────────────────────

class _IntegralTab extends StatefulWidget {
  const _IntegralTab();

  @override
  State<_IntegralTab> createState() => _IntegralTabState();
}

class _IntegralTabState extends State<_IntegralTab> {
  final _fnCtrl = TextEditingController();
  final _aCtrl = TextEditingController(text: '0');
  final _bCtrl = TextEditingController(text: '1');
  String _result = '';
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final fn = _fnCtrl.text.trim();
        final a = double.parse(_aCtrl.text.trim());
        final b = double.parse(_bCtrl.text.trim());
        final res = MathEngine.integrate(fn, a, b);
        _result = '∫f(x)dx from $a to $b ≈ ${_fmt(res)}';
      } catch (_) {
        _error = 'Error: check your function syntax\nUse x as variable, e.g. sin(x)';
      }
    });
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsPrecision(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return _CalcForm(
      title: 'Definite Integral',
      subtitle: 'Simpson\'s rule with 1000 intervals — high accuracy',
      fields: [
        _FormField(label: 'f(x)', hint: 'e.g. sin(x)', controller: _fnCtrl),
        _FormField(label: 'Lower bound (a)', hint: '0', controller: _aCtrl, isNumber: true),
        _FormField(label: 'Upper bound (b)', hint: '1', controller: _bCtrl, isNumber: true),
      ],
      onCalculate: _calculate,
      result: _result,
      error: _error,
    );
  }
}

// ─── Limit Tab ────────────────────────────────────────────────────────────────

class _LimitTab extends StatefulWidget {
  const _LimitTab();

  @override
  State<_LimitTab> createState() => _LimitTabState();
}

class _LimitTabState extends State<_LimitTab> {
  final _fnCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '0');
  String _result = '';
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final fn = _fnCtrl.text.trim();
        final target = double.parse(_targetCtrl.text.trim());
        final res = MathEngine.limit(fn, target);
        if (res.isNaN) {
          _result = 'Limit does not exist (left ≠ right)';
        } else {
          _result = 'lim(x→$target) f(x) ≈ ${_fmt(res)}';
        }
      } catch (_) {
        _error = 'Error: check your function syntax';
      }
    });
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsPrecision(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return _CalcForm(
      title: 'Limit',
      subtitle: 'Numerical limit as x approaches a value',
      fields: [
        _FormField(label: 'f(x)', hint: 'e.g. sin(x)/x', controller: _fnCtrl),
        _FormField(label: 'x → ?', hint: '0', controller: _targetCtrl, isNumber: true),
      ],
      onCalculate: _calculate,
      result: _result,
      error: _error,
    );
  }
}

// ─── Taylor Tab ───────────────────────────────────────────────────────────────

class _TaylorTab extends StatefulWidget {
  const _TaylorTab();

  @override
  State<_TaylorTab> createState() => _TaylorTabState();
}

class _TaylorTabState extends State<_TaylorTab> {
  final _fnCtrl = TextEditingController();
  final _aCtrl = TextEditingController(text: '0');
  final _orderCtrl = TextEditingController(text: '4');
  String _result = '';
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final fn = _fnCtrl.text.trim();
        final a = double.parse(_aCtrl.text.trim());
        final order = int.tryParse(_orderCtrl.text.trim()) ?? 4;
        final series = MathEngine.taylorSeries(fn, a, order.clamp(1, 8));
        _result = 'T(x) ≈ $series';
      } catch (_) {
        _error = 'Error: check your function syntax';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CalcForm(
      title: 'Taylor Series',
      subtitle: 'Polynomial approximation around a point',
      fields: [
        _FormField(label: 'f(x)', hint: 'e.g. sin(x)', controller: _fnCtrl),
        _FormField(label: 'Center (a)', hint: '0', controller: _aCtrl, isNumber: true),
        _FormField(label: 'Order (1–8)', hint: '4', controller: _orderCtrl, isNumber: true),
      ],
      onCalculate: _calculate,
      result: _result,
      error: _error,
    );
  }
}

// ─── ODE Tab ──────────────────────────────────────────────────────────────────

class _ODETab extends StatefulWidget {
  const _ODETab();

  @override
  State<_ODETab> createState() => _ODETabState();
}

class _ODETabState extends State<_ODETab> {
  final _fnCtrl = TextEditingController();
  final _x0Ctrl = TextEditingController(text: '0');
  final _y0Ctrl = TextEditingController(text: '1');
  final _xEndCtrl = TextEditingController(text: '5');
  final _stepsCtrl = TextEditingController(text: '10');
  bool _useRK4 = true;
  List<List<double>> _points = [];
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _points = [];
      try {
        final fn = _fnCtrl.text.trim();
        final x0 = double.parse(_x0Ctrl.text.trim());
        final y0 = double.parse(_y0Ctrl.text.trim());
        final xEnd = double.parse(_xEndCtrl.text.trim());
        final steps = int.tryParse(_stepsCtrl.text.trim()) ?? 10;
        _points = _useRK4
            ? MathEngine.rungeKutta4(fn, x0, y0, xEnd, steps.clamp(2, 50))
            : MathEngine.eulerMethod(fn, x0, y0, xEnd, steps.clamp(2, 50));
      } catch (_) {
        _error = 'Error: use x and y as variables, e.g. x*y';
      }
    });
  }

  String _fmt(double v) => v.toStringAsFixed(6);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('ODE Solver', 'Solves dy/dx = f(x,y) numerically'),
          const SizedBox(height: 16),
          _field('dy/dx = f(x,y)', 'e.g. x*y or -2*y', _fnCtrl),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field('x₀', '0', _x0Ctrl, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _field('y₀', '1', _y0Ctrl, isNumber: true)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field('x end', '5', _xEndCtrl, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _field('Steps', '10', _stepsCtrl, isNumber: true)),
          ]),
          const SizedBox(height: 12),
          // Method toggle
          Row(
            children: [
              const Text('Method:', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              _methodChip('RK4', _useRK4, () => setState(() => _useRK4 = true)),
              const SizedBox(width: 8),
              _methodChip('Euler', !_useRK4, () => setState(() => _useRK4 = false)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Solve', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorBox(_error!),
          ],
          if (_points.isNotEmpty) ...[
            const SizedBox(height: 16),
            _resultBox(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_useRK4 ? 'RK4' : 'Euler'} Solution (${_points.length} points)',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Expanded(child: Text('x', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                      Expanded(child: Text('y', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                    ],
                  ),
                  const Divider(color: AppTheme.divider),
                  ..._points.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(_fmt(p[0]), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'))),
                            Expanded(child: Text(_fmt(p[1]), style: const TextStyle(color: AppTheme.success, fontSize: 13, fontFamily: 'monospace'))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _methodChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 13)),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _FormField {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isNumber;
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.isNumber = false,
  });
}

class _CalcForm extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_FormField> fields;
  final VoidCallback onCalculate;
  final String result;
  final String? error;

  const _CalcForm({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onCalculate,
    required this.result,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title, subtitle),
          const SizedBox(height: 16),
          ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: f.controller,
                  keyboardType: f.isNumber ? TextInputType.number : TextInputType.text,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(labelText: f.label, hintText: f.hint),
                ),
              )),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCalculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _errorBox(error!),
          ],
          if (result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _resultBox(Text(result,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w300))),
          ],
        ],
      ),
    );
  }
}

Widget _sectionTitle(String title, String subtitle) {
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

Widget _resultBox(Widget child) {
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

Widget _errorBox(String msg) {
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
