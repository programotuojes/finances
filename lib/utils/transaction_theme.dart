import 'package:finances/transaction/models/transaction.dart';
import 'package:flutter/material.dart';

ThemeData _transactionTheme(
  BuildContext context,
  TransactionType type,
) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: type.color,
    brightness: Theme.of(context).brightness,
  );
  return Theme.of(context).copyWith(
    scaffoldBackgroundColor: colorScheme.background,
    colorScheme: colorScheme,
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

  TextStyle? createTextStyle(BuildContext context, TransactionType type) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: current(type.index).colorScheme.primary,
          );
}
