import 'package:finances/extensions/money.dart';
import 'package:flutter/services.dart';

final amountFormatter = [AmountFormatter()];

class AmountFormatter implements TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (amountValidator.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}
