import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class BankSyncInfo {
  String transactionId;
  String? creditorName;
  String? creditorIban;
  String? remittanceInfo;

  BankSyncInfo({
    required this.transactionId,
    required this.creditorName,
    required this.creditorIban,
    required this.remittanceInfo,
  });

  static void createTable(Batch batch) {
    batch.execute('''
      create table bankSyncInfo (
        id integer primary key autoincrement,
        transactionId text not null,
        creditorName text,
        creditorIban text,
        remittanceInfo text,
        dbTransactionId integer not null unique,
        foreign key (dbTransactionId) references transactions(id) on delete cascade
      )
    ''');
  }
}

class Transaction {
  Account account;
  DateTime dateTime;
  TransactionType type;
  List<Attachment> attachments = [];
  List<Expense> expenses = [];
  BankSyncInfo? bankInfo;

  Transaction({
    required this.account,
    required this.dateTime,
    required this.type,
    this.bankInfo,
  });

  Expense get mainExpense => expenses.first;

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
