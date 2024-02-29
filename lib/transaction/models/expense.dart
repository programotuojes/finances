import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:money2/money2.dart';

class Expense {
  Transaction transaction;
  Money money;
  CategoryModel category;
  String? description;

  Expense({
    required this.transaction,
    required this.money,
    required this.category,
    required this.description,
  });
}
