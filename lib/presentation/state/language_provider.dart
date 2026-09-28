import 'package:flutter/material.dart';
import '../../core/translations.dart';

/// Manages active language state (English 'en' vs Sinhala 'si') across the app
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isSinhala => _locale.languageCode == 'si';
  bool get isEnglish => _locale.languageCode == 'en';

  /// Switch language using language code ('en' or 'si')
  void setLanguage(String code) {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    notifyListeners();
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
