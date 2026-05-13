# Contributing to Math GOAT Calculator

First off, thank you for considering contributing to Math GOAT! 🎉

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Device information** (Android version, device model)
- **App version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** — why is this enhancement useful?
- **Proposed solution** — how should it work?
- **Alternatives considered**

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes**
3. **Add tests** if applicable
4. **Ensure tests pass**: `dart verify_scientific.dart`
5. **Update documentation** if needed
6. **Follow the style guide** (see below)
7. **Submit a pull request**

## 📝 Style Guide

### Dart Code Style

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// Good
class MathEngine {
  static double evaluate(String expression) {
    // Implementation
  }
}

// Bad
class mathEngine {
  static double Evaluate(String Expression) {
    // Implementation
  }
}
```

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

Examples:
```
Add support for complex numbers
Fix division by zero error in scientific mode
Update README with installation instructions
```

### Code Organization

- Keep functions small and focused
- Use meaningful variable names
- Add comments for complex logic
- Group related functionality

## 🧪 Testing

Before submitting a PR:

1. **Run the verification test**:
   ```bash
   dart verify_scientific.dart
   ```

2. **Test on a real device**:
   ```bash
   flutter run --release
   ```

3. **Check for analysis issues**:
   ```bash
   flutter analyze
   ```

4. **Format your code**:
   ```bash
   dart format .
   ```

## 📁 Project Structure

```
lib/
├── core/          # Business logic and math engines
├── screens/       # UI screens
├── widgets/       # Reusable widgets
└── theme/         # Theme configuration
```

## 🎯 Areas for Contribution

### High Priority
- [ ] iOS support
- [ ] Unit tests for all math operations
- [ ] Integration tests for UI
- [ ] Performance optimizations

### Medium Priority
- [ ] Graphing calculator mode
- [ ] Unit converter
- [ ] Custom themes
- [ ] Expression history export

### Low Priority
- [ ] Animations improvements
- [ ] Accessibility enhancements
- [ ] Localization (i18n)

## 💡 Development Tips

### Setting Up Development Environment

1. Install Flutter SDK
2. Install Android Studio or VS Code
3. Clone the repository
4. Run `flutter pub get`
5. Run `flutter run`

### Debugging

- Use `print()` statements for quick debugging
- Use Flutter DevTools for advanced debugging
- Check logs: `flutter logs`

### Performance

- Use `const` constructors where possible
- Avoid rebuilding widgets unnecessarily
- Profile with: `flutter run --profile`

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design Guidelines](https://material.io/design)

## ❓ Questions?

Feel free to open an issue with the `question` label or reach out to the maintainer.

## 📜 Code of Conduct

Be respectful, inclusive, and professional. We're all here to learn and build something great together.

---

Thank you for contributing to Math GOAT! 🐐
