import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:money2/money2.dart';

class Expense {
  Transaction transaction;
  Money money;
  CategoryModel category;
  String? _description;

  String? get description => _description;

  set description(String? value) {
    if (value != null && value.isNotEmpty) {
      _description = value;
    }

    _description = null;
  }

  Expense({
    required this.transaction,
    required this.money,
    required this.category,
    required String? description,
  }) {
    this.description = description;
  }
}
