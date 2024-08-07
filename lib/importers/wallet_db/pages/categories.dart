import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/importers/wallet_db/pages/final.dart';
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
  var _sortBy = _SortBy.numOfRecords;
  late final List<_CalculatedCategory> _sortedCategories = widget.walletCategories
      .map((e) => _CalculatedCategory(e, widget.records))
      .sorted((a, b) => b.numOfRecords.compareTo(a.numOfRecords))
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
                        )),
                  ),
                  const Icon(Icons.arrow_right),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WalletDbFinalPage(
                        accountMap: widget.accountMap,
                        categoryMap: _categoryMap,
                        records: widget.records,
                      ),
                    ),
                  );
                },
                child: const Text('Preview result'),
              ),
            ),
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
