import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/bank_sync_info.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TransactionService with ChangeNotifier {
  static final TransactionService instance = TransactionService._ctor();

  final List<Transaction> transactions = [];

  TransactionService._ctor();

  Iterable<Expense> get expenses sync* {
    for (final transaction in transactions) {
      yield* transaction.expenses;
    }
  }

  Future<void> add(
    Transaction transaction, {
    required List<Expense> expenses,
  }) async {
    await _copyAttachments(transaction.attachments);

    transaction.id = await Db.instance.db.insert('transactions', transaction.toMap());

    var batch = Db.instance.db.batch();
    for (var i in expenses) {
      i.transaction = transaction;
      batch.insert('expenses', i.toMap());
    }
    var ids = await batch.commit();
    for (var i = 0; i < expenses.length; i++) {
      expenses[i].id = ids[i] as int;
    }

    batch = Db.instance.db.batch();
    for (var i in transaction.attachments) {
      batch.insert('attachments', i.toMap());
    }
    ids = await batch.commit();
    for (var i = 0; i < transaction.attachments.length; i++) {
      transaction.attachments[i].id = ids[i] as int;
    }

    if (transaction.bankInfo != null) {
      transaction.bankInfo!.dbTransactionId = transaction.id;
      transaction.bankInfo!.id = await Db.instance.db.insert('bankSyncInfo', transaction.bankInfo!.toMap());
    }

    transaction.expenses = expenses;
    transactions.add(transaction);

    // TODO don't sort on every insert
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    notifyListeners();
  }

  Future<void> delete(Transaction transaction) async {
    await Db.instance.db.delete('transactions', where: 'id = ?', whereArgs: [transaction.id]);

    transactions.remove(transaction);

    await _removeUnusedFiles([], transaction.attachments);

    notifyListeners();
  }

  Future<void> init() async {
    var dbAttachments = await Db.instance.db.query('attachments');
    var attachments = dbAttachments.map((e) => Attachment.fromMap(e)).toList();

    var dbBankInfos = await Db.instance.db.query('bankSyncInfo');
    var bankInfos = dbBankInfos.map((e) => BankSyncInfo.fromMap(e)).toList();

    var dbTransactions = await Db.instance.db.query('transactions', orderBy: 'dateTimeMs desc');
    transactions.addAll(dbTransactions.map((e) => Transaction.fromMap(e, attachments, bankInfos)));

    var dbExpenses = await Db.instance.db.query('expenses');
    var expenses = dbExpenses.map((e) => Expense.fromMap(e, transactions)).toList();

    for (var i in transactions) {
      i.expenses = expenses.where((element) => element.transaction.id == i.id).toList();
    }
  }

  Future<void> update(
    Transaction target, {
    Account? account,
    DateTime? dateTime,
    TransactionType? type,
    List<Attachment>? attachments,
    List<Expense>? expenses,
    BankSyncInfo? bankInfo,
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
    }

    target.account = account ?? target.account;
    target.dateTime = dateTime ?? target.dateTime;
    target.expenses = expenses ?? target.expenses;
    target.type = type ?? target.type;
    target.bankInfo = bankInfo ?? target.bankInfo;

    await Db.instance.db.update('transactions', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    if (previousDateTime != target.dateTime) {
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    notifyListeners();
  }

  Future<void> _copyAttachments(List<Attachment> attachments) async {
    var appDir = await getApplicationSupportDirectory();
    var attachmentDir = join(appDir.path, 'attachments');
    await Directory(attachmentDir).create();

    for (final attachment in attachments) {
      if (attachment.file.path.startsWith(attachmentDir)) {
        continue;
      }

      var newPath = await _getUniqueName(attachmentDir, attachment.file.path);

      await attachment.file.saveTo(newPath);
      attachment.file = XFile(newPath);
    }
  }

  Future<String> _getUniqueName(
    String attachmentsDir,
    String filePath,
  ) async {
    var name = basenameWithoutExtension(filePath);
    var ext = extension(filePath);
    var newPath = join(attachmentsDir, '$name$ext');

    for (var i = 1; await File(join(newPath)).exists(); i++) {
      newPath = join(attachmentsDir, '${name}_$i$ext');
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

      if (exists) {
        await Db.instance.db.update('attachments', i.toMap());
      } else {
        // TODO encapsulate the attachment list to avoid such issues
        i.transactionId = transactionId;
        i.id = await Db.instance.db.insert('attachments', i.toMap());
      }
    }

    for (var i in prev) {
      var contains = curr.any((element) => element.id == i.id);
      if (!contains) {
        await Db.instance.db.delete('attachments', where: 'id = ?', whereArgs: [i.id]);
      }
    }
  }

  Future<void> _upsertExpenses(List<Expense> curr, List<Expense> prev) async {
    for (var i in curr) {
      var exists = prev.any((element) => element.id == i.id);

      if (exists) {
        await Db.instance.db.update('expenses', i.toMap());
      } else {
        i.id = await Db.instance.db.insert('expenses', i.toMap());
      }
    }

    for (var i in prev) {
      var contains = curr.any((element) => element.id == i.id);
      if (!contains) {
        await Db.instance.db.delete('expenses', where: 'id = ?', whereArgs: [i.id]);
      }
    }
  }
}
