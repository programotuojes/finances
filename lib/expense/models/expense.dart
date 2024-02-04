import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:money2/money2.dart';

class Expense {
  Account account;
  CategoryModel category;
  Money amount;
  DateTime dateTime;
  String? description;

  Expense({
    required this.account,
    required this.category,
    required this.amount,
    required this.dateTime,
    this.description,
  });
}
