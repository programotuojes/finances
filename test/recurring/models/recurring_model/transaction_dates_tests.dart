import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
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
  test('period calculated', () {
    // Arrange
    _sut.interval = 2;
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = DateTime(2024, 04, 04);

    // Act
    final result = _sut.transactionDates;

    // Assert
    expect(result.length, 2);
  });

  test('included if ends on the same day', () {
    // Arrange
    _sut.interval = 2;
    _sut.from = DateTime(2024, 04, 01);
    _sut.until = DateTime(2024, 04, 05);

    // Act
    final periods = _sut.transactionDates;

    // Assert
    expect(periods.length, 3);
    expect(periods.last, _sut.until);
  });

  test('weekly transactions happen on the same day', () {
    // Arrange
    _sut.interval = 1;
    _sut.periodicity = Periodicity.week;
    _sut.from = DateTime(2020, 01, 01);
    _sut.until = DateTime(2020, 12, 31);

    // Act
    final result = _sut.transactionDates;

    // Assert
    for (var x in result) {
      expect(x.weekday, 3, reason: 'checking $x');
    }
    expect(result.length, 53);
  });

  test('monthly transactions happen on the same day', () {
    // Arrange
    _sut.interval = 1;
    _sut.periodicity = Periodicity.month;
    _sut.from = DateTime(2024, 01, 01);
    _sut.until = DateTime(2024, 12, 01);

    // Act
    final result = _sut.transactionDates;

    // Assert
    for (var x in result) {
      expect(x.day, 01, reason: 'checking $x');
    }
    expect(result.length, 12);
  });

  test('yearly transactions happen on the same day', () {
    // Arrange
    _sut.interval = 1;
    _sut.periodicity = Periodicity.year;
    _sut.from = DateTime(2000, 01, 01);
    _sut.until = DateTime(2024, 01, 01);

    // Act
    final result = _sut.transactionDates;

    // Assert
    for (var x in result) {
      expect(x.day, 01, reason: 'checking $x');
    }
    expect(result.length, 25);
  });
}
