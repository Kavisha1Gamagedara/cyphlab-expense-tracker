import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/translations.dart';

/// Manages active language state (English 'en' vs Sinhala 'si') across the app
/// with SharedPreferences persistence.
class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language_code';
  final SharedPreferences? _prefs;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isSinhala => _locale.languageCode == 'si';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider([this._prefs]) {
    _initLanguage();
  }

  void _initLanguage() {
    if (_prefs != null) {
      final saved = _prefs.getString(_prefKey);
      if (saved != null && (saved == 'en' || saved == 'si')) {
        _locale = Locale(saved);
      }
    } else {
      _loadSavedAsync();
    }
  }

  Future<void> _loadSavedAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == 'en' || saved == 'si')) {
        _locale = Locale(saved);
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Switch language using language code ('en' or 'si')
  Future<void> setLanguage(String code) async {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }

  /// Switch between English and Sinhala
  void toggleLanguage() {
    setLanguage(isSinhala ? 'en' : 'si');
  }

  /// Get translated text by key
  String getText(String key) {
    return AppTranslations.getText(key, _locale.languageCode);
  }

  /// Shorthand translation method
  String tr(String key) => getText(key);

  /// Get translated category name
  String getCategory(String category) {
    return AppTranslations.getCategoryName(category, _locale.languageCode);
  }
}
