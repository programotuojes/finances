import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/date.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart';

class Budget {
  int? id;
  String name;
  Money limit;
  Periodicity period;
  List<BudgetCategory> categories;

  Budget({
    this.id,
    required this.name,
    required this.limit,
    required this.period,
    required this.categories,
  });

  factory Budget.fromMap(Map<String, Object?> map, List<BudgetCategory> budgetCategories) {
    var id = map['id'] as int;

    return Budget(
      id: id,
      name: map['name'] as String,
      limit: Money.fromInt(
        map['moneyMinor'] as int,
        decimalDigits: map['moneyDecimalDigits'] as int,
        isoCode: map['currencyIsoCode'] as String,
      ),
      period: Periodicity.values[map['period'] as int],
      categories: budgetCategories.where((element) => element.budgetId == id).toList(),
    );
  }

  DateTimeRange currentRange(DateTime now) {
    var start = switch (period) {
      Periodicity.day => DateTime(now.year, now.month, now.day),
      Periodicity.week => DateUtils.dateOnly(now.subtract(Duration(days: now.weekday - 1))),
      Periodicity.month => DateTime(now.year, now.month),
      Periodicity.year => DateTime(now.year),
    };

    var end = switch (period) {
      Periodicity.day => DateTime(start.year, start.month, start.day + 1, 0, 0, -1),
      Periodicity.week => DateTime(start.year, start.month, start.day + 7, 0, 0, -1),
      Periodicity.month => DateTime(start.year, start.month + 1, 0, 0, 0, -1),
      Periodicity.year => DateTime(start.year + 1, 1, 1, 0, 0, -1),
    };

    return DateTimeRange(start: start, end: end);
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'period': period.index,
      'moneyMinor': limit.minorUnits.toInt(),
      'moneyDecimalDigits': limit.decimalDigits,
      'currencyIsoCode': limit.currency.isoCode,
    };
  }

  Money usedThisPeriod(DateTime now) {
    var range = currentRange(now);

    Money total = zeroEur;

    for (var budget in categories) {
      total += TransactionService.instance.expenses
          .where((expense) =>
              expense.transaction.dateTime.isIn(range) &&
              expense.transaction.type == TransactionType.expense &&
              _categoryMatches(expense.category, budget))
          .map((expense) => expense.money)
          .fold(zeroEur, (acc, x) => acc + x);
    }

    return total;
  }

  bool _categoryMatches(CategoryModel expenseCategory, BudgetCategory budgetCategory) {
    if (budgetCategory.includeChildren) {
      return expenseCategory.isNestedChildOf(budgetCategory.category);
    }

    return expenseCategory == budgetCategory.category;
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table budgets (
        id integer primary key autoincrement,
        name text not null,
        period integer not null,
        moneyMinor integer not null,
        moneyDecimalDigits integer not null,
        currencyIsoCode text not null
      )
    ''');
  }
}

class BudgetCategory {
  int? id;
  int? budgetId;
  CategoryModel category;
  bool includeChildren;

  BudgetCategory({
    this.id,
    this.budgetId,
    required this.category,
    required this.includeChildren,
  });

  factory BudgetCategory.fromMap(Map<String, Object?> map, List<CategoryModel> categories) {
    return BudgetCategory(
      id: map['id'] as int,
      budgetId: map['budgetId'] as int,
      category: categories.firstWhere((element) => element.id == map['categoryId'] as int),
      includeChildren: map['includeChildren'] == 1,
    );
  }

  BudgetCategory copy() {
    return BudgetCategory(
      id: id,
      budgetId: budgetId,
      category: category,
      includeChildren: includeChildren,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'includeChildren': includeChildren ? 1 : 0,
      'categoryId': category.id,
      'budgetId': budgetId,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table budgetCategories (
        id integer primary key autoincrement,
        includeChildren integer not null,
        categoryId integer not null,
        budgetId integer not null,
        foreign key (categoryId) references categories(id) on delete cascade,
        foreign key (budgetId) references budgets(id) on delete cascade
      )
    ''');
  }
}
