import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/expense.dart';

class Transaction {
  Account account;
  DateTime dateTime;
  // TODO attachment
  late List<Expense> expenses;

  Transaction({
    required this.account,
    required this.dateTime,
  });
}
