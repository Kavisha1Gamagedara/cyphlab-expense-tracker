import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/models/currency_model.dart';

/// Provider to manage the selected currency across the application.
class CurrencyProvider extends ChangeNotifier {
  CurrencyModel _currentCurrency = kCurrencies.first; // Default USD ($)

  CurrencyModel get currentCurrency => _currentCurrency;
  String get symbol => _currentCurrency.symbol;
  String get code => _currentCurrency.code;
  String get name => _currentCurrency.name;
  String get flag => _currentCurrency.flag;

  CurrencyProvider() {
    // Sync initial default currency symbol to AppConstants
    AppConstants.currencySymbol = _currentCurrency.symbol;
  }

  /// Change active currency
  void setCurrency(CurrencyModel currency) {
    if (_currentCurrency.code == currency.code) return;
    _currentCurrency = currency;
    AppConstants.currencySymbol = currency.symbol;
    notifyListeners();
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
