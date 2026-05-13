import 'package:flutter/material.dart';
import '../core/matrix_engine.dart';
import '../core/math_engine.dart';
import '../theme/app_theme.dart';

// ─── Local shared helpers ─────────────────────────────────────────────────────

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

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
              Tab(text: 'Operations'),
              Tab(text: 'Solve Ax=b'),
              Tab(text: 'Properties'),
              Tab(text: 'Quadratic'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _MatrixOpsTab(),
              _LinearSystemTab(),
              _MatrixPropsTab(),
              _QuadraticTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Matrix Input Widget ──────────────────────────────────────────────────────

class MatrixInput extends StatefulWidget {
  final String label;
  final int rows;
  final int cols;
  final List<List<TextEditingController>> controllers;

  const MatrixInput({
    super.key,
    required this.label,
    required this.rows,
    required this.cols,
    required this.controllers,
  });

  @override
  State<MatrixInput> createState() => _MatrixInputState();
}

class _MatrixInputState extends State<MatrixInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: List.generate(widget.rows, (i) {
              return Row(
                children: List.generate(widget.cols, (j) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: TextField(
                        controller: widget.controllers[i][j],
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '0',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppTheme.accent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppTheme.surface,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}

List<List<TextEditingController>> _makeControllers(int rows, int cols) {
  return List.generate(
      rows, (_) => List.generate(cols, (_) => TextEditingController(text: '0')));
}

List<List<double>> _readMatrix(List<List<TextEditingController>> ctrls) {
  return ctrls
      .map((row) => row.map((c) => double.tryParse(c.text.trim()) ?? 0).toList())
      .toList();
}

// ─── Matrix Operations Tab ────────────────────────────────────────────────────

class _MatrixOpsTab extends StatefulWidget {
  const _MatrixOpsTab();

  @override
  State<_MatrixOpsTab> createState() => _MatrixOpsTabState();
}

class _MatrixOpsTabState extends State<_MatrixOpsTab> {
  int _rows = 2, _cols = 2;
  late List<List<TextEditingController>> _aCtrl;
  late List<List<TextEditingController>> _bCtrl;
  String _operation = 'Add';
  String _result = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _aCtrl = _makeControllers(_rows, _cols);
    _bCtrl = _makeControllers(_rows, _cols);
  }

  @override
  void dispose() {
    _disposeControllers(_aCtrl);
    _disposeControllers(_bCtrl);
    super.dispose();
  }

  void _disposeControllers(List<List<TextEditingController>> ctrls) {
    for (final row in ctrls) {
      for (final c in row) c.dispose();
    }
  }

  void _rebuildControllers() {
    _disposeControllers(_aCtrl);
    _disposeControllers(_bCtrl);
    _aCtrl = _makeControllers(_rows, _cols);
    _bCtrl = _makeControllers(_rows, _cols);
  }

  void _calculate() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final a = _readMatrix(_aCtrl);
        final b = _readMatrix(_bCtrl);
        List<List<double>> res;
        switch (_operation) {
          case 'Add':
            res = MatrixEngine.add(a, b);
          case 'Subtract':
            res = MatrixEngine.subtract(a, b);
          case 'Multiply':
            res = MatrixEngine.multiply(a, b);
          default:
            res = a;
        }
        _result = MatrixEngine.formatMatrix(res);
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Matrix Operations', 'Add, subtract, or multiply two matrices'),
          const SizedBox(height: 12),
          // Size selector
          Row(
            children: [
              const Text('Size:', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              ...[2, 3, 4].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _sizeChip('${s}x$s', _rows == s, () {
                      setState(() {
                        _rows = s;
                        _cols = s;
                        _rebuildControllers();
                      });
                    }),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          MatrixInput(label: 'Matrix A', rows: _rows, cols: _cols, controllers: _aCtrl),
          const SizedBox(height: 12),
          // Operation selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Add', 'Subtract', 'Multiply'].map((op) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _sizeChip(op, _operation == op, () {
                  setState(() => _operation = op);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          MatrixInput(label: 'Matrix B', rows: _rows, cols: _cols, controllers: _bCtrl),
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
              child: const Text('Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _resultBox(Text('Result:\n$_result',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontFamily: 'monospace'))),
          ],
        ],
      ),
    );
  }

  Widget _sizeChip(String label, bool selected, VoidCallback onTap) {
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
}

// ─── Linear System Tab ────────────────────────────────────────────────────────

class _LinearSystemTab extends StatefulWidget {
  const _LinearSystemTab();

  @override
  State<_LinearSystemTab> createState() => _LinearSystemTabState();
}

class _LinearSystemTabState extends State<_LinearSystemTab> {
  int _n = 2;
  late List<List<TextEditingController>> _aCtrl;
  late List<TextEditingController> _bCtrl;
  String _result = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  void _disposeAll() {
    for (final row in _aCtrl) for (final c in row) c.dispose();
    for (final c in _bCtrl) c.dispose();
  }

  void _rebuild() {
    _aCtrl = _makeControllers(_n, _n);
    _bCtrl = List.generate(_n, (_) => TextEditingController(text: '0'));
  }

  void _solve() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final a = _readMatrix(_aCtrl);
        final b = _bCtrl.map((c) => double.tryParse(c.text.trim()) ?? 0).toList();
        final sol = MatrixEngine.solveLinearSystem(a, b);
        if (sol == null) {
          _error = 'No unique solution (singular matrix)';
          return;
        }
        final vars = ['x', 'y', 'z', 'w'];
        _result = sol.asMap().entries
            .map((e) => '${e.key < vars.length ? vars[e.key] : 'x${e.key}'} = ${_fmt(e.value)}')
            .join('\n');
      } catch (e) {
        _error = e.toString();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Linear System Solver', 'Solves Ax = b using Gaussian elimination'),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Variables:', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              ...[2, 3, 4].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip('$s', _n == s, () {
                      setState(() { _n = s; _rebuild(); });
                    }),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          MatrixInput(label: 'Coefficient Matrix A', rows: _n, cols: _n, controllers: _aCtrl),
          const SizedBox(height: 12),
          // b vector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vector b',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: _bCtrl.map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: c,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.divider)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppTheme.accent, width: 1.5)),
                            filled: true,
                            fillColor: AppTheme.surface,
                          ),
                        ),
                      ),
                    )).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Solve',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _resultBox(Text(_result,
                style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 18,
                    fontWeight: FontWeight.w400))),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
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
}

