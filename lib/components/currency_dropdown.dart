import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

final _currencies = [
  DropdownMenuEntry(value: CommonCurrencies().euro, label: CommonCurrencies().euro.name),
  DropdownMenuEntry(value: CommonCurrencies().usd, label: CommonCurrencies().usd.name),
  DropdownMenuEntry(value: CommonCurrencies().jpy, label: CommonCurrencies().jpy.name),
];

class CurrencyDropdown extends StatelessWidget {
  final Currency currency;
  final Function(Currency) onChange;

  const CurrencyDropdown({
    super.key,
    required this.currency,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Currency>(
      label: const Text('Currency'),
      expandedInsets: EdgeInsets.zero,
      initialSelection: currency,
      dropdownMenuEntries: _currencies,
      onSelected: (currency) {
        if (currency == null) {
          return;
        }

        onChange(currency);
      },
    );
  }
}
