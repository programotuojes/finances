import 'package:collection/collection.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/diacritic.dart';
import 'package:finances/utils/money.dart';
import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Expense {
  int? id;
  Money money;
  String? _description;
  Transaction transaction;
  CategoryModel category;
  ImportedWalletDbExpense? importedWalletDbExpense;

  Expense({
    this.id,
    required this.transaction,
    required this.money,
    required this.category,
    required String? description,
    this.importedWalletDbExpense,
  }) {
    this.description = description;
  }

  factory Expense.fromMap(
    Map<String, Object?> map,
    List<Transaction> transactions,
    List<ImportedWalletDbExpense> importedWalletDbExpenses,
  ) {
    var id = map['id'] as int;
    var transaction = transactions.firstWhere((x) => x.id == map['transactionId'] as int);

    return Expense(
      id: id,
      money: Money.fromIntWithCurrency(map['moneyMinor'] as int, transaction.account.currency),
      category: CategoryService.instance.findById(map['categoryId'] as int)!,
      transaction: transaction,
      description: map['description'] as String?,
      importedWalletDbExpense: importedWalletDbExpenses.firstWhereOrNull((x) => x.parentId == id),
    );
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
    final accountMatches = transaction.account.name.contains(regex);
    if (accountMatches) {
      return true;
    }

    // TODO normalize only once per object creation and description update
    var descriptionMatches = normalizeString(description)?.contains(regex) == true;
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

    return false;
  }

  Map<String, Object?> toMap() {
    return {
      'moneyMinor': money.minorUnits.toInt(),
      'description': description,
      'descriptionNorm': normalizeString(description),
      'categoryId': category.id,
      'transactionId': transaction.id,
    };
  }

  static void createTable(sql.Batch batch) {
    batch.execute('''
      create table expenses (
        id integer primary key autoincrement,
        moneyMinor integer not null,
        description text,
        descriptionNorm text,
        categoryId integer not null,
        transactionId integer not null,
        foreign key (categoryId) references categories(id) on delete cascade,
        foreign key (transactionId) references transactions(id) on delete cascade
      )
    ''');
  }
}
