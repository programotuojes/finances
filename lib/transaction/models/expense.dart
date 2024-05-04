import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/money.dart';
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
    } else {
      _description = null;
    }
  }

  Expense({
    required this.transaction,
    required this.money,
    required this.category,
    required String? description,
  }) {
    this.description = description;
  }

  Expense copy() => Expense(
        transaction: transaction,
        money: money,
        category: category,
        description: description,
      );

  Money get signedMoney {
    return switch (transaction.type) {
      TransactionType.income => money,
      TransactionType.expense => -money,
      TransactionType.transfer => zeroEur,
    };
  }

  bool matchesFilter(RegExp regex) {
    var descriptionMatches = description?.contains(regex) == true;
    if (descriptionMatches) {
      return true;
    }

    var categoryMatches = category.name.contains(regex);
    if (categoryMatches) {
      return true;
    }

    var attachmentTextMatches = transaction.attachments.any((attachment) => attachment.text?.contains(regex) == true);
    if (attachmentTextMatches) {
      return true;
    }

    var creditorNameMatches = transaction.bankInfo?.receiverName?.contains(regex) == true;
    if (creditorNameMatches) {
      return true;
    }

    return false;
  }
}
