# 🐐 Math GOAT Calculator

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

**A professional-grade, fully-featured scientific calculator built with Flutter**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 📱 Overview

Math GOAT is a powerful, offline-first scientific calculator that goes beyond basic arithmetic. With 5 specialized calculation modes and 100+ mathematical operations, it's designed for students, engineers, scientists, and anyone who needs advanced mathematical capabilities on the go.

### ✨ Why Math GOAT?

- 🚀 **Lightning Fast** — Instant calculations with optimized algorithms
- 🎨 **Beautiful UI** — Modern dark theme with smooth animations
- 📴 **100% Offline** — No internet required, works anywhere
- 🧮 **Professional Grade** — Accurate to 10+ decimal places
- 🔧 **Smart Features** — Auto-close brackets, live evaluation, expression history
- 🎯 **Zero Crashes** — Comprehensive error handling and validation

---

## 🎯 Features

### 🔢 Standard Calculator
- Basic arithmetic operations (+, -, ×, ÷)
- Live evaluation as you type
- Expression history with copy-to-clipboard
- Clean, intuitive interface

### 🔬 Scientific Calculator
- **Trigonometry**: sin, cos, tan, asin, acos, atan (DEG/RAD modes)
- **Hyperbolic Functions**: sinh, cosh, tanh
- **Logarithms**: log10, ln, log2
- **Exponentials**: exp, powers (x², xⁿ)
- **Roots**: √ (square root), ∛ (cube root)
- **Constants**: π (pi), e (Euler's number)
- **Special Functions**: factorial (!), absolute value (|x|), modulo
- **Smart Input**: Auto-close brackets, smart backspace
- **Inverse Mode**: Toggle between forward and inverse functions

### 📐 Calculus
- **Derivatives**: 1st and 2nd order numerical derivatives
- **Integrals**: Definite integrals using Simpson's rule
- **Limits**: Numerical limit calculation
- **Taylor Series**: Polynomial expansion around any point
- **ODE Solvers**: Euler method and Runge-Kutta 4th order

### 🔲 Matrix & Linear Algebra
- **Matrix Operations**: Add, subtract, multiply, transpose
- **Advanced Operations**: Determinant, inverse, eigenvalues
- **Linear Systems**: Solve systems of linear equations
- **Quadratic Solver**: Find roots of quadratic equations

### 📊 Numerical & Statistics
- **Root Finding**: Newton-Raphson and Bisection methods
- **Statistics**: Mean, median, variance, standard deviation
- **Number Theory**: Prime checking, GCD, LCM, prime factorization
- **Combinatorics**: Permutations and combinations

---

## � Installation

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 21+)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/touseef7878/upcalculator-flutter-project.git
   cd upcalculator-flutter-project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode (recommended for best performance)
   flutter run --release
   ```

4. **Build APK**
   ```bash
   flutter build apk --release
   ```
   APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

## 💻 Usage

### Key Features
- **Auto-Close Brackets**: Press `=` to automatically close all open parentheses
- **Smart Backspace**: Removes entire function names intelligently
- **Copy Results**: Long-press any result to copy to clipboard
- **DEG/RAD Toggle**: Switch between degrees and radians for trigonometric functions
- **INV Mode**: Access inverse functions (asin, acos, atan)
- **Live Evaluation**: See results update in real-time as you type

---

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # App entry point & navigation
├── core/
│   ├── math_engine.dart        # Scientific calculator engine
│   └── matrix_engine.dart      # Matrix operations engine
├── screens/
│   ├── standard_screen.dart    # Basic calculator UI
│   ├── scientific_screen.dart  # Scientific calculator UI
│   ├── calculus_screen.dart    # Calculus operations UI
│   ├── matrix_screen.dart      # Matrix & linear algebra UI
│   ├── numerical_screen.dart   # Numerical & statistics UI
│   └── splash_screen.dart      # Animated splash screen
├── widgets/
│   ├── calc_button.dart        # Reusable button widget
│   └── display_panel.dart      # Expression/result display
└── theme/
    └── app_theme.dart          # Dark theme configuration
```

### Tech Stack
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **Architecture**: Clean Architecture with separation of concerns
- **State Management**: StatefulWidget with setState
- **Math Engine**: Custom recursive descent parser
- **Dependencies**: Minimal (only `math_expressions` for basic parsing)

### Key Components

#### Math Engine (`lib/core/math_engine.dart`)
- Custom recursive descent parser for scientific expressions
- Supports all standard mathematical functions
- Handles operator precedence and associativity
- Comprehensive error handling and domain validation
- Expression caching for improved performance

#### Matrix Engine (`lib/core/matrix_engine.dart`)
- Gaussian elimination for linear systems
- LU decomposition for matrix operations
- Power iteration for eigenvalue calculation
- Optimized algorithms for large matrices

---

## 🧪 Testing

### Run Tests
```bash
# Run verification test
dart verify_scientific.dart

# Expected output: 57/57 tests passed ✅
```

### Test Coverage
- ✅ Basic arithmetic (6 tests)
- ✅ Trigonometry (12 tests)
- ✅ Hyperbolic functions (3 tests)
- ✅ Logarithms & exponentials (6 tests)
- ✅ Roots & powers (8 tests)
- ✅ Special functions (7 tests)
- ✅ Complex expressions (5 tests)
- ✅ Nested functions (3 tests)
- ✅ Operator precedence (4 tests)

**Total: 57/57 tests passing** 🎉

---

## 🎨 Design

### Theme
- **Color Scheme**: Professional dark theme
  - Background: `#0D0D0D`
  - Surface: `#1A1A1A`
  - Accent: `#8B5CF6` (Purple) → `#3B82F6` (Blue) gradient
- **Typography**: Clean, readable fonts with proper hierarchy
- **Animations**: Smooth transitions and haptic feedback

### UX Principles
- **Immediate Feedback**: Live evaluation as you type
- **Error Prevention**: Smart input validation
- **Discoverability**: Clear mode indicators and visual cues
- **Efficiency**: Keyboard shortcuts and smart features

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Development Guidelines
- Follow Dart style guide
- Add tests for new features
- Update documentation
- Ensure all tests pass before submitting PR

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Touseef Ur Rehman** — Computer Science Student

- GitHub: [@touseef7878](https://github.com/touseef7878)
- LinkedIn: [Touseef Ur Rehman](https://www.linkedin.com/in/touseef-ur-rehman-6b2888372)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Dart team for the powerful language
- Open source community for inspiration

---

## 📊 Stats

- **Lines of Code**: ~3,000+
- **Mathematical Operations**: 100+
- **Test Coverage**: 57 verified operations
- **Build Size**: 46.2 MB (release APK)
- **Minimum Android**: API 21 (Android 5.0)

---

## 📞 Support

Found a bug or have a feature request? Please [open an issue](https://github.com/touseef7878/upcalculator-flutter-project/issues).

---

<div align="center">

**Made with ❤️ and Flutter**

If you found this project helpful, please give it a ⭐️!

[⬆ Back to Top](#-math-goat-calculator)

</div>
