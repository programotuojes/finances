import 'package:money2/money2.dart';

extension MoneyParsing on String {
  Money toMoney(String code) {
    var minor = replaceAll(RegExp('[.,]'), '');

    return Money.fromInt(
      int.parse(minor),
      code: code,
    );
  }
}
