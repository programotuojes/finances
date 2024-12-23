import 'package:money2/money2.dart';

final amountValidator = RegExp(r'^\d*[\.,]?\d{0,2}$');

@Deprecated('Use Money.fromFixedWithCurrency() or alternatives')
final zeroEur = Money.fromInt(0, isoCode: 'EUR');

extension MoneyParsing on String {
  @Deprecated('This method has hard coded euros. Use toMoneyWithCurrency() instead.')
  Money? toMoney() {
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
      isoCode: 'EUR',
    );
  }

  Money? toMoneyWithCurrency(Currency currency) {
    try {
      return currency.parse(this);
    } catch (e) {
      return null;
    }
  }
}

extension MyExtensions on Currency {
  Money zero() => Money.fromIntWithCurrency(0, this);
}
