import 'package:finances/account/models/account.dart';

class Expense {
  int id;
  int amount;
  DateTime dateTime;

  int accountId;
  late Account account;

  Expense({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.dateTime,
  });
}
