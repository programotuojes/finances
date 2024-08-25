import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/importers/wallet_db/pages/descriptions.dart';
import 'package:finances/importers/wallet_db/pages/records.dart';
import 'package:finances/transaction/components/category_list_tile.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class WalletDbCategoryPage extends StatefulWidget {
  final List<wallet_db.Account> walletAccounts;
  final List<wallet_db.Category> walletCategories;
  final List<wallet_db.Record> records;
  final Map<String, Account> accountMap;

  const WalletDbCategoryPage({
    super.key,
    required this.walletAccounts,
    required this.walletCategories,
    required this.records,
    required this.accountMap,
  });

  @override
  State<WalletDbCategoryPage> createState() => _WalletDbCategoryPageState();
}

class _WalletDbCategoryPageState extends State<WalletDbCategoryPage> {
  final Map<String, CategoryModel> _categoryMap = {};
  var _sortBy = _SortBy.totalMoney;
  late final List<_CalculatedCategory> _sortedCategories = widget.walletCategories
      .whereNot((x) => x.name == 'Transfer')
      .map((e) => _CalculatedCategory(e, widget.records))
      .where((element) => element.numOfRecords > 0)
      .sorted((a, b) => b.totalMoney.amount.abs.compareTo(a.totalMoney.amount.abs))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map categories'),
        actions: [
          MenuAnchor(
            menuChildren: [
              for (final sortValue in _SortBy.values)
                RadioMenuButton<_SortBy>(
                  value: sortValue,
                  groupValue: _sortBy,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _sortBy = value;
                      _sortedCategories.sort((a, b) {
                        return switch (_sortBy) {
                          _SortBy.numOfRecords => b.numOfRecords.compareTo(a.numOfRecords),
                          _SortBy.totalMoney => b.totalMoney.amount.abs.compareTo(a.totalMoney.amount.abs),
                        };
                      });
                    });
                  },
                  child: Text(sortValue.title),
                ),
            ],
            builder: (context, controller, child) => IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              tooltip: 'Sort by',
              icon: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Wallet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Local',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            for (final walletCategory in _sortedCategories)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(walletCategory.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${walletCategory.numOfRecords} ${walletCategory.numOfRecords == 1 ? 'record' : 'records'}'),
                          Text(walletCategory.totalMoney.toString()),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImportRecordsPage(
                              accounts: {for (final x in widget.walletAccounts) x.id: x.name},
                              categories: {for (final x in widget.walletCategories) x.id: x.name},
                              records:
                                  widget.records.where((element) => element.categoryId == walletCategory.id).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.arrow_right),
                  Expanded(
                    child: CategoryListTile(
                      key: ObjectKey(walletCategory),
                      initialCategory: _categoryMap[walletCategory.id] ?? CategoryService.instance.otherCategory,
                      onCategorySelected: (selected) {
                        setState(() {
                          _categoryMap[walletCategory.id] = selected;
                        });
                      },
                      morePadding: false,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletDbDescriptionsPage(
                      walletAccounts: widget.walletAccounts,
                      walletCategories: widget.walletCategories,
                      records: widget.records,
                      accountMap: widget.accountMap,
                      categoryMap: _categoryMap,
                    ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

enum _SortBy {
  numOfRecords('Number of records'),
  totalMoney('Total money');

  const _SortBy(this.title);
  final String title;
}

class _CalculatedCategory extends wallet_db.Category {
  int numOfRecords = 0;
  Money totalMoney = zeroEur;

  _CalculatedCategory(
    wallet_db.Category category,
    List<wallet_db.Record> records,
  ) : super(id: category.id, name: category.name) {
    for (final record in records) {
      if (record.categoryId != id) {
        continue;
      }

      numOfRecords += 1;
      totalMoney += Money.fromNumWithCurrency(record.amountReal, CommonCurrencies().euro);
    }
  }
}
