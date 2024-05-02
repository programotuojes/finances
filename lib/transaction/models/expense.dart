import 'package:finances/category/models/category.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/money.dart';
import 'package:intl/intl.dart';
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

  String groupingKey(Periodicity periodicity) {
    var dateTime = transaction.dateTime;

    var format = switch (periodicity) {
      Periodicity.day => DateFormat('yyyy-MM-dd'),
      Periodicity.week => DateFormat('yyyy-${_weekNumber(dateTime).toString().padLeft(2, '0')}'),
      Periodicity.month => DateFormat('yyyy-MM'),
      Periodicity.year => DateFormat('yyyy'),
    };

    return format.format(dateTime);
  }

  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  int _numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = _numOfWeeks(date.year - 18);
    } else if (woy > _numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }
}
