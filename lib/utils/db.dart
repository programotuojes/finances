import 'dart:io';

import 'package:finances/account/models/account.dart';
import 'package:finances/automation/models/automation.dart';
import 'package:finances/budget/models/budget.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/bank_sync_info.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart' as finances;
import 'package:finances/utils/app_paths.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late Database _database;
Database get database => _database;

Future<void> initializeDatabase() async {
  if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
    databaseFactory = databaseFactoryFfi;
  }

  _database = await openDatabase(
    AppPaths.db,
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
