import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

/// Manages the application's ThemeMode (light, dark, or system default)
/// and Material You Google Pixel accent color palettes with SharedPreferences persistence.
class ThemeProvider extends ChangeNotifier {
  static const String _prefThemeModeKey = 'selected_theme_mode';
  static const String _prefPixelColorKey = 'selected_pixel_color';

  final SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  PixelThemeColor _selectedPixelColor = AppTheme.pixelPalettes.first;

  ThemeMode get themeMode => _themeMode;
  PixelThemeColor get selectedPixelColor => _selectedPixelColor;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Dynamic Light Theme using selected Pixel color
  ThemeData get lightTheme => AppTheme.getLightTheme(_selectedPixelColor.primaryColor);

  /// Dynamic Dark Theme using selected Pixel color
  ThemeData get darkTheme => AppTheme.getDarkTheme(_selectedPixelColor.secondaryColor);

  ThemeProvider([this._prefs]) {
    _initTheme();
  }

  void _initTheme() {
    if (_prefs != null) {
      _applyPreferences(_prefs);
    } else {
      _loadSavedAsync();
    }
  }

  void _applyPreferences(SharedPreferences prefs) {
    final savedMode = prefs.getString(_prefThemeModeKey);
    if (savedMode == 'dark') _themeMode = ThemeMode.dark;
    if (savedMode == 'light') _themeMode = ThemeMode.light;
    if (savedMode == 'system') _themeMode = ThemeMode.system;

    final savedColor = prefs.getString(_prefPixelColorKey);
    if (savedColor != null) {
      final match = AppTheme.pixelPalettes.firstWhere(
        (p) => p.name == savedColor,
        orElse: () => AppTheme.pixelPalettes.first,
      );
      _selectedPixelColor = match;
    }
  }

  Future<void> _loadSavedAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _applyPreferences(prefs);
      notifyListeners();
    } catch (_) {}
  }

  /// Toggle between light and dark mode explicitly
  void toggleTheme(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }

  /// Set a specific ThemeMode and persist preference
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final modeStr = mode == ThemeMode.dark
          ? 'dark'
          : (mode == ThemeMode.light ? 'light' : 'system');
      await prefs.setString(_prefThemeModeKey, modeStr);
    } catch (_) {}
  }

  /// Change the Google Pixel accent theme color and persist preference
  Future<void> setPixelColor(PixelThemeColor color) async {
    _selectedPixelColor = color;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_prefPixelColorKey, color.name);
    } catch (_) {}
  }
}

