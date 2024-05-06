import 'package:finances/utils/amount_input_formatter.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

class AmountTextField extends StatelessWidget {
  final TextEditingController controller;

  const AmountTextField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '€ ',
      ),
    );
  }
}
