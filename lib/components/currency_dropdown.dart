import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

final _currencies = [
  DropdownMenuEntry(value: CommonCurrencies().euro, label: CommonCurrencies().euro.name),
  DropdownMenuEntry(value: CommonCurrencies().usd, label: CommonCurrencies().usd.name),
  DropdownMenuEntry(value: CommonCurrencies().jpy, label: CommonCurrencies().jpy.name),
];

class CurrencyDropdown extends StatefulWidget {
  final Currency currency;
  final FutureOr<bool> Function(Currency) onChange;

  const CurrencyDropdown({
    super.key,
    required this.currency,
    required this.onChange,
  });

  @override
  State<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  var _key = UniqueKey(); // Needed to re-render the widget in case the user didn't agree to the change

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Currency>(
      key: _key,
      label: const Text('Currency'),
      expandedInsets: EdgeInsets.zero,
      initialSelection: widget.currency,
      dropdownMenuEntries: _currencies,
      onSelected: (currency) async {
        if (currency == null) {
          return;
        }

        var agreed = await widget.onChange(currency);
        if (!agreed) {
          setState(() => _key = UniqueKey());
        }
      },
    );
  }
}
