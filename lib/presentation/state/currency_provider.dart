import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../data/models/currency_model.dart';

/// Provider to manage the selected currency across the application,
/// persisted locally via SharedPreferences so choices are remembered across app restarts.
class CurrencyProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_currency_code';
  final SharedPreferences? _prefs;
  CurrencyModel _currentCurrency = kCurrencies.first; // Default USD ($)

  CurrencyModel get currentCurrency => _currentCurrency;
  String get symbol => _currentCurrency.symbol;
  String get code => _currentCurrency.code;
  String get name => _currentCurrency.name;
  String get flag => _currentCurrency.flag;

  CurrencyProvider([this._prefs]) {
    _initCurrency();
  }

  void _initCurrency() {
    if (_prefs != null) {
      final savedCode = _prefs.getString(_prefKey);
      if (savedCode != null) {
        final match = kCurrencies.firstWhere(
          (c) => c.code == savedCode,
          orElse: () => kCurrencies.first,
        );
        _currentCurrency = match;
      }
    } else {
      _loadSavedAsync();
    }
    // Sync initial currency symbol to AppConstants
    AppConstants.currencySymbol = _currentCurrency.symbol;
  }

  Future<void> _loadSavedAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        final match = kCurrencies.firstWhere(
          (c) => c.code == savedCode,
          orElse: () => kCurrencies.first,
        );
        _currentCurrency = match;
        AppConstants.currencySymbol = match.symbol;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[CurrencyProvider] Error loading saved currency: $e');
    }
  }

  /// Change active currency and persist preference
  Future<void> setCurrency(CurrencyModel currency) async {
    if (_currentCurrency.code == currency.code) return;
    _currentCurrency = currency;
    AppConstants.currencySymbol = currency.symbol;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, currency.code);
    } catch (e) {
      debugPrint('[CurrencyProvider] Error saving currency: $e');
    }
  }

  /// Search currencies by code, name, or symbol
  static List<CurrencyModel> filterCurrencies(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return kCurrencies;

    return kCurrencies.where((c) {
      return c.code.toLowerCase().contains(clean) ||
          c.name.toLowerCase().contains(clean) ||
          c.symbol.toLowerCase().contains(clean);
    }).toList();
  }
}
