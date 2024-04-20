import 'package:finances/transaction/models/transaction.dart';
import 'package:flutter/material.dart';

ThemeData _transactionTheme(
  BuildContext context,
  TransactionType type,
) {
  var color = switch (type) {
    TransactionType.income => Colors.green[100]!,
    TransactionType.expense => Colors.red[200]!,
    TransactionType.transfer => Colors.indigo[100]!,
  };

  return Theme.of(context).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    ),
  );
}

class TransactionTheme {
  final ThemeData _income;
  final ThemeData _expense;
  final ThemeData _transfer;

  TransactionTheme(BuildContext context)
      : _income = _transactionTheme(context, TransactionType.income),
        _expense = _transactionTheme(context, TransactionType.expense),
        _transfer = _transactionTheme(context, TransactionType.transfer);

  ThemeData current(int index) => switch (index) {
        0 => _income,
        1 => _expense,
        2 => _transfer,
        _ => throw ArgumentError(),
      };
}
