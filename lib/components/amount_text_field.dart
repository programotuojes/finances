import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class AmountTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final Currency currency;

  const AmountTextField({
    super.key,
    required this.controller,
    this.labelText = 'Amount',
    this.suffixIcon,
    this.onFieldSubmitted,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an amount';
        }

        if (value.toMoneyWithCurrency(currency) == null) {
          return 'Please enter a valid amount';
        }

        return null;
      },
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: currency.decimalDigits > 0,
      ),
      decoration: InputDecoration(
        prefixText: '${currency.symbol} ',
        labelText: labelText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
