import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';

class Transaction {
  Account account;
  DateTime dateTime;
  TransactionType type;
  List<Attachment> attachments = List.empty(growable: true);
  List<Expense> expenses = List.empty(growable: true);
  BankSyncInfo? bankInfo;

  Expense get mainExpense => expenses.first;

  Transaction({
    required this.account,
    required this.dateTime,
    required this.type,
    this.bankInfo,
  });
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
