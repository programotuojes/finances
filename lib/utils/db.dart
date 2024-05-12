import 'dart:io';

import 'package:finances/account/models/account.dart';
import 'package:finances/automation/models/automation.dart';
import 'package:finances/budget/models/budget.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/main.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/bank_sync_info.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart' as finances;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Db {
  static final Db instance = Db._ctor();

  late final Database _database;
  late final String path;

  Db._ctor();

  Database get db => _database;

  Future<void> initialize() async {
    if (!Platform.isAndroid || !Platform.isIOS || !Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }

    var databasePath = await getApplicationSupportDirectory();
    path = join(databasePath.path, 'finances.db');

    logger.d('Database path = $path');

    _database = await openDatabase(
      path,
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
        BankSyncInfo.createTable(batch);
        finances.Transaction.createTable(batch);

        await batch.commit();
      },
    );
  }

  // TODO remove
  Future<void> delete() async {
    logger.i('Deleted the database');
    await deleteDatabase(path);
  }
}
