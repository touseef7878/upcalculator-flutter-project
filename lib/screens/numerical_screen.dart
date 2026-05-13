import 'package:flutter/material.dart';
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

class NumericalScreen extends StatefulWidget {
  const NumericalScreen({super.key});

  @override
  State<NumericalScreen> createState() => _NumericalScreenState();
}

class _NumericalScreenState extends State<NumericalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            tabs: const [
              Tab(text: 'Root Finding'),
              Tab(text: 'Statistics'),
              Tab(text: 'Number Theory'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _RootFindingTab(),
              _StatisticsTab(),
              _NumberTheoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Root Finding Tab ─────────────────────────────────────────────────────────

class _RootFindingTab extends StatefulWidget {
  const _RootFindingTab();

  @override
  State<_RootFindingTab> createState() => _RootFindingTabState();
}

class _RootFindingTabState extends State<_RootFindingTab> {
  final _fnCtrl = TextEditingController();
  final _x0Ctrl = TextEditingController(text: '1');
  final _aCtrl = TextEditingController(text: '-2');
  final _bCtrl = TextEditingController(text: '2');
  bool _useNewton = true;
  String _result = '';
  String? _error;

  void _solve() {
    setState(() {
      _error = null;
      _result = '';
      try {
        final fn = _fnCtrl.text.trim();
        double root;
        if (_useNewton) {
          final x0 = double.parse(_x0Ctrl.text.trim());
          root = MathEngine.newtonRaphson(fn, x0);
        } else {
          final a = double.parse(_aCtrl.text.trim());
          final b = double.parse(_bCtrl.text.trim());
          root = MathEngine.bisection(fn, a, b);
        }
        _result = 'Root ≈ ${_fmt(root)}\nf(root) ≈ ${_fmt(MathEngine.evaluate(fn.replaceAll('x', '($root)')))}';
      } catch (_) {
        _error = 'Error: use x as variable, e.g. x^3 - x - 2';
      }
    });
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsPrecision(10)
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
          _sectionTitle('Root Finding', 'Newton-Raphson or Bisection method'),
          const SizedBox(height: 16),
          TextField(
            controller: _fnCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'f(x)',
              hintText: 'e.g. x^3 - x - 2',
            ),
          ),
          const SizedBox(height: 16),
          // Method toggle
          Row(
            children: [
              const Text('Method:', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              _chip('Newton-Raphson', _useNewton, () => setState(() => _useNewton = true)),
              const SizedBox(width: 8),
              _chip('Bisection', !_useNewton, () => setState(() => _useNewton = false)),
            ],
          ),
          const SizedBox(height: 12),
          if (_useNewton)
            TextField(
              controller: _x0Ctrl,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Initial guess x₀',
                hintText: '1',
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aCtrl,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'a (lower)', hintText: '-2'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _bCtrl,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'b (upper)', hintText: '2'),
                  ),
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
              child: const Text('Find Root',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _resultBox(Text(_result,
                style: const TextStyle(
                    color: AppTheme.success, fontSize: 18, fontWeight: FontWeight.w300))),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 12)),
      ),
    );
  }
}

// ─── Statistics Tab ───────────────────────────────────────────────────────────

class _StatisticsTab extends StatefulWidget {
  const _StatisticsTab();

