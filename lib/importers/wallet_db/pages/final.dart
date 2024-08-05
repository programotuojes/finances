import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/temp_combined.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/utils/transaction_theme.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class WalletDbFinalPage extends StatelessWidget {
  final Map<String, Account> accountMap;
  final Map<String, CategoryModel> categoryMap;
  final List<wallet_db.Record> records;

  const WalletDbFinalPage({
    super.key,
    required this.accountMap,
    required this.categoryMap,
    required this.records,
  });

  Iterable<TempCombined> _calculate() sync* {
    for (final record in records) {
      assert(accountMap[record.accountId] != null);

      final money = Money.fromNumWithCurrency(record.amountReal, CommonCurrencies().euro);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(record.recordDate);

      if (record.transfer) {
        final fromAccount = accountMap[record.accountId];
        final toAccount = accountMap[record.transferAccountId];

        if (money.isNegative && fromAccount != null && toAccount != null) {
          continue;
        }

        final transfer = Transfer(
          money: money,
          description: record.note,
          from: fromAccount,
          to: toAccount,
          dateTime: dateTime,
        );
        yield TempCombined.fromTransfer(transfer);
        continue;
      }

      final transaction = Transaction(
        account: accountMap[record.accountId]!,
        dateTime: dateTime,
        type: record.amountReal < 0 ? TransactionType.expense : TransactionType.income,
      );
      final expense = Expense(
        transaction: transaction,
        money: money,
        category: categoryMap[record.categoryId] ?? CategoryService.instance.otherCategory,
        description: record.note,
      );
      transaction.expenses = [expense];
      // yield TempCombined.fromExpense(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = TransactionTheme(context);
    final _incomeStyle = theme.createTextStyle(context, TransactionType.income);
    final _expenseStyle = theme.createTextStyle(context, TransactionType.expense);
    final _transferStyle = theme.createTextStyle(context, TransactionType.transfer);

    TextStyle? _textStyle(TransactionType type) {
      return switch (type) {
        TransactionType.income => _incomeStyle,
        TransactionType.expense => _expenseStyle,
        TransactionType.transfer => _transferStyle,
      };
    }

    IconData? _amountSymbol(TransactionType type) {
      return switch (type) {
        TransactionType.income => Icons.arrow_drop_up_rounded,
        TransactionType.expense => Icons.arrow_drop_down_rounded,
        TransactionType.transfer => null,
      };
    }

    final mapped = _calculate().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview results'),
      ),
      body: ListView.builder(
        itemCount: mapped.length,
        prototypeItem: ListTile(
          isThreeLine: true,
          title: Text(mapped.first.category.name),
          leading: CategoryIcon(
            icon: mapped.first.category.icon,
            color: mapped.first.category.color,
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mapped.first.dateTime.toString().substring(0, 16)),
              Text(
                mapped.first.description ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                style: _textStyle(mapped.first.type),
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        _amountSymbol(mapped.first.type),
                        color: _textStyle(mapped.first.type)?.color,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(text: mapped.first.money.toString()),
                  ],
                ),
              ),
              Text(mapped.first.accountName),
            ],
          ),
        ),
        itemBuilder: (context, index) {
          final x = mapped[index];
          return ListTile(
            isThreeLine: true,
            title: Text(x.category.name),
            leading: CategoryIcon(
              icon: x.category.icon,
              color: x.category.color,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(x.dateTime.toString().substring(0, 16)),
                Text(
                  x.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  style: _textStyle(x.type),
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(
                          _amountSymbol(x.type),
                          color: _textStyle(x.type)?.color,
                        ),
                        alignment: PlaceholderAlignment.middle,
                      ),
                      TextSpan(text: x.money.toString()),
                    ],
                  ),
                ),
                Text(x.accountName),
              ],
            ),
          );
        },
      ),
    );
  }
}
