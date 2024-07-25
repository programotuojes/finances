import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

// TODO remove this file

final _transferCategory = CategoryModel(
  name: 'Transfer',
  color: Colors.blue,
  icon: Icons.swap_horiz,
  orderIndex: 0,
);

class TempCombined {
  Expense? expense;
  Transfer? transfer;

  TempCombined({
    this.expense,
    this.transfer,
  });

  factory TempCombined.fromExpense(Expense expense) {
    return TempCombined(
      expense: expense,
    );
  }

  factory TempCombined.fromTransfer(Transfer transfer) {
    return TempCombined(
      transfer: transfer,
    );
  }

  String get accountName {
    if (expense != null) {
      return expense!.transaction.account.name;
    } else {
      final fromAccount = transfer!.from?.name ?? 'Outside the app';
      final toAccount = transfer!.to?.name ?? 'Outside the app';
      return '$fromAccount ➜ $toAccount';
    }
  }

  CategoryModel get category {
    if (expense != null) {
      return expense!.category;
    }

    return _transferCategory;
  }

  set category(CategoryModel value) {
    if (expense != null) {
      expense!.category = value;
    }
  }

  DateTime get dateTime {
    if (expense != null) {
      return expense!.transaction.dateTime;
    } else {
      return transfer!.dateTime;
    }
  }

  String? get description {
    if (expense != null) {
      return expense!.description;
    } else {
      return transfer!.description;
    }
  }

  set description(String? value) {
    if (expense != null) {
      expense!.description = value;
    } else {
      transfer!.description = value;
    }
  }

  Money get money {
    if (expense != null) {
      return expense!.money;
    } else {
      return transfer!.money;
    }
  }

  set money(Money value) {
    if (expense != null) {
      expense!.money = value;
    } else {
      transfer!.money = value;
    }
  }

  Money get signedMoney {
    return switch (type) {
      TransactionType.income => money,
      TransactionType.expense => -money,
      TransactionType.transfer => zeroEur,
    };
  }

  Transaction? get transaction => expense?.transaction;

  TransactionType get type {
    if (transfer != null) {
      return TransactionType.transfer;
    } else {
      return expense!.transaction.type;
    }
  }
}
