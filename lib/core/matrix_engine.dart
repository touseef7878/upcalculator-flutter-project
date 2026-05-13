import 'dart:math' as math;

/// Optimized matrix engine — minimal allocations, index-based loops throughout.
class MatrixEngine {
  // ─── Basic Operations ─────────────────────────────────────────────────────

  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    _checkSameDims(a, b);
    final rows = a.length, cols = a[0].length;
    return List.generate(rows, (i) {
      final row = List<double>.filled(cols, 0);
      for (int j = 0; j < cols; j++) row[j] = a[i][j] + b[i][j];
      return row;
    });
  }

  static List<List<double>> subtract(List<List<double>> a, List<List<double>> b) {
    _checkSameDims(a, b);
    final rows = a.length, cols = a[0].length;
    return List.generate(rows, (i) {
      final row = List<double>.filled(cols, 0);
      for (int j = 0; j < cols; j++) row[j] = a[i][j] - b[i][j];
      return row;
    });
  }

  static List<List<double>> multiply(List<List<double>> a, List<List<double>> b) {
    final aRows = a.length, aCols = a[0].length, bCols = b[0].length;
    if (aCols != b.length) throw ArgumentError('Incompatible dimensions');
    // Cache-friendly: iterate in row-major order
    final result = List.generate(aRows, (_) => List<double>.filled(bCols, 0));
    for (int i = 0; i < aRows; i++) {
      for (int k = 0; k < aCols; k++) {
        final aik = a[i][k];
        if (aik == 0) continue; // Skip zero multiplications
        for (int j = 0; j < bCols; j++) {
          result[i][j] += aik * b[k][j];
        }
      }
    }
    return result;
  }

  static List<List<double>> scalarMultiply(List<List<double>> a, double scalar) {
    return List.generate(a.length, (i) {
      final row = List<double>.filled(a[0].length, 0);
      for (int j = 0; j < a[0].length; j++) row[j] = a[i][j] * scalar;
      return row;
    });
  }

  static List<List<double>> transpose(List<List<double>> a) {
    final rows = a.length, cols = a[0].length;
    return List.generate(cols, (i) {
      final row = List<double>.filled(rows, 0);
      for (int j = 0; j < rows; j++) row[j] = a[j][i];
      return row;
    });
  }

  // ─── Determinant ──────────────────────────────────────────────────────────

  static double determinant(List<List<double>> matrix) {
    final n = matrix.length;
    if (n == 1) return matrix[0][0];
    if (n == 2) return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    // In-place LU with partial pivoting — no extra matrix allocation
    final u = List.generate(n, (i) => List<double>.from(matrix[i]));
    double det = 1;
    for (int col = 0; col < n; col++) {
      // Find pivot
      int maxRow = col;
      double maxVal = u[col][col].abs();
      for (int row = col + 1; row < n; row++) {
        final v = u[row][col].abs();
        if (v > maxVal) { maxVal = v; maxRow = row; }
      }
      if (maxRow != col) {
        final tmp = u[col]; u[col] = u[maxRow]; u[maxRow] = tmp;
        det = -det;
      }
      if (u[col][col].abs() < 1e-12) return 0;
      det *= u[col][col];
      final pivot = u[col][col];
      for (int row = col + 1; row < n; row++) {
        final factor = u[row][col] / pivot;
        for (int j = col; j < n; j++) u[row][j] -= factor * u[col][j];
      }
    }
    return det;
  }

  // ─── Inverse (Gauss-Jordan) ───────────────────────────────────────────────

  static List<List<double>>? inverse(List<List<double>> matrix) {
    final n = matrix.length;
    if (n != matrix[0].length) return null;
    // Augmented [A | I] — single allocation
    final aug = List.generate(n,
        (i) => List<double>.generate(2 * n, (j) => j < n ? matrix[i][j] : (i == j - n ? 1.0 : 0.0)));
    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      for (int row = col + 1; row < n; row++) {
        if (aug[row][col].abs() > aug[pivotRow][col].abs()) pivotRow = row;
      }
      if (pivotRow != col) {
        final tmp = aug[col]; aug[col] = aug[pivotRow]; aug[pivotRow] = tmp;
      }
      if (aug[col][col].abs() < 1e-12) return null;
      final pivot = aug[col][col];
      for (int j = 0; j < 2 * n; j++) aug[col][j] /= pivot;
      for (int row = 0; row < n; row++) {
        if (row == col) continue;
        final factor = aug[row][col];
        if (factor == 0) continue;
        for (int j = 0; j < 2 * n; j++) aug[row][j] -= factor * aug[col][j];
      }
    }
    return List.generate(n, (i) => aug[i].sublist(n));
  }

  // ─── Eigenvalues ──────────────────────────────────────────────────────────

  static List<double> eigenvalues2x2(List<List<double>> m) {
    final tr = m[0][0] + m[1][1];
    final det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
    final disc = tr * tr - 4 * det;
    if (disc < 0) return [];
    final sqrtDisc = math.sqrt(disc);
    return [(tr + sqrtDisc) / 2, (tr - sqrtDisc) / 2];
  }

  static double dominantEigenvalue(List<List<double>> matrix,
      {int maxIter = 1000, double tol = 1e-10}) {
    final n = matrix.length;
    var v = List<double>.generate(n, (i) => i == 0 ? 1.0 : 0.0);
    double eigenval = 0;
    for (int iter = 0; iter < maxIter; iter++) {
      final av = _matVecMul(matrix, v);
      final norm = _vecNorm(av);
      if (norm < 1e-15) break;
      for (int i = 0; i < n; i++) av[i] /= norm; // In-place normalize
      final newEigen = _dot(av, v);
      if ((newEigen - eigenval).abs() < tol) { eigenval = newEigen; break; }
      eigenval = newEigen;
      v = av;
    }
    return eigenval;
  }

  // ─── Linear System Solver ─────────────────────────────────────────────────

  static List<double>? solveLinearSystem(List<List<double>> a, List<double> b) {
    final n = a.length;
    final aug = List.generate(n, (i) {
      final row = List<double>.filled(n + 1, 0);
      for (int j = 0; j < n; j++) row[j] = a[i][j];
      row[n] = b[i];
      return row;
    });
    for (int col = 0; col < n; col++) {
      int maxRow = col;
      for (int row = col + 1; row < n; row++) {
        if (aug[row][col].abs() > aug[maxRow][col].abs()) maxRow = row;
      }
      if (maxRow != col) {
        final tmp = aug[col]; aug[col] = aug[maxRow]; aug[maxRow] = tmp;
      }
      if (aug[col][col].abs() < 1e-12) return null;
      final pivot = aug[col][col];
      for (int row = col + 1; row < n; row++) {
        final factor = aug[row][col] / pivot;
        if (factor == 0) continue;
        for (int j = col; j <= n; j++) aug[row][j] -= factor * aug[col][j];
      }
    }
    final x = List<double>.filled(n, 0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = aug[i][n];
      for (int j = i + 1; j < n; j++) x[i] -= aug[i][j] * x[j];
      x[i] /= aug[i][i];
    }
    return x;
  }

  // ─── Rank ─────────────────────────────────────────────────────────────────

  static int rank(List<List<double>> matrix) {
    final m = matrix.length, n = matrix[0].length;
    final a = List.generate(m, (i) => List<double>.from(matrix[i]));
    int r = 0;
    for (int col = 0; col < n && r < m; col++) {
      int pivotRow = -1;
      for (int row = r; row < m; row++) {
        if (a[row][col].abs() > 1e-10) { pivotRow = row; break; }
      }
      if (pivotRow == -1) continue;
      final tmp = a[r]; a[r] = a[pivotRow]; a[pivotRow] = tmp;
      final pivot = a[r][col];
      for (int j = 0; j < n; j++) a[r][j] /= pivot;
      for (int row = 0; row < m; row++) {
        if (row == r) continue;
        final factor = a[row][col];
        if (factor == 0) continue;
        for (int j = 0; j < n; j++) a[row][j] -= factor * a[r][j];
      }
      r++;
    }
    return r;
  }

  // ─── Trace & Norm ─────────────────────────────────────────────────────────

  static double trace(List<List<double>> m) {
    double t = 0;
    for (int i = 0; i < m.length; i++) t += m[i][i];
    return t;
  }

  static double frobeniusNorm(List<List<double>> m) {
    double sum = 0;
    for (final row in m) {
      for (final v in row) sum += v * v;
    }
    return math.sqrt(sum);
  }

  // ─── Formatting ───────────────────────────────────────────────────────────

  static String formatMatrix(List<List<double>> m) {
    final buf = StringBuffer();
    for (int i = 0; i < m.length; i++) {
      buf.write('[');
      for (int j = 0; j < m[i].length; j++) {
        if (j > 0) buf.write(', ');
        buf.write(_fmt(m[i][j]));
      }
      buf.write(']');
      if (i < m.length - 1) buf.write('\n');
    }
    return buf.toString();
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e12) return v.toInt().toString();
    final s = v.toStringAsPrecision(6);
    if (s.contains('.')) {
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  static void _checkSameDims(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw ArgumentError('Matrix dimensions do not match');
    }
  }

  /// Index-based mat-vec multiply — no iterator allocations.
  static List<double> _matVecMul(List<List<double>> m, List<double> v) {
    final n = m.length;
    final result = List<double>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < v.length; j++) sum += m[i][j] * v[j];
      result[i] = sum;
    }
    return result;
  }

  static double _vecNorm(List<double> v) {
    double sum = 0;
    for (final x in v) sum += x * x;
    return math.sqrt(sum);
  }

  static double _dot(List<double> a, List<double> b) {
    double s = 0;
    for (int i = 0; i < a.length; i++) s += a[i] * b[i];
    return s;
  }
}
