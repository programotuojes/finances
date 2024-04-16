import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';

class Transaction {
  Account account;
  DateTime dateTime;
  List<Attachment> attachments = List.empty(growable: true);
  List<Expense> expenses = List.empty(growable: true);

  Transaction({
    required this.account,
    required this.dateTime,
  });
}