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
  income(color: Color(0xFFAED581)),
  expense(color: Color(0xFFCC616B)),
  transfer(color: Color(0xFF6AC6E7));

  final Color color;

  const TransactionType({
    required this.color,
  });
}
