import 'package:finances/account/models/account.dart';
import 'package:finances/automation/models/automation.dart';
import 'package:finances/budget/models/budget.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/main.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_expense.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_transfer.dart';
import 'package:finances/transaction/models/transaction.dart' as finances;
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:finances/utils/diacritic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late Database _database;
Database get database => _database;

Future<void> initializeDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  _database = await openDatabase(
    AppPaths.db,
    version: 3,
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
      ImportedWalletDbExpense.createTable(batch);
      ImportedWalletDbTransfer.createTable(batch);
      finances.Transaction.createTable(batch);
      Transfer.createTable(batch);

      await batch.commit();
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await _upgradeFrom1(db, oldVersion, newVersion);
      await _upgradeFrom2(db, oldVersion, newVersion);
    },
  );
}

Future<void> _upgradeFrom1(Database db, int oldVersion, int newVersion) async {
  if (oldVersion > 1) {
    return;
  }

  logger.i('Upgrading database from v1');

  final batch = db.batch();

  batch.execute('ALTER TABLE expenses ADD descriptionNorm TEXT');
  batch.execute('ALTER TABLE transfers ADD descriptionNorm TEXT');

  final expenses = await db.query('expenses', columns: ['id', 'description']);
  for (final row in expenses) {
    final id = row['id'] as int;
    final description = row['description'] as String?;
    batch.update(
      'expenses',
      {'descriptionNorm': normalizeString(description)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  final transfers = await db.query('transfers', columns: ['id', 'description']);
  for (final row in transfers) {
    final id = row['id'] as int;
    final description = row['description'] as String?;
    batch.update(
      'transfers',
      {'descriptionNorm': normalizeString(description)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  await batch.commit(noResult: true);
}

Future<void> _upgradeFrom2(Database db, int oldVersion, int newVersion) async {
  if (oldVersion > 2) {
    return;
  }

  logger.i('Upgrading database from v2');

  await db.execute('''
    ALTER TABLE expenses DROP COLUMN moneyDecimalDigits;
    ALTER TABLE expenses DROP COLUMN currencyIsoCode;
    ALTER TABLE transfers DROP COLUMN moneyDecimalDigits;
    ALTER TABLE transfers DROP COLUMN currencyIsoCode;
  ''');
}
