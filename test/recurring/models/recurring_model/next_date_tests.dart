import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:money2/money2.dart';

final _account = Account(
  name: 'Swedbank',
  balance: Money.fromInt(100000, code: 'EUR'),
);
final _category = CategoryModel(
  name: 'Food',
  icon: Symbols.restaurant,
);
final _sut = RecurringModel(
  account: _account,
  category: _category,
  money: '10'.toMoney('EUR')!,
  description: null,
  periodicity: Periodicity.day,
  interval: 1,
  from: DateTime.now(),
  until: null,
);

void main() {
  test('upcoming date returned', () {
    // Arrange
    _sut.periodicity = Periodicity.week;
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = null;
    final now = DateTime(2024, 04, 02);

    // Act
    final result = _sut.nextDate(now);

    // Assert
    expect(result, DateTime(2024, 04, 07));
  });

  test('periodic transaction ended, returns null', () {
    // Arrange
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = DateTime(2024, 04, 05);
    final now = DateTime(2024, 04, 10);

    // Act
    final result = _sut.nextDate(now);

    // Assert
    expect(result, null);
  });

  test('payment date is today, returns next date', () {
    // Arrange
    _sut.from = DateTime(2024, 04, 01);
    final now = DateTime(2024, 04, 02);

    // Act
    final result = _sut.nextDate(now);

    // Assert
    expect(result, DateTime(2024, 04, 03));
  });

  test('payment ends today, returns null', () {
    // Arrange
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = DateTime(2024, 04, 02);
    final now = DateTime(2024, 04, 02);

    // Act
    final result = _sut.nextDate(now);

    // Assert
    expect(result, null);
  });
}