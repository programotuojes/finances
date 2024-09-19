import 'package:finances/account/models/account.dart';
import 'package:finances/account/pages/edit.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/IconPicker/Packs/MaterialDefault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money2/money2.dart';

final _testAccount = Account(name: 'Test', initialMoney: zeroEur);

final _category = CategoryModel(
  name: 'Other',
  color: const Color(0xffffffff),
  icon: defaultIcons['home']!,
);

void main() {
  test('Has expense', () {
    // Arrange
    final expenses = [
      Expense(
        transaction: Transaction(
          account: _testAccount,
          dateTime: DateTime.now(),
          type: TransactionType.expense,
        ),
        money: Money.parse('1', isoCode: 'EUR'),
        category: _category,
        description: null,
      ),
    ];

    // Act
    final result = calculateInitialAmount(zeroEur, expenses, [], _testAccount);

    // Assert
    expect(result.toDouble(), 1);
  });

  test('Has income', () {
    // Arrange
    final expenses = [
      Expense(
        transaction: Transaction(
          account: _testAccount,
          dateTime: DateTime.now(),
          type: TransactionType.income,
        ),
        money: Money.parse('1', isoCode: 'EUR'),
        category: _category,
        description: null,
      ),
    ];

    // Act
    final result = calculateInitialAmount(zeroEur, expenses, [], _testAccount);

    // Assert
    expect(result.toDouble(), -1);
  });

  test('Has outbound transfer', () {
    // Arrange
    final expenses = <Expense>[];
    final transfers = [
      Transfer(
        money: Money.parse('1', isoCode: 'EUR'),
        description: null,
        from: _testAccount,
        to: null,
        dateTime: DateTime.now(),
      ),
    ];

    // Act
    final result = calculateInitialAmount(zeroEur, expenses, transfers, _testAccount);

    // Assert
    expect(result.toDouble(), 1);
  });

  test('Has inbound transfer', () {
    // Arrange
    final expenses = <Expense>[];
    final transfers = [
      Transfer(
        money: Money.parse('1', isoCode: 'EUR'),
        description: null,
        from: null,
        to: _testAccount,
        dateTime: DateTime.now(),
      ),
    ];

    // Act
    final result = calculateInitialAmount(zeroEur, expenses, transfers, _testAccount);

    // Assert
    expect(result.toDouble(), -1);
  });

  test('Has inbound transfer and expense', () {
    // Arrange
    final expenses = <Expense>[
      Expense(
        transaction: Transaction(
          account: _testAccount,
          dateTime: DateTime.now(),
          type: TransactionType.expense,
        ),
        money: Money.parse('1', isoCode: 'EUR'),
        category: _category,
        description: null,
      ),
    ];
    final transfers = [
      Transfer(
        money: Money.parse('1', isoCode: 'EUR'),
        description: null,
        from: null,
        to: _testAccount,
        dateTime: DateTime.now(),
      ),
    ];

    // Act
    final result = calculateInitialAmount(zeroEur, expenses, transfers, _testAccount);

    // Assert
    expect(result.toDouble(), 0);
  });

  test('Transfer with same "from" and "to" accounts', () {
    // Arrange
    final expenses = <Expense>[];
    final transfers = [
      Transfer(
        money: Money.parse('1', isoCode: 'EUR'),
        description: null,
        from: _testAccount,
        to: _testAccount,
        dateTime: DateTime.now(),
      ),
    ];

    // Act
    final result = calculateInitialAmount(zeroEur, expenses, transfers, _testAccount);

    // Assert
    expect(result.toDouble(), 0);
  });
}
