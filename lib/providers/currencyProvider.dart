import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _currentCurrency = "USD";
  final Map<String, double> _conversionRates = {
    "USD": 1.0,
    "EUR": 0.85,
    "IDR": 14000.0,
    "JPY":
        140.0, // Misalnya, 1 USD = 140 JPY (Anda dapat menyesuaikan nilai tukar sesuai kebutuhan)
    "GBP":
        0.75, // Misalnya, 1 USD = 0.75 GBP (sesuaikan dengan nilai tukar yang tepat)
  };

  List<String> get availableCurrencies => _conversionRates.keys.toList();

  String get currentCurrency => _currentCurrency;

  double getRate(String currency) => _conversionRates[currency] ?? 1.0;

  void changeCurrency(String currency) {
    _currentCurrency = currency;
    notifyListeners();
  }
}
