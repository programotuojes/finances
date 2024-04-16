import 'dart:io';

import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/service.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/random_string.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class TransactionService with ChangeNotifier {
  static final TransactionService instance = TransactionService._ctor();

  TransactionService._ctor() {
    final t1 = Transaction(
      account: swedbank,
      dateTime: DateTime.now(),
    );
    t1.expenses = [
      Expense(
        transaction: t1,
        money: '2.4'.toMoney('EUR')!,
        category: food,
        description: null,
      ),
      Expense(
        transaction: t1,
        money: '30.4'.toMoney('EUR')!,
        category: other,
        description: 'idk',
      ),
    ];
    final t2 = Transaction(
      account: revolut,
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
    );
    t2.expenses = [
      Expense(
        transaction: t2,
        money: '150'.toMoney('EUR')!,
        category: transport,
        description: null,
      ),
    ];

    transactions = [t1, t2];
  }

  List<Transaction> transactions = List.empty(growable: true);
  Iterable<Expense> get expenses sync* {
    for (final transaction in transactions) {
      for (final expense in transaction.expenses) {
        yield expense;
      }
    }
  }

  Future<void> add(
    Transaction transaction, {
    required List<Expense> expenses,
    required List<Attachment> attachments,
  }) async {
    // transaction.attachments = await moveAttachmentsFromCache(
    //   attachments,
    // ).toList();
    transaction.attachments = attachments.toList();
    transaction.expenses = expenses;
    transactions.add(transaction);

    // TODO don't sort on every insert
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    notifyListeners();
  }

  void delete(Transaction transaction) {
    transactions.remove(transaction);
    notifyListeners();
  }

  Future<void> update({
    required Transaction target,
    required Account account,
    required DateTime dateTime,
    required List<Expense> expenses,
    required List<Attachment> attachments,
  }) async {
    final previousDateTime = target.dateTime;

    // await removeUnusedFiles(attachments, target.attachments);
    // target.attachments = await moveAttachmentsFromCache(attachments).toList();
    target.attachments = attachments.toList();

    target.account = account;
    target.dateTime = dateTime;
    target.expenses = expenses;

    if (previousDateTime != target.dateTime) {
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    notifyListeners();
  }

  Stream<File> moveAttachmentsFromCache(List<File> attachments) async* {
    final appDir = await getApplicationDocumentsDirectory();
    print('App data dir = ${appDir.path}');
    final attachmentsDir = await Directory(
      '${appDir.path}/attachments',
    ).create();

    for (final cacheFile in attachments) {
      final fileExtensionIndex = cacheFile.path.lastIndexOf('.');
      final extension = cacheFile.path.substring(fileExtensionIndex + 1);
      final name = await getUniqueName(attachmentsDir.path, extension);

      final movedAttachment = await cacheFile.rename(
        '${attachmentsDir.path}/$name.$extension',
      );
      yield movedAttachment;
    }
  }

  Future<String> getUniqueName(
    String attachmentsDir,
    String extension,
  ) async {
    String name;

    do {
      name = generateRandomString(15);
    } while (await File('$attachmentsDir/$name.$extension').exists());

    return name;
  }

  Future<void> removeUnusedFiles(
    List<File> current,
    List<File> previous,
  ) async {
    for (final i in previous) {
      if (!current.contains(i)) {
        await i.delete();
      }
    }
  }
}