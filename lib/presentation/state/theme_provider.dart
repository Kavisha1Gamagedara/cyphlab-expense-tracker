import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Manages the application's ThemeMode (light, dark, or system default)
/// and Material You Google Pixel accent color palettes.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  PixelThemeColor _selectedPixelColor = AppTheme.pixelPalettes.first;

  ThemeMode get themeMode => _themeMode;
  PixelThemeColor get selectedPixelColor => _selectedPixelColor;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Dynamic Light Theme using selected Pixel color
  ThemeData get lightTheme => AppTheme.getLightTheme(_selectedPixelColor.primaryColor);

  /// Dynamic Dark Theme using selected Pixel color
  ThemeData get darkTheme => AppTheme.getDarkTheme(_selectedPixelColor.secondaryColor);

  /// Toggle between light and dark mode explicitly
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Set a specific ThemeMode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Change the Google Pixel accent theme color
  void setPixelColor(PixelThemeColor color) {
    _selectedPixelColor = color;
    notifyListeners();
  }
}

