import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/standard_screen.dart';
import 'screens/scientific_screen.dart';
import 'screens/calculus_screen.dart';
import 'screens/matrix_screen.dart';
import 'screens/numerical_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MathGoatApp());
}

class MathGoatApp extends StatelessWidget {
  const MathGoatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math GOAT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _showSplash = true;
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(icon: Icons.calculate_outlined, activeIcon: Icons.calculate, label: 'Basic'),
    _TabItem(icon: Icons.science_outlined, activeIcon: Icons.science, label: 'Scientific'),
    _TabItem(icon: Icons.functions_outlined, activeIcon: Icons.functions, label: 'Calculus'),
    _TabItem(icon: Icons.grid_on_outlined, activeIcon: Icons.grid_on, label: 'Matrix'),
    _TabItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Numerical'),
  ];

  static const _titles = [
    'Calculator',
    'Scientific',
    'Calculus',
    'Matrix & Linear Algebra',
    'Numerical & Stats',
  ];

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onDone: () => setState(() => _showSplash = false));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.functions, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 20),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          StandardScreen(),
          ScientificScreen(),
          CalculusScreen(),
          MatrixScreen(),
          NumericalScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final i = entry.key;
                final tab = entry.value;
                final selected = _currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _currentIndex = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              selected ? tab.activeIcon : tab.icon,
                              key: ValueKey(selected),
                              color: selected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 2,
                            width: selected ? 20 : 0,
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentAlt],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.functions, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Math GOAT',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Text('v1.0.0 — Fully Offline',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),
            _infoRow(Icons.calculate, 'Basic', 'Standard arithmetic with live evaluation'),
            _infoRow(Icons.science, 'Scientific', 'Trig, logs, powers, constants, factorial'),
            _infoRow(Icons.functions, 'Calculus', 'Derivatives, integrals, limits, Taylor, ODE'),
            _infoRow(Icons.grid_on, 'Matrix', 'Operations, inverse, eigenvalues, linear systems, quadratic'),
            _infoRow(Icons.analytics, 'Numerical', 'Root finding, statistics, number theory'),
            const SizedBox(height: 16),
            const Text(
              'Long-press any result to copy it to clipboard.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentAlt, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('T',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Crafted by Touseef',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text('The mind behind Math GOAT 🐐',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '$title  ',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: desc,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem(
      {required this.icon, required this.activeIcon, required this.label});
}