// ─── Matrix Properties Tab ────────────────────────────────────────────────────

class _MatrixPropsTab extends StatefulWidget {
  const _MatrixPropsTab();

  @override
  State<_MatrixPropsTab> createState() => _MatrixPropsTabState();
}

class _MatrixPropsTabState extends State<_MatrixPropsTab> {
  int _size = 2;
  late List<List<TextEditingController>> _ctrl;
  Map<String, String> _props = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = _makeControllers(_size, _size);
  }

  @override
  void dispose() {
    for (final row in _ctrl) for (final c in row) c.dispose();
    super.dispose();
  }

  void _analyze() {
    setState(() {
      _error = null;
      _props = {};
      try {
        final m = _readMatrix(_ctrl);
        final det = MatrixEngine.determinant(m);
        final tr = MatrixEngine.trace(m);
        final rk = MatrixEngine.rank(m);
        final norm = MatrixEngine.frobeniusNorm(m);
        final inv = MatrixEngine.inverse(m);
        final t = MatrixEngine.transpose(m);

        _props = {
          'Determinant': _fmt(det),
          'Trace': _fmt(tr),
          'Rank': rk.toString(),
          'Frobenius Norm': _fmt(norm),
          'Invertible': inv != null ? 'Yes' : 'No',
          'Transpose': MatrixEngine.formatMatrix(t),
          if (inv != null) 'Inverse': MatrixEngine.formatMatrix(inv),
          if (_size == 2) 'Eigenvalues': () {
            final ev = MatrixEngine.eigenvalues2x2(m);
            return ev.isEmpty ? 'Complex' : ev.map(_fmt).join(', ');
          }(),
        };
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e12) return v.toInt().toString();
    return v.toStringAsPrecision(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Matrix Properties', 'Determinant, inverse, eigenvalues, rank & more'),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Size:', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              ...[2, 3, 4].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip('${s}x$s', _size == s, () {
                      setState(() {
                        for (final row in _ctrl) for (final c in row) c.dispose();
                        _size = s;
                        _ctrl = _makeControllers(s, s);
                        _props = {};
                      });
                    }),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          MatrixInput(label: 'Matrix', rows: _size, cols: _size, controllers: _ctrl),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Analyze',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_props.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._props.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _propCard(e.key, e.value),
                )),
          ],
        ],
      ),
    );
  }

  Widget _propCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
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
}

// ─── Quadratic Tab ────────────────────────────────────────────────────────────

class _QuadraticTab extends StatefulWidget {
  const _QuadraticTab();

  @override
  State<_QuadraticTab> createState() => _QuadraticTabState();
}

class _QuadraticTabState extends State<_QuadraticTab> {
  final _aCtrl = TextEditingController(text: '1');
  final _bCtrl = TextEditingController(text: '-3');
  final _cCtrl = TextEditingController(text: '2');
  List<String> _roots = [];
  String? _error;
  String _discriminant = '';

  void _solve() {
    setState(() {
      _error = null;
      _roots = [];
      _discriminant = '';
      try {
        final a = double.parse(_aCtrl.text.trim());
        final b = double.parse(_bCtrl.text.trim());
        final c = double.parse(_cCtrl.text.trim());
        final disc = b * b - 4 * a * c;
        _discriminant = 'Δ = b²−4ac = ${_fmt(disc)}';
        _roots = MathEngine.solveQuadratic(a, b, c);
      } catch (_) {
        _error = 'Enter valid numbers for a, b, c';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Quadratic Solver', 'Solves ax² + bx + c = 0 (real & complex roots)'),
          const SizedBox(height: 16),
          // Equation preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_aCtrl.text}x² + (${_bCtrl.text})x + (${_cCtrl.text}) = 0',
              style: const TextStyle(
                  color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _numField('a', _aCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _numField('b', _bCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _numField('c', _cCtrl)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Solve',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_roots.isNotEmpty) ...[
            const SizedBox(height: 12),
            _resultBox(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_discriminant,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ..._roots.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'x${e.key + 1} = ${e.value}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w300),
                      ),
                    )),
              ],
            )),
          ],
        ],
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.accent),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
