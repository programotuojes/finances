import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
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
import 'package:finances/utils/app_paths.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class WalletDbFinalPage extends StatelessWidget {
  final Map<String, Account> accountMap;
  final Map<String, CategoryModel> categoryMap;
  final List<wallet_db.Record> records;
  final List<Rule> rules;
  final Map<String, CategoryModel> manualOverrides;

  const WalletDbFinalPage({
    super.key,
    required this.accountMap,
    required this.categoryMap,
    required this.records,
    required this.rules,
    required this.manualOverrides,
  });

  @override
  Widget build(BuildContext context) {
    final convertedData = _convertWalletToNative().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview results'),
      ),
      body: convertedData.isNotEmpty
          ? ListView.builder(
              itemCount: convertedData.length,
              prototypeItem: _ListTile(tempCombined: convertedData.first),
              itemBuilder: (context, index) => _ListTile(tempCombined: convertedData[index]),
            )
          : Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No records'),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil(ModalRoute.withName(Navigator.defaultRouteName));
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go home'),
                ),
              ],
            )),
      floatingActionButton: convertedData.isEmpty
          ? null
          : FloatingActionButton.extended(
              label: const Text('Import'),
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () async {
                // Dismissed by popping after import finishes
                // ignore: unawaited_futures
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const PopScope(
                    canPop: false,
                    child: Dialog(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 24),
                            Text('Importing...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                await _import(convertedData);

                if (context.mounted) {
                  Navigator.of(context).popUntil(ModalRoute.withName(Navigator.defaultRouteName));
                  AppPaths.notifyListeners(); // In case imported on first launch
                }
              },
            ),
    );
  }

  Iterable<TempCombined> _convertWalletToNative() sync* {
    final transactionCache = <DateTime, Transaction>{};

    for (final record in records) {
      final money = Money.fromNumWithCurrency(record.amountReal.abs(), CommonCurrencies().euro);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(record.recordDate);

      if (record.transfer) {
        final fromAccount = accountMap[record.accountId];
        final toAccount = accountMap[record.transferAccountId];

        if (record.amountReal > 0 && fromAccount != null && toAccount != null) {
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

      final category = manualOverrides[record.id] ??
          rules.firstWhereOrNull((rule) => rule.regex.hasMatch(record.note))?.category ??
          categoryMap[record.categoryId] ??
          CategoryService.instance.otherCategory;

      final expense = Expense(
        transaction: transaction,
        money: money,
        category: category,
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

  Future<void> _import(List<TempCombined> convertedData) async {
    final existingTransfers = TransactionService.instance.transfers;
    final existingExpenses = TransactionService.instance.expenses;

    final importedTransfers = {
      for (final transfer in existingTransfers.where((e) => e.importedWalletDbTransfer != null))
        transfer.importedWalletDbTransfer!.recordId: transfer,
    };
    final importedExpenses = {
      for (final expense in existingExpenses.where((e) => e.importedWalletDbExpense != null))
        expense.importedWalletDbExpense!.recordId: expense
    };

    final batchUpdate = database.batch();
    final newTransfers = <Transfer>[];
    final newTransactions = <Transaction>{};

    for (final data in convertedData) {
      if (data.transfer != null) {
        final transfer = data.transfer!;
        final existingTransfer = importedTransfers[transfer.importedWalletDbTransfer?.recordId];

        if (existingTransfer == null) {
          newTransfers.add(transfer);
          continue;
        }

        existingTransfer.from = transfer.from;
        existingTransfer.to = transfer.to;
        existingTransfer.description = transfer.description;
        existingTransfer.dateTime = transfer.dateTime;
        existingTransfer.money = transfer.money;
        batchUpdate.update('transfers', existingTransfer.toMap(), where: 'id = ?', whereArgs: [existingTransfer.id]);
        continue;
      }

      if (data.expense != null) {
        final expense = data.expense!;
        final existingExpense = importedExpenses[expense.importedWalletDbExpense?.recordId];

        if (existingExpense == null) {
          newTransactions.add(expense.transaction);
          continue;
        }

        existingExpense.transaction.account = expense.transaction.account;
        batchUpdate.update(
          'transactions',
          {'accountId': expense.transaction.account.id},
          where: 'id = ?',
          whereArgs: [existingExpense.transaction.id],
        );

        existingExpense.category = expense.category;
        existingExpense.description = expense.description;
        existingExpense.money = expense.money;
        batchUpdate.update('expenses', existingExpense.toMap(), where: 'id = ?', whereArgs: [existingExpense.id]);
        continue;
      }
    }

    await batchUpdate.commit(noResult: true);
    await TransactionService.instance.addBulk(newTransactions);
    await TransactionService.instance.addBulkTransfers(newTransfers);
  }
}

// TODO probably could also use this on the home page
class _ListTile extends StatefulWidget {
  final TempCombined tempCombined;

  const _ListTile({
    required this.tempCombined,
  });

  @override
  State<_ListTile> createState() => __ListTileState();
}

class __ListTileState extends State<_ListTile> {
  @override
  Widget build(BuildContext context) {
    final amountIcon = switch (widget.tempCombined.type) {
      TransactionType.income => Icons.arrow_drop_up_rounded,
      TransactionType.expense => Icons.arrow_drop_down_rounded,
      TransactionType.transfer => null,
    };

    return ListTile(
      isThreeLine: true,
      title: Text(widget.tempCombined.category.name),
      leading: CategoryIconSquare(
        icon: widget.tempCombined.category.icon,
        color: widget.tempCombined.category.color,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.tempCombined.dateTime.toString().substring(0, 16)),
          Text(
            widget.tempCombined.description ?? '',
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                amountIcon,
                color: widget.tempCombined.type.color,
                size: 32,
              ),
              Text(
                widget.tempCombined.money.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.apply(
                      color: widget.tempCombined.type.color,
                    ),
              ),
            ],
          ),
          Text(widget.tempCombined.accountName),
        ],
      ),
      onTap: widget.tempCombined.transfer == null
          ? () async {
              final selectedCategory = await Navigator.push<CategoryModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryListPage(CategoryService.instance.rootCategory),
                ),
              );

              if (selectedCategory == null) {
                return;
              }

              setState(() {
                widget.tempCombined.category = selectedCategory;
              });
            }
          : null,
    );
  }
}
