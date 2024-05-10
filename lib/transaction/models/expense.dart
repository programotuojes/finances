import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/money.dart';
import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Expense {
  Money money;
  String? _description;
  Transaction transaction;
  CategoryModel category;

  Expense({
    required this.transaction,
    required this.money,
    required this.category,
    required String? description,
  }) {
    this.description = description;
  }

  String? get description => _description;

  set description(String? value) {
    if (value != null && value.isNotEmpty) {
      _description = value;
    } else {
      _description = null;
    }
  }

  Money get signedMoney {
    return switch (transaction.type) {
      TransactionType.income => money,
      TransactionType.expense => -money,
      TransactionType.transfer => zeroEur,
    };
  }

  Expense copy() => Expense(
        transaction: transaction,
        money: money,
        category: category,
        description: description,
      );

  bool matchesFilter(RegExp regex) {
    var descriptionMatches = description?.contains(regex) == true;
    if (descriptionMatches) {
      return true;
    }

    var categoryMatches = category.name.contains(regex);
    if (categoryMatches) {
      return true;
    }

    var attachmentTextMatches = transaction.attachments.any((attachment) => attachment.text?.contains(regex) == true);
    if (attachmentTextMatches) {
      return true;
    }

    var creditorNameMatches = transaction.bankInfo?.creditorName?.contains(regex) == true;
    if (creditorNameMatches) {
      return true;
    }

    return false;
  }

  static void createTable(sql.Batch batch) {
    batch.execute('''
      create table expenses (
        id integer primary key autoincrement,
        moneyMinor integer not null,
        moneyDecimalDigits integer not null,
        currencyIsoCode text not null,
        description text,
        categoryId integer not null,
        transactionId integer not null,
        foreign key (categoryId) references categories(id) on delete cascade,
        foreign key (transactionId) references transactions(id) on delete cascade
      )
    ''');
  }
}
