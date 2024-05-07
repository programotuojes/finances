import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:money2/money2.dart';

final _account = Account(
  id: 0,
  name: 'Swedbank',
  initialMoney: Money.fromInt(100000, code: 'EUR'),
);
final _category = CategoryModel(
  id: 0,
  name: 'Food',
  icon: Symbols.restaurant,
  color: Colors.green,
);
final _sut = RecurringModel(
  account: _account,
  category: _category,
  money: '10'.toMoney()!,
  description: null,
  periodicity: Periodicity.day,
  interval: 1,
  from: DateTime.now(),
  until: null,
  type: TransactionType.expense,
);

void main() {
  test('upcoming date returned', () {
    // Arrange
    _sut.periodicity = Periodicity.week;
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = null;

    // Act
    final result = _sut.nextDate();

    // Assert
    expect(result, DateTime(2024, 04, 07));
  });

  test('periodic transaction ended, returns null', () {
    // Arrange
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = DateTime(2024, 04, 05);

    // Act
    final result = _sut.nextDate();

    // Assert
    expect(result, null);
  });

  test('payment date is today, returns next date', () {
    // Arrange
    _sut.from = DateTime(2024, 04, 01);

    // Act
    final result = _sut.nextDate();

    // Assert
    expect(result, DateTime(2024, 04, 03));
  });

  test('payment ends today, returns null', () {
    // Arrange
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = DateTime(2024, 04, 02);

    // Act
    final result = _sut.nextDate();

    // Assert
    expect(result, null);
  });
}
