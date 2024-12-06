import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _currentCurrency = "USD";
  final Map<String, double> _conversionRates = {
    "USD": 1.0,
    "EUR": 0.85,
    "IDR": 14000.0,
    "JPY": 140.0,
    "GBP": 0.75,
  };

  List<String> get availableCurrencies => _conversionRates.keys.toList();

  String get currentCurrency => _currentCurrency;

  double getRate(String currency) => _conversionRates[currency] ?? 1.0;

  void changeCurrency(String currency) {
    _currentCurrency = currency;
    notifyListeners();
  }
}
