import 'dart:io';

import 'package:finances/account/models/account.dart';
import 'package:finances/automation/models/automation.dart';
import 'package:finances/budget/models/budget.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/main.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart' as finances;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xdg_directories/xdg_directories.dart';

class Db {
  static final Db instance = Db._ctor();

  late final Database _database;

  Db._ctor();

  Database get db => _database;

  Future<void> initialize() async {
    String databasePath;

    if (Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      databasePath = '${dataHome.path}/finances';
    } else {
      databasePath = await getDatabasesPath();
    }

    databasePath = join(databasePath, 'finances.db');

    logger.d('Database path = $databasePath');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onConfigure: (db) {
        db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        var batch = db.batch();

        Account.createTable(batch);
        Automation.createTable(batch);
        Rule.createTable(batch);
        Budget.createTable(batch);
        BudgetCategory.createTable(batch);
        CategoryModel.createTable(batch);
        RecurringModel.createTable(batch);
        Attachment.createTable(batch);
        Expense.createTable(batch);
        finances.BankSyncInfo.createTable(batch);
        finances.Transaction.createTable(batch);

        await batch.commit();
      },
    );
  }
}
