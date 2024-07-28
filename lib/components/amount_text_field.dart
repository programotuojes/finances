import 'package:finances/utils/amount_input_formatter.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

class AmountTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;

  const AmountTextField({
    super.key,
    required this.controller,
    this.labelText = 'Amount',
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an amount';
        }

        if (value.toMoney() == null) {
          return 'Please enter a valid amount';
        }

        return null;
      },
      controller: controller,
      inputFormatters: amountFormatter,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        prefixText: '€ ',
        labelText: labelText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
