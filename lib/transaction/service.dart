import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_expense.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_transfer.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class TransactionService with ChangeNotifier {
  static final TransactionService instance = TransactionService._ctor();

  List<Transaction> _transactions = [];
  List<Transfer> _transfers = [];

  TransactionService._ctor();

  Iterable<Transaction> get transactions => _transactions;
  Iterable<Transfer> get transfers => _transfers;
  Iterable<Expense> get expenses sync* {
    for (final transaction in transactions) {
      yield* transaction.expenses;
    }
  }

  Future<void> addTransfer(Transfer transfer) async {
    transfer.id = await database.insert('transfers', transfer.toMap());
    _transfers.add(transfer);
    notifyListeners();
  }

  Future<void> add(
    Transaction transaction, {
    required List<Expense> expenses,
  }) async {
    await _copyAttachments(transaction.attachments);

    transaction.id = await database.insert('transactions', transaction.toMap());

    var batch = database.batch();
    for (var i in expenses) {
      i.transaction = transaction;
      batch.insert('expenses', i.toMap());
    }
    var ids = await batch.commit();
    for (var i = 0; i < expenses.length; i++) {
      expenses[i].id = ids[i] as int;
    }

    batch = database.batch();
    for (var i in transaction.attachments) {
      i.transactionId = transaction.id;
      batch.insert('attachments', i.toMap());
    }
    ids = await batch.commit();
    for (var i = 0; i < transaction.attachments.length; i++) {
      transaction.attachments[i].id = ids[i] as int;
    }

    transaction.expenses = expenses;
    _transactions.add(transaction);

    // TODO don't sort on every insert
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    notifyListeners();
  }

  Future<void> addBulk(List<Transaction> transactions) async {
    var batch1 = database.batch();

    for (var transaction in transactions) {
      await _copyAttachments(transaction.attachments);
      batch1.insert('transactions', transaction.toMap());
    }

    var ids = await batch1.commit();

    for (var i = 0; i < transactions.length; i++) {
      transactions[i].id = ids[i] as int;
    }

    var childrenBatch = database.batch();

    for (var transaction in transactions) {
      for (var expense in transaction.expenses) {
        expense.transaction = transaction;
        childrenBatch.insert('expenses', expense.toMap());
      }

      for (var attachment in transaction.attachments) {
        attachment.transactionId = transaction.id;
        childrenBatch.insert('attachments', attachment.toMap());
      }
    }

    ids = await childrenBatch.commit();
    var idIndex = 0;
    final batchImportedWallet = database.batch();

    for (var transaction in transactions) {
      for (var expense in transaction.expenses) {
        expense.id = ids[idIndex++] as int;
        if (expense.importedWalletDbExpense != null) {
          expense.importedWalletDbExpense!.parentId = expense.id;
          batchImportedWallet.insert(ImportedWalletDbExpense.tableName, expense.importedWalletDbExpense!.toMap());
        }
      }
      for (var attachment in transaction.attachments) {
        attachment.id = ids[idIndex++] as int;
      }
    }

    final importedWalletIds = await batchImportedWallet.commit();
    var importedWalletIndex = 0;
    for (var transaction in transactions) {
      for (var expense in transaction.expenses) {
        if (expense.importedWalletDbExpense != null) {
          expense.importedWalletDbExpense!.id = importedWalletIds[importedWalletIndex++] as int;
        }
      }
    }

    _transactions.addAll(transactions);
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  Future<void> addBulkTransfers(List<Transfer> transfers) async {
    var addTransfersBatch = database.batch();

    for (var transfer in transfers) {
      addTransfersBatch.insert('transfers', transfer.toMap());
    }

    final transferIds = await addTransfersBatch.commit();
    for (var i = 0; i < transfers.length; i++) {
      transfers[i].id = transferIds[i] as int;
    }

    var childrenBatch = database.batch();
    for (final transfer in transfers) {
      if (transfer.importedWalletDbTransfer != null) {
        transfer.importedWalletDbTransfer!.parentId = transfer.id;
        childrenBatch.insert(ImportedWalletDbTransfer.tableName, transfer.importedWalletDbTransfer!.toMap());
      }
    }

    final childrenIds = await childrenBatch.commit();
    var idIndex = 0;
    for (final transaction in transfers) {
      if (transaction.importedWalletDbTransfer != null) {
        transaction.importedWalletDbTransfer!.id = childrenIds[idIndex++] as int;
      }
    }

    _transfers.addAll(transfers);
    _transfers.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  Future<void> delete(Transaction transaction) async {
    await database.delete('transactions', where: 'id = ?', whereArgs: [transaction.id]);

    _transactions.remove(transaction);

    await _removeUnusedFiles([], transaction.attachments);

    notifyListeners();
  }

  Future<void> deleteTransfer(Transfer transfer) async {
    await database.delete('transfers', where: 'id = ?', whereArgs: [transfer.id]);
    _transfers.remove(transfer);
    notifyListeners();
  }

  Future<void> init() async {
    var dbAttachments = await database.query('attachments');
    var attachments = dbAttachments.map((e) => Attachment.fromMap(e)).toList();

    final dbImportedWalletDbExpenses = await database.query(ImportedWalletDbExpense.tableName);
    final importedWalletDbExpenses = dbImportedWalletDbExpenses.map((x) => ImportedWalletDbExpense.fromMap(x)).toList();

    final dbImportedWalletDbTransfers = await database.query(ImportedWalletDbTransfer.tableName);
    final importedWalletDbTransfers =
        dbImportedWalletDbTransfers.map((x) => ImportedWalletDbTransfer.fromMap(x)).toList();

    final dbTransfers = await database.query('transfers', orderBy: 'dateTimeMs desc');
    _transfers = dbTransfers.map((e) => Transfer.fromMap(e, importedWalletDbTransfers)).toList();

    var dbTransactions = await database.query('transactions', orderBy: 'dateTimeMs desc');
    _transactions = dbTransactions.map((e) => Transaction.fromMap(e, attachments)).toList();

    var dbExpenses = await database.query('expenses');
    var expenses = dbExpenses.map((e) => Expense.fromMap(e, _transactions, importedWalletDbExpenses)).toList();

    for (var i in _transactions) {
      i.expenses = expenses.where((element) => element.transaction.id == i.id).toList();
    }

    notifyListeners();
  }

  Future<void> updateTransfer(Transfer target, Transfer newValues) async {
    final previousDateTime = target.dateTime;

    target.money = newValues.money;
    target.description = newValues.description;
    target.from = newValues.from;
    target.to = newValues.to;
    target.dateTime = newValues.dateTime;

    await database.update('transfers', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    if (previousDateTime != target.dateTime) {
      _transfers.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    notifyListeners();
  }

  Future<void> update(
    Transaction target, {
    Account? account,
    DateTime? dateTime,
    TransactionType? type,
    List<Attachment>? attachments,
    List<Expense>? expenses,
  }) async {
    final previousDateTime = target.dateTime;

    if (attachments != null) {
      await _copyAttachments(attachments);
      await _removeUnusedFiles(attachments, target.attachments);
      await _upsertAttachments(target.id!, attachments, target.attachments);
      target.attachments = attachments;
    }

    if (expenses != null) {
      await _upsertExpenses(expenses, target.expenses);
      target.expenses = expenses;
    }

    target.account = account ?? target.account;
    target.dateTime = dateTime ?? target.dateTime;
    target.type = type ?? target.type;

    await database.update('transactions', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    if (previousDateTime != target.dateTime) {
      _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    notifyListeners();
  }

  Future<void> _copyAttachments(List<Attachment> attachments) async {
    await Directory(AppPaths.attachments).create();

    for (final attachment in attachments) {
      if (attachment.id != null) {
        continue;
      }

      var newPath = await _getUniqueName(attachment.file.path);

      await attachment.file.saveTo(newPath);
      attachment.file = XFile(newPath);
    }
  }

  Future<String> _getUniqueName(
    String filePath,
  ) async {
    var name = basenameWithoutExtension(filePath);
    var ext = extension(filePath);
    var newPath = join(AppPaths.attachments, '$name$ext');

    for (var i = 1; await File(join(newPath)).exists(); i++) {
      newPath = join(AppPaths.attachments, '${name}_$i$ext');
    }

    return newPath;
  }

  Future<void> _removeUnusedFiles(
    List<Attachment> currentAttachments,
    List<Attachment> previousAttachments,
  ) async {
    for (final previousAttachment in previousAttachments) {
      if (!currentAttachments.contains(previousAttachment)) {
        var file = File(previousAttachment.file.path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<void> _upsertAttachments(int transactionId, List<Attachment> curr, List<Attachment> prev) async {
    for (var i in curr) {
      var exists = prev.any((element) => element.id == i.id);

      // TODO check if `exists` could be replaced with `i.id != null`
      if (exists) {
        await database.update('attachments', i.toMap(), where: 'id = ?', whereArgs: [i.id]);
      } else {
        // TODO encapsulate the attachment list to avoid such issues
        i.transactionId = transactionId;
        i.id = await database.insert('attachments', i.toMap());
      }
    }

    for (var i in prev) {
      var contains = curr.any((element) => element.id == i.id);
      if (!contains) {
        await database.delete('attachments', where: 'id = ?', whereArgs: [i.id]);
      }
    }
  }

  Future<void> _upsertExpenses(List<Expense> curr, List<Expense> prev) async {
    for (var i in curr) {
      var exists = prev.any((element) => element.id == i.id);

      // TODO check if `exists` could be replaced with `i.id != null`
      if (exists) {
        await database.update('expenses', i.toMap(), where: 'id = ?', whereArgs: [i.id]);
      } else {
        i.id = await database.insert('expenses', i.toMap());
      }
    }

    for (var i in prev) {
      var contains = curr.any((element) => element.id == i.id);
      if (!contains) {
        await database.delete('expenses', where: 'id = ?', whereArgs: [i.id]);
      }
    }
  }
}
