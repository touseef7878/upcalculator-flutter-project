import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

/// Professional math engine.
/// Scientific functions (sin, cos, log, etc.) are evaluated directly via dart:math
/// — no external parser involved, so they always work correctly.
class MathEngine {
  // ─── Parser (used only for arithmetic expressions with +,-,*,/,^) ─────────
  static final GrammarParser _parser = GrammarParser();
  static final ContextModel _ctx = ContextModel();
  static final _cache = <String, Expression>{};

  static Expression _parse(String expr) {
    final c = _cache[expr];
    if (c != null) return c;
    final p = _parser.parse(expr);
    if (_cache.length >= 256) _cache.remove(_cache.keys.first);
    _cache[expr] = p;
    return p;
  }

  // ─── Simple arithmetic evaluate (for standard/calculus screens) ───────────
  static double evaluate(String expression) {
    final s = _prepareArith(expression);
    return _parse(s).evaluate(EvaluationType.REAL, _ctx) as double;
  }

  /// Prepare expression for the arithmetic parser.
  /// Only handles: +  -  *  /  ^  ()  numbers  and the variable x
  static String _prepareArith(String expr) {
    return expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '${math.pi}')
        .replaceAll(RegExp(r'\be\b'), '${math.e}');
  }

  // ─── Scientific evaluate — pure Dart, always correct ─────────────────────

  /// Evaluate a scientific expression string.
  /// Supports: sin cos tan asin acos atan sinh cosh tanh
  ///           sqrt cbrt abs log log10 ln exp
  ///           ^ * / + - ( )  numbers  π  e
  /// [degrees]: if true, trig input is degrees, inverse trig output is degrees
  static double evalSci(String raw, {bool degrees = true}) {
    if (raw.trim().isEmpty) return 0;

    // Handle factorial: "5!" → 120
    if (raw.trim().endsWith('!')) {
      final inner = raw.trim().replaceAll('!', '').trim();
      final n = int.tryParse(inner);
      if (n != null && n >= 0 && n <= 20) return factorial(n).toDouble();
      throw Exception('Invalid factorial');
    }

    // Handle mod: "10 mod 3"
    if (raw.contains(' mod ')) {
      final p = raw.split(' mod ');
      final a = evalSci(p[0].trim(), degrees: degrees);
      final b = evalSci(p[1].trim(), degrees: degrees);
      if (b == 0) throw Exception('mod by zero');
      return a % b;
    }

    final tokens = _tokenize(raw);
    final result = _parseExpr(tokens, 0, degrees);
    if (result.pos != tokens.length) throw Exception('Unexpected token');
    return result.value;
  }

  // ─── Tokenizer ────────────────────────────────────────────────────────────

  static List<_Token> _tokenize(String s) {
    final tokens = <_Token>[];
    int i = 0;
    while (i < s.length) {
      final ch = s[i];

      // Skip spaces
      if (ch == ' ') { i++; continue; }

      // Numbers (including decimals and scientific notation like 1.5e10)
      if (_isDigit(ch) || (ch == '.' && i + 1 < s.length && _isDigit(s[i + 1]))) {
        final start = i;
        while (i < s.length && (_isDigit(s[i]) || s[i] == '.')) i++;
        if (i < s.length && (s[i] == 'e' || s[i] == 'E')) {
          i++;
          if (i < s.length && (s[i] == '+' || s[i] == '-')) i++;
          while (i < s.length && _isDigit(s[i])) i++;
        }
        tokens.add(_Token(_TType.number, s.substring(start, i)));
        continue;
      }

      if (ch == 'π') {
        tokens.add(_Token(_TType.number, '${math.pi}'));
        i++; continue;
      }

      if (ch == '+') { tokens.add(_Token(_TType.plus, '+')); i++; continue; }
      if (ch == '-') { tokens.add(_Token(_TType.minus, '-')); i++; continue; }
      if (ch == '*' || ch == '×') { tokens.add(_Token(_TType.mul, '*')); i++; continue; }
      if (ch == '/' || ch == '÷') { tokens.add(_Token(_TType.div, '/')); i++; continue; }
      if (ch == '^') { tokens.add(_Token(_TType.pow, '^')); i++; continue; }
      if (ch == '(') { tokens.add(_Token(_TType.lparen, '(')); i++; continue; }
      if (ch == ')') { tokens.add(_Token(_TType.rparen, ')')); i++; continue; }
      if (ch == '!') { tokens.add(_Token(_TType.factorial, '!')); i++; continue; }
      if (ch == '%') { tokens.add(_Token(_TType.percent, '%')); i++; continue; }

      // Identifiers (function names and constants)
      if (_isAlpha(ch)) {
        final start = i;
        while (i < s.length && (_isAlpha(s[i]) || _isDigit(s[i]))) i++;
        tokens.add(_Token(_TType.ident, s.substring(start, i)));
        continue;
      }

      throw Exception('Unknown character: $ch');
    }
    return tokens;
  }

  // ─── Recursive descent parser ─────────────────────────────────────────────

  static _Result _parseExpr(List<_Token> t, int pos, bool deg) =>
      _parseAddSub(t, pos, deg);

  static _Result _parseAddSub(List<_Token> t, int pos, bool deg) {
    var r = _parseMulDiv(t, pos, deg);
    while (r.pos < t.length &&
        (t[r.pos].type == _TType.plus || t[r.pos].type == _TType.minus)) {
      final op = t[r.pos].type;
      final right = _parseMulDiv(t, r.pos + 1, deg);
      r = _Result(
          op == _TType.plus ? r.value + right.value : r.value - right.value,
          right.pos);
    }
    return r;
  }

  static _Result _parseMulDiv(List<_Token> t, int pos, bool deg) {
    var r = _parsePow(t, pos, deg);
    while (r.pos < t.length &&
        (t[r.pos].type == _TType.mul || t[r.pos].type == _TType.div)) {
      final op = t[r.pos].type;
      final right = _parsePow(t, r.pos + 1, deg);
      if (op == _TType.div && right.value == 0) throw Exception('Division by zero');
      r = _Result(
          op == _TType.mul ? r.value * right.value : r.value / right.value,
          right.pos);
    }
    return r;
  }

  static _Result _parsePow(List<_Token> t, int pos, bool deg) {
    var r = _parseUnary(t, pos, deg);
    if (r.pos < t.length && t[r.pos].type == _TType.pow) {
      // Right-associative
      final right = _parsePow(t, r.pos + 1, deg);
      return _Result(math.pow(r.value, right.value).toDouble(), right.pos);
    }
    return r;
  }

  static _Result _parseUnary(List<_Token> t, int pos, bool deg) {
    if (pos < t.length && t[pos].type == _TType.minus) {
      final r = _parseUnary(t, pos + 1, deg);
      return _Result(-r.value, r.pos);
    }
    if (pos < t.length && t[pos].type == _TType.plus) {
      return _parseUnary(t, pos + 1, deg);
    }
    return _parsePostfix(t, pos, deg);
  }

  static _Result _parsePostfix(List<_Token> t, int pos, bool deg) {
    var r = _parsePrimary(t, pos, deg);
    while (r.pos < t.length) {
      if (t[r.pos].type == _TType.factorial) {
        final n = r.value.round();
        if (n < 0 || n > 20) throw Exception('Factorial out of range');
        r = _Result(factorial(n).toDouble(), r.pos + 1);
      } else if (t[r.pos].type == _TType.percent) {
        r = _Result(r.value / 100, r.pos + 1);
      } else {
        break;
      }
    }
    return r;
  }

  static _Result _parsePrimary(List<_Token> t, int pos, bool deg) {
    if (pos >= t.length) throw Exception('Unexpected end');

    final tok = t[pos];

    // Number literal
    if (tok.type == _TType.number) {
      return _Result(double.parse(tok.value), pos + 1);
    }

    // Parenthesised expression
    if (tok.type == _TType.lparen) {
      final r = _parseExpr(t, pos + 1, deg);
      if (r.pos >= t.length || t[r.pos].type != _TType.rparen) {
        throw Exception('Missing )');
      }
      return _Result(r.value, r.pos + 1);
    }

    // Identifier: function call or constant
    if (tok.type == _TType.ident) {
      final name = tok.value.toLowerCase();

      // Constants
      if (name == 'pi' || name == 'π') return _Result(math.pi, pos + 1);
      if (name == 'e') return _Result(math.e, pos + 1);
      if (name == 'inf') return _Result(double.infinity, pos + 1);

      // Function call: name(arg)
      if (pos + 1 < t.length && t[pos + 1].type == _TType.lparen) {
        final argR = _parseExpr(t, pos + 2, deg);
        if (argR.pos >= t.length || t[argR.pos].type != _TType.rparen) {
          throw Exception('Missing ) after $name');
        }
        final arg = argR.value;
        final nextPos = argR.pos + 1;
        final v = _applyFunc(name, arg, deg);
        return _Result(v, nextPos);
      }

      throw Exception('Unknown identifier: $name');
    }

    throw Exception('Unexpected token: ${tok.value}');
  }

  /// Apply a named function to its argument.
  static double _applyFunc(String name, double arg, bool deg) {
    switch (name) {
      // Trig — input in degrees if deg mode
      case 'sin':
        final a = deg ? arg * math.pi / 180 : arg;
        final r = math.sin(a);
        return _cleanTrig(r);
      case 'cos':
        final a = deg ? arg * math.pi / 180 : arg;
        final r = math.cos(a);
        return _cleanTrig(r);
      case 'tan':
        final a = deg ? arg * math.pi / 180 : arg;
        // tan(90°) = undefined
        if (deg && (arg % 180 - 90).abs() < 1e-10) throw Exception('tan undefined');
        return _cleanTrig(math.tan(a));

      // Inverse trig — output in degrees if deg mode
      case 'asin':
        if (arg < -1 || arg > 1) throw Exception('asin domain error');
        final r = math.asin(arg);
        return deg ? r * 180 / math.pi : r;
      case 'acos':
        if (arg < -1 || arg > 1) throw Exception('acos domain error');
        final r = math.acos(arg);
        return deg ? r * 180 / math.pi : r;
      case 'atan':
        final r = math.atan(arg);
        return deg ? r * 180 / math.pi : r;

      // Hyperbolic
      case 'sinh': return (math.exp(arg) - math.exp(-arg)) / 2;
      case 'cosh': return (math.exp(arg) + math.exp(-arg)) / 2;
      case 'tanh':
        final e2 = math.exp(2 * arg);
        return (e2 - 1) / (e2 + 1);

      // Roots
      case 'sqrt':
        if (arg < 0) throw Exception('sqrt of negative');
        return math.sqrt(arg);
      case 'cbrt':
        return arg >= 0 ? math.pow(arg, 1/3).toDouble()
                        : -math.pow(-arg, 1/3).toDouble();

      // Logs & exp
      case 'log':   // natural log
      case 'ln':
        if (arg <= 0) throw Exception('log domain error');
        return math.log(arg);
      case 'log10':
        if (arg <= 0) throw Exception('log10 domain error');
        return math.log(arg) / math.ln10;
      case 'log2':
        if (arg <= 0) throw Exception('log2 domain error');
        return math.log(arg) / math.ln2;
      case 'exp':
        return math.exp(arg);

      // Other
      case 'abs':   return arg.abs();
      case 'ceil':  return arg.ceilToDouble();
      case 'floor': return arg.floorToDouble();
      case 'round': return arg.roundToDouble();
      case 'sign':  return arg == 0 ? 0 : (arg > 0 ? 1 : -1);

      default: throw Exception('Unknown function: $name');
    }
  }

  /// Clean near-zero trig results (e.g. sin(180°) = 1.2e-16 → 0)
  static double _cleanTrig(double v) => v.abs() < 1e-10 ? 0 : v;

  // ─── Quadratic ────────────────────────────────────────────────────────────

  static List<String> solveQuadratic(double a, double b, double c) {
    if (a == 0) {
      if (b == 0) return c == 0 ? ['Infinite solutions'] : ['No solution'];
      return [_fmt(-c / b)];
    }
    final disc = b * b - 4 * a * c;
    if (disc > 0) {
      final sq = math.sqrt(disc);
      return [_fmt((-b + sq) / (2 * a)), _fmt((-b - sq) / (2 * a))];
    } else if (disc == 0) {
      return [_fmt(-b / (2 * a))];
    } else {
      final real = -b / (2 * a);
      final imag = math.sqrt(-disc) / (2 * a);
      return ['${_fmt(real)} + ${_fmt(imag)}i', '${_fmt(real)} − ${_fmt(imag)}i'];
    }
  }

  // ─── Calculus (uses evalSci for x-substitution) ───────────────────────────

  static double derivative(String expression, double x, {double h = 1e-7}) =>
      (_evalAt(expression, x + h) - _evalAt(expression, x - h)) / (2 * h);

  static double secondDerivative(String expression, double x, {double h = 1e-5}) {
    final f0 = _evalAt(expression, x);
    return (_evalAt(expression, x + h) - 2 * f0 + _evalAt(expression, x - h)) / (h * h);
  }

  static double integrate(String expression, double a, double b, {int n = 200}) {
    if (n % 2 != 0) n++;
    final h = (b - a) / n;
    double sum = _evalAt(expression, a) + _evalAt(expression, b);
    for (int i = 1; i < n; i++) {
      sum += (i % 2 == 0 ? 2 : 4) * _evalAt(expression, a + i * h);
    }
    return sum * h / 3;
  }

  static double limit(String expression, double target, {double h = 1e-9}) {
    final left = _evalAt(expression, target - h);
    final right = _evalAt(expression, target + h);
    if ((left - right).abs() < 1e-6) return (left + right) / 2;
    return double.nan;
  }

  static String taylorSeries(String expression, double a, int order) {
    final terms = <String>[];
    double fact = 1;
    for (int n = 0; n <= order; n++) {
      if (n > 0) fact *= n;
      final coeff = _nthDeriv(expression, a, n) / fact;
      if (coeff.abs() < 1e-12) continue;
      final cs = _fmt(coeff);
      if (n == 0) {
        terms.add(cs);
      } else if (n == 1) {
        terms.add('$cs(x${a != 0 ? '−${_fmt(a)}' : ''})');
      } else {
        terms.add('$cs(x${a != 0 ? '−${_fmt(a)}' : ''})^$n');
      }
    }
    return terms.isEmpty ? '0' : terms.join(' + ');
  }

  static double _nthDeriv(String expr, double x, int n) {
    if (n == 0) return _evalAt(expr, x);
    if (n == 1) {
      const h = 1e-7;
      return (_evalAt(expr, x + h) - _evalAt(expr, x - h)) / (2 * h);
    }
    const h = 1e-4;
    double sum = 0;
    for (int k = 0; k <= n; k++) {
      final sign = (k % 2 == 0) ? 1.0 : -1.0;
      sum += sign * _binomCoeff(n, k) * _evalAt(expr, x + (n - 2 * k) * h);
    }
    return sum / math.pow(h, n);
  }

  static int _binomCoeff(int n, int k) {
    if (k == 0 || k == n) return 1;
    int r = 1;
    for (int i = 0; i < k; i++) r = r * (n - i) ~/ (i + 1);
    return r;
  }

  // ─── Numerical methods ────────────────────────────────────────────────────

  static double newtonRaphson(String expression, double x0,
      {int maxIter = 100, double tol = 1e-12}) {
    double x = x0;
    for (int i = 0; i < maxIter; i++) {
      final fx = _evalAt(expression, x);
      if (fx.abs() < tol) return x;
      final fpx = derivative(expression, x);
      if (fpx.abs() < 1e-15) break;
      final xn = x - fx / fpx;
      if ((xn - x).abs() < tol) return xn;
      x = xn;
    }
    return x;
  }

  static double bisection(String expression, double a, double b,
      {int maxIter = 100, double tol = 1e-12}) {
    double fa = _evalAt(expression, a);
    for (int i = 0; i < maxIter; i++) {
      final mid = (a + b) / 2;
      final fm = _evalAt(expression, mid);
      if (fm.abs() < tol || (b - a) / 2 < tol) return mid;
      if (fa * fm < 0) { b = mid; } else { a = mid; fa = fm; }
    }
    return (a + b) / 2;
  }

  static List<List<double>> eulerMethod(
      String expr, double x0, double y0, double xEnd, int steps) {
    final h = (xEnd - x0) / steps;
    final pts = <List<double>>[[x0, y0]];
    double x = x0, y = y0;
    for (int i = 0; i < steps; i++) {
      y += h * _evalXY(expr, x, y);
      x += h;
      pts.add([x, y]);
    }
    return pts;
  }

  static List<List<double>> rungeKutta4(
      String expr, double x0, double y0, double xEnd, int steps) {
    final h = (xEnd - x0) / steps;
    final pts = <List<double>>[[x0, y0]];
    double x = x0, y = y0;
    for (int i = 0; i < steps; i++) {
      final k1 = _evalXY(expr, x, y);
      final k2 = _evalXY(expr, x + h / 2, y + h * k1 / 2);
      final k3 = _evalXY(expr, x + h / 2, y + h * k2 / 2);
      final k4 = _evalXY(expr, x + h, y + h * k3);
      y += h * (k1 + 2 * k2 + 2 * k3 + k4) / 6;
      x += h;
      pts.add([x, y]);
    }
    return pts;
  }

  // ─── Statistics ───────────────────────────────────────────────────────────

  static double mean(List<double> data) {
    double s = 0;
    for (final v in data) s += v;
    return s / data.length;
  }

  static double median(List<double> data) {
    final s = List<double>.from(data)..sort();
    final n = s.length;
    return n % 2 == 0 ? (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2 : s[n ~/ 2];
  }

  static double variance(List<double> data) {
    double m = 0, m2 = 0;
    for (int i = 0; i < data.length; i++) {
      final d = data[i] - m;
      m += d / (i + 1);
      m2 += d * (data[i] - m);
    }
    return m2 / data.length;
  }

  static double stdDev(List<double> data) => math.sqrt(variance(data));

  // ─── Number theory ────────────────────────────────────────────────────────

  static bool isPrime(int n) {
    if (n < 2) return false;
    if (n == 2 || n == 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
      if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
  }

  static int gcd(int a, int b) {
    a = a.abs(); b = b.abs();
    while (b != 0) { final t = b; b = a % b; a = t; }
    return a;
  }

  static int lcm(int a, int b) => (a ~/ gcd(a, b)) * b;

  static List<int> primeFactors(int n) {
    final f = <int>[];
    while (n % 2 == 0) { f.add(2); n ~/= 2; }
    for (int i = 3; i * i <= n; i += 2)
      while (n % i == 0) { f.add(i); n ~/= i; }
    if (n > 1) f.add(n);
    return f;
  }

  static const _factTable = [
    1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800,
    39916800, 479001600, 6227020800, 87178291200, 1307674368000,
    20922789888000, 355687428096000, 6402373705728000,
    121645100408832000, 2432902008176640000,
  ];

  static int factorial(int n) {
    if (n < 0) throw ArgumentError('Factorial undefined for negative');
    if (n <= 20) return _factTable[n];
    int r = _factTable[20];
    for (int i = 21; i <= n; i++) r *= i;
    return r;
  }

  static int permutation(int n, int r) {
    if (r > n) throw ArgumentError('r > n');
    int res = 1;
    for (int i = n; i > n - r; i--) res *= i;
    return res;
  }

  static int combination(int n, int r) {
    if (r > n) throw ArgumentError('r > n');
    if (r > n - r) r = n - r;
    int res = 1;
    for (int i = 0; i < r; i++) res = res * (n - i) ~/ (i + 1);
    return res;
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  static double _evalAt(String expression, double x) {
    try {
      final s = expression.replaceAll('x', '($x)');
      return evalSci(s, degrees: false);
    } catch (_) { return double.nan; }
  }

  static double _evalXY(String expression, double x, double y) {
    try {
      final s = expression
          .replaceAll('y', '($y)')
          .replaceAll('x', '($x)');
      return evalSci(s, degrees: false);
    } catch (_) { return double.nan; }
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || c == '_';
  }

  static String _fmt(double v) {
    if (v.isNaN) return 'NaN';
    if (v.isInfinite) return v > 0 ? '∞' : '-∞';
    if (v == v.truncateToDouble() && v.abs() < 1e15) return v.toInt().toString();
    final s = v.toStringAsPrecision(10);
    if (s.contains('.')) {
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}

// ─── Token types ──────────────────────────────────────────────────────────────

enum _TType { number, ident, plus, minus, mul, div, pow, lparen, rparen, factorial, percent }

class _Token {
  final _TType type;
  final String value;
  const _Token(this.type, this.value);
}

class _Result {
  final double value;
  final int pos;
  const _Result(this.value, this.pos);
}
