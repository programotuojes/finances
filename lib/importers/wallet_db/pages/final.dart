import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/importers/wallet_db/pages/descriptions.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_expense.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_transfer.dart';
import 'package:finances/transaction/models/temp_combined.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/db.dart';
import 'package:finances/utils/transaction_theme.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class WalletDbFinalPage extends StatelessWidget {
  final Map<String, Account> accountMap;
  final Map<String, CategoryModel> categoryMap;
  final List<wallet_db.Record> records;
  final List<Rule> rules;

  const WalletDbFinalPage({
    super.key,
    required this.accountMap,
    required this.categoryMap,
    required this.records,
    required this.rules,
  });

  Iterable<TempCombined> _calculate() sync* {
    final Map<DateTime, Transaction> transactionCache = {};

    for (final record in records) {
      assert(accountMap[record.accountId] != null);

      final money = Money.fromNumWithCurrency(record.amountReal, CommonCurrencies().euro);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(record.recordDate);

      if (record.transfer) {
        final fromAccount = accountMap[record.accountId];
        final toAccount = accountMap[record.transferAccountId];

        if (money.isNegative && fromAccount != null && toAccount != null) {
          // For a to b transfers, skip the b to a record
          continue;
        }

        final transfer = Transfer(
          money: money,
          description: record.note,
          from: fromAccount,
          to: toAccount,
          dateTime: dateTime,
          importedWalletDbTransfer: ImportedWalletDbTransfer(
            recordId: record.id,
            accountId: record.accountId,
            categoryId: record.categoryId,
            transferId: record.transferId!,
            transferAccountId: record.transferAccountId,
          ),
        );
        yield TempCombined.fromTransfer(transfer);
        continue;
      }

      var transaction = transactionCache[dateTime];
      if (transaction == null) {
        transaction = Transaction(
          account: accountMap[record.accountId]!,
          dateTime: dateTime,
          type: record.amountReal < 0 ? TransactionType.expense : TransactionType.income,
        );
        transactionCache[dateTime] = transaction;
      }

      final rule = rules.firstWhereOrNull((rule) => rule.regex.hasMatch(record.note));

      final expense = Expense(
        transaction: transaction,
        money: money,
        category: rule?.category ?? categoryMap[record.categoryId] ?? CategoryService.instance.otherCategory,
        description: record.note,
        importedWalletDbExpense: ImportedWalletDbExpense(
          recordId: record.id,
          accountId: record.accountId,
          categoryId: record.categoryId,
        ),
      );
      transaction.expenses.add(expense);
      yield TempCombined.fromExpense(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO clean up
    final theme = TransactionTheme(context);
    final incomeStyle = theme.createTextStyle(context, TransactionType.income);
    final expenseStyle = theme.createTextStyle(context, TransactionType.expense);
    final transferStyle = theme.createTextStyle(context, TransactionType.transfer);

    TextStyle? textStyle(TransactionType type) {
      return switch (type) {
        TransactionType.income => incomeStyle,
        TransactionType.expense => expenseStyle,
        TransactionType.transfer => transferStyle,
      };
    }

    IconData? amountSymbol(TransactionType type) {
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
                style: textStyle(mapped.first.type),
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        amountSymbol(mapped.first.type),
                        color: textStyle(mapped.first.type)?.color,
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
                  style: textStyle(x.type),
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(
                          amountSymbol(x.type),
                          color: textStyle(x.type)?.color,
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Import',
        onPressed: () async {
          await _importTransactions();
          await _importTransfers();

          if (context.mounted) {
            Navigator.of(context).pop(); // Description rules
            Navigator.of(context).pop(); // Map categories
            Navigator.of(context).pop(); // Map accounts
            Navigator.of(context).pop(); // Select databases
            Navigator.of(context).pop(); // Imports
            Navigator.of(context).pop(); // Sidebar
            Navigator.of(context).pop(); // Home
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _importTransactions() async {
    final newTransactions = _calculate().where((x) => x.transaction != null).map((x) => x.transaction!);
    final toBeInserted = <Transaction>[];
    final batch = database.batch();

    for (final newTransaction in newTransactions) {
      final newExpenses = newTransaction.expenses.toList();

      for (final newExpense in newTransaction.expenses) {
        final existingExpense = TransactionService.instance.expenses.firstWhereOrNull(
            (existing) => existing.importedWalletDbExpense?.recordId == newExpense.importedWalletDbExpense?.recordId);

        if (existingExpense != null) {
          final transaction = existingExpense.transaction;
          transaction.account = newExpense.transaction.account;
          batch.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);

          existingExpense.category = newExpense.category;
          batch.update('expenses', existingExpense.toMap(), where: 'id = ?', whereArgs: [existingExpense.id]);
          newExpenses.remove(newExpense);
        }
      }

      if (newExpenses.isNotEmpty) {
        toBeInserted.add(newTransaction);
      }
    }

    await batch.commit(noResult: true);
    await TransactionService.instance.addBulk(toBeInserted);
  }

  Future<void> _importTransfers() async {
    final newTransfers = _calculate().where((x) => x.transfer != null).map((x) => x.transfer!);
    final toBeInserted = <Transfer>[];
    final batch = database.batch();

    for (final newTransfer in newTransfers) {
      final existingTransfer = TransactionService.instance.transfers.firstWhereOrNull(
          (existing) => existing.importedWalletDbTransfer?.recordId == newTransfer.importedWalletDbTransfer?.recordId);

      if (existingTransfer != null) {
        existingTransfer.from = newTransfer.from;
        existingTransfer.to = newTransfer.to;
        batch.update('transfers', existingTransfer.toMap(), where: 'id = ?', whereArgs: [existingTransfer.id]);
        continue;
      }

      toBeInserted.add(newTransfer);
    }

    await batch.commit(noResult: true);
    await TransactionService.instance.addBulkTransfers(toBeInserted);
  }
}