  @override
  State<_StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<_StatisticsTab> {
  final _dataCtrl = TextEditingController();
  Map<String, String> _stats = {};
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _stats = {};
      try {
        final raw = _dataCtrl.text.trim();
        final data = raw
            .split(RegExp(r'[,\s]+'))
            .where((s) => s.isNotEmpty)
            .map((s) => double.parse(s))
            .toList();
        if (data.isEmpty) throw Exception('No data');

        final sorted = List<double>.from(data)..sort();
        final n = data.length;

        _stats = {
          'Count (n)': n.toString(),
          'Sum': _fmt(data.reduce((a, b) => a + b)),
          'Mean': _fmt(MathEngine.mean(data)),
          'Median': _fmt(MathEngine.median(data)),
          'Mode': _mode(data),
          'Std Dev (σ)': _fmt(MathEngine.stdDev(data)),
          'Variance (σ²)': _fmt(MathEngine.variance(data)),
          'Min': _fmt(sorted.first),
          'Max': _fmt(sorted.last),
          'Range': _fmt(sorted.last - sorted.first),
          'Q1': _fmt(_percentile(sorted, 25)),
          'Q3': _fmt(_percentile(sorted, 75)),
          'IQR': _fmt(_percentile(sorted, 75) - _percentile(sorted, 25)),
        };
      } catch (_) {
        _error = 'Enter comma or space separated numbers\ne.g. 1, 2, 3, 4, 5';
      }
    });
  }

  String _mode(List<double> data) {
    final freq = <double, int>{};
    for (final v in data) {
      freq[v] = (freq[v] ?? 0) + 1;
    }
    final maxFreq = freq.values.reduce((a, b) => a > b ? a : b);
    if (maxFreq == 1) return 'No mode';
    final modes = freq.entries.where((e) => e.value == maxFreq).map((e) => _fmt(e.key));
    return modes.join(', ');
  }

  double _percentile(List<double> sorted, double p) {
    final idx = (p / 100) * (sorted.length - 1);
    final lower = idx.floor();
    final upper = idx.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (idx - lower) * (sorted[upper] - sorted[lower]);
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
          _sectionTitle('Statistics', 'Mean, median, std dev, quartiles & more'),
          const SizedBox(height: 16),
          TextField(
            controller: _dataCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Data',
              hintText: 'e.g. 1, 2, 3, 4, 5, 6',
              alignLabelWithHint: true,
            ),
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
              child: const Text('Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_stats.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: _stats.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: i < _stats.length - 1
                          ? const Border(bottom: BorderSide(color: AppTheme.divider))
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        Text(e.value,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Number Theory Tab ────────────────────────────────────────────────────────

class _NumberTheoryTab extends StatefulWidget {
  const _NumberTheoryTab();

  @override
  State<_NumberTheoryTab> createState() => _NumberTheoryTabState();
}

class _NumberTheoryTabState extends State<_NumberTheoryTab> {
  final _n1Ctrl = TextEditingController(text: '12');
  final _n2Ctrl = TextEditingController(text: '18');
  Map<String, String> _results = {};
  String? _error;

  void _calculate() {
    setState(() {
      _error = null;
      _results = {};
      try {
        final n1 = int.parse(_n1Ctrl.text.trim());
        final n2 = int.parse(_n2Ctrl.text.trim());

        _results = {
          'GCD($n1, $n2)': MathEngine.gcd(n1, n2).toString(),
          'LCM($n1, $n2)': MathEngine.lcm(n1, n2).toString(),
          '$n1 is prime': MathEngine.isPrime(n1) ? 'Yes' : 'No',
          '$n2 is prime': MathEngine.isPrime(n2) ? 'Yes' : 'No',
          'Factors of $n1': MathEngine.primeFactors(n1).join(' × '),
          'Factors of $n2': MathEngine.primeFactors(n2).join(' × '),
          if (n1 >= 0 && n1 <= 20) '$n1! (factorial)': MathEngine.factorial(n1).toString(),
          if (n2 >= 0 && n2 <= 20) '$n2! (factorial)': MathEngine.factorial(n2).toString(),
          if (n1 >= n2) 'P($n1,$n2)': MathEngine.permutation(n1, n2).toString(),
          if (n1 >= n2) 'C($n1,$n2)': MathEngine.combination(n1, n2).toString(),
        };
      } catch (_) {
        _error = 'Enter valid positive integers';
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
          _sectionTitle('Number Theory', 'GCD, LCM, primes, factorials, permutations'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _n1Ctrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'n₁'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _n2Ctrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'n₂'),
                ),
              ),
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
              child: const Text('Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: _results.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: i < _results.length - 1
                          ? const Border(bottom: BorderSide(color: AppTheme.divider))
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(e.key,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 14)),
                        ),
                        Text(e.value,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
