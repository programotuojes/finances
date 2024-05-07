import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:flutter/material.dart';

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
}

enum TransactionType {
  income,
  expense,
  transfer,
}

class BankSyncInfo {
  String transactionId;
  String? receiverName;
  String? receiverIban;
  String? remittanceInfo;

  BankSyncInfo({
    required this.transactionId,
    required this.receiverName,
    required this.receiverIban,
    required this.remittanceInfo,
  });
}
