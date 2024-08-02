import 'dart:ui';

import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/importers/wallet_db/pages/final.dart';
import 'package:finances/importers/wallet_db/pages/records.dart';
import 'package:finances/transaction/components/category_list_tile.dart';
import 'package:finances/transaction/components/text_field_list_tile.dart';
import 'package:flutter/material.dart';

class WalletDbDescriptionsPage extends StatefulWidget {
  final List<wallet_db.Record> records;
  final List<wallet_db.Account> walletAccounts;
  final List<wallet_db.Category> walletCategories;
  final Map<String, Account> accountMap;
  final Map<String, CategoryModel> categoryMap;

  const WalletDbDescriptionsPage({
    super.key,
    required this.records,
    required this.walletAccounts,
    required this.walletCategories,
    required this.accountMap,
    required this.categoryMap,
  });

  @override
  State<WalletDbDescriptionsPage> createState() => _WalletDbDescriptionsPageState();
}

class _WalletDbDescriptionsPageState extends State<WalletDbDescriptionsPage> {
  final _rules = <Rule>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Description rules')),
      body: ReorderableListView.builder(
        shrinkWrap: true,
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final rule = _rules[index];
          return _RuleTile(
            key: ObjectKey(rule),
            records: widget.records,
            walletAccounts: widget.walletAccounts,
            walletCategories: widget.walletCategories,
            rule: rule,
            index: index,
            onDelete: () {
              setState(() {
                _rules.removeAt(index);
              });
            },
          );
        },
        itemCount: _rules.length,
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final animValue = Curves.easeInOut.transform(animation.value);
            final elevation = lerpDouble(0, 6, animValue)!;
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: Colors.black12,
              child: child,
            );
          },
          child: child,
        ),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final movedItem = _rules.removeAt(oldIndex);
          setState(() {
            _rules.insert(newIndex, movedItem);
          });
        },
        header: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              margin: const EdgeInsets.all(16),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text('Info', textScaler: TextScaler.linear(1.2)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Create rules to set the category based on the description.'),
                    SizedBox(height: 8),
                    Text(
                      'These override category mappings from the previous page. '
                      'If a record is matched by multiple rules, the top most takes precedence.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        footer: Column(
          children: [
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                final rule = Rule(
                  regex: RegExp(''),
                  category: CategoryService.instance.otherCategory,
                );
                setState(() {
                  _rules.add(rule);
                });
              },
              label: const Text('New rule'),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletDbFinalPage(
                      accountMap: widget.accountMap,
                      categoryMap: widget.categoryMap,
                      records: widget.records,
                      rules: _rules,
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

class _RuleTile extends StatefulWidget {
  final List<wallet_db.Record> records;
  final List<wallet_db.Account> walletAccounts;
  final List<wallet_db.Category> walletCategories;
  final Rule rule;
  final int index;
  final VoidCallback onDelete;

  const _RuleTile({
    super.key,
    required this.records,
    required this.walletAccounts,
    required this.walletCategories,
    required this.rule,
    required this.index,
    required this.onDelete,
  });

  @override
  State<_RuleTile> createState() => __RuleTileState();
}

class __RuleTileState extends State<_RuleTile> {
  late final _textCtrl = TextEditingController(text: widget.rule.regex.pattern);
  late var _filteredRecords = widget.records.toList();

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() {
      final regex = RegExp(_textCtrl.text);
      widget.rule.regex = regex;
      setState(() {
        _filteredRecords = widget.records.where((element) => regex.hasMatch(element.note)).toList();
      });
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  String _counterText() {
    if (_filteredRecords.length == 1) {
      return '1 record';
    }

    return '${_filteredRecords.length} records';
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: widget.index,
      child: Card.outlined(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFieldListTile(
                      controller: _textCtrl,
                      hintText: 'Regex',
                      icon: Icons.text_fields,
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImportRecordsPage(
                              accounts: {for (final x in widget.walletAccounts) x.id: x.name},
                              categories: {for (final x in widget.walletCategories) x.id: x.name},
                              records: _filteredRecords,
                            ),
                          ),
                        );
                      },
                      title: Text(_counterText()),
                      leading: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.functions),
                      ),
                    ),
                    CategoryListTile(
                      initialCategory: CategoryService.instance.otherCategory,
                      onCategorySelected: (selected) {
                        widget.rule.category = selected;
                      },
                      morePadding: false,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                tooltip: 'Delete',
                icon: const Icon(Icons.close),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Rule {
  RegExp regex;
  CategoryModel category;

  Rule({
    required this.regex,
    required this.category,
  });
}
