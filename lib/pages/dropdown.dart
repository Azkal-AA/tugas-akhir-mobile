import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currencyProvider.dart';

class CurrencyDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Currency: ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: currencyProvider.currentCurrency,
          items: currencyProvider.availableCurrencies
              .map((currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              currencyProvider.changeCurrency(value);
            }
          },
        ),
      ],
    );
  }
}
