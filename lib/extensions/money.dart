import 'package:money2/money2.dart';

final amountValidator = RegExp(r'^\d*[\.,]?\d{0,2}$');

extension MoneyParsing on String {
  Money? toMoney(String code) {
    if (isEmpty) {
      return null;
    }

    if (!amountValidator.hasMatch(this)) {
      return null;
    }

    var parts = split(RegExp(r'[\.,]'));
    var major = (int.tryParse(parts[0]) ?? 0) * 100;
    var minor = 0;

    if (parts.length > 1) {
      minor = int.parse(parts[1].padRight(2, '0'));
    }

    return Money.fromInt(
      major + minor,
      code: code,
    );
  }
}
