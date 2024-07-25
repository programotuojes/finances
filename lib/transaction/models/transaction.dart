import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/bank_sync_info.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Transaction {
  int? id;
  Account account;
  DateTime dateTime;
  TransactionType type;
  List<Attachment> attachments = [];
  List<Expense> expenses = [];
  BankSyncInfo? bankInfo;

  Transaction({
    this.id,
    required this.account,
    required this.dateTime,
    required this.type,
    List<Attachment>? attachments,
    List<Expense>? expenses,
    this.bankInfo,
  }) {
    if (attachments != null) {
      this.attachments = attachments;
    }
    if (expenses != null) {
      this.expenses = expenses;
    }
  }

  factory Transaction.fromMap(
    Map<String, Object?> map,
    List<Attachment> attachments,
    List<BankSyncInfo> bankInfos,
  ) {
    var id = map['id'] as int;

    return Transaction(
      id: id,
      account: AccountService.instance.accounts.firstWhere((x) => x.id == map['accountId'] as int),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTimeMs'] as int),
      type: TransactionType.values[map['type'] as int],
      attachments: attachments.where((x) => x.transactionId == id).toList(),
      bankInfo: bankInfos.firstWhereOrNull((x) => x.dbTransactionId == id),
    );
  }

  Expense get mainExpense => expenses.first;

  Map<String, Object?> toMap() {
    return {
      'accountId': account.id,
      'dateTimeMs': dateTime.millisecondsSinceEpoch,
      'type': type.index,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table transactions (
        id integer primary key autoincrement,
        accountId integer not null,
        dateTimeMs integer not null,
        type integer not null,
        foreign key (accountId) references accounts(id) on delete cascade
      )
    ''');
  }
}

enum TransactionType {
  income(color: Color(0xFFAED581)),
  expense(color: Color(0xFFCC616B)),
  transfer(color: Color(0xFF6AC6E7));

  final Color color;

  const TransactionType({
    required this.color,
  });
}
