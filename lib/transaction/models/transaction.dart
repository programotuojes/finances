import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/models/expense.dart';

class Transaction {
  Account account;
  DateTime dateTime;
  // TODO attachment
  List<Expense> expenses = List.empty(growable:  true);

  Transaction({
    required this.account,
    required this.dateTime,
  });
}
