import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class ImportRecordsPage extends StatelessWidget {
  final List<wallet_db.Record> records;
  final Map<String, String> categories;
  final Map<String, String> accounts;
  final Map<String, CategoryModel> manualOverrides;

  const ImportRecordsPage({
    super.key,
    required this.records,
    required this.categories,
    required this.accounts,
    required this.manualOverrides,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet records'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Help'),
                  content: const SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You can override the category that will be used for individual '
                            'records by clicking on them. To clear the mapping, long press on '
                            'the list item.'),
                        SizedBox(height: 8),
                        Text('This takes precedence over all other category maps.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: records.isNotEmpty
          ? ListView.builder(
              itemCount: records.length,
              prototypeItem: _ListTile(
                record: records.first,
                categories: categories,
                accounts: accounts,
                manualOverrides: manualOverrides,
              ),
              itemBuilder: (context, index) {
                return _ListTile(
                  record: records[index],
                  categories: categories,
                  accounts: accounts,
                  manualOverrides: manualOverrides,
                );
              },
            )
          : const Center(
              child: Text('No records'),
            ),
    );
  }
}

class _ListTile extends StatefulWidget {
  final wallet_db.Record record;
  final Map<String, String> categories;
  final Map<String, String> accounts;
  final Map<String, CategoryModel> manualOverrides;

  const _ListTile({
    required this.record,
    required this.categories,
    required this.accounts,
    required this.manualOverrides,
  });

  @override
  State<_ListTile> createState() => __ListTileState();
}

class __ListTileState extends State<_ListTile> {
  @override
  Widget build(BuildContext context) {
    var title = widget.categories[widget.record.categoryId]!;
    final overriddenCategory = widget.manualOverrides[widget.record.id];
    if (overriddenCategory != null) {
      title += ' (${overriddenCategory.name})';
    }

    return ListTile(
      isThreeLine: true,
      titleTextStyle:
          overriddenCategory != null ? Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 2) : null,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.accounts[widget.record.accountId]!),
          Text(widget.record.note),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Money.fromNumWithCurrency(widget.record.amountReal, CommonCurrencies().euro).toString(),
            textScaler: const TextScaler.linear(1.3),
            style: TextStyle(
              color: widget.record.amountReal > 0 ? Colors.green : Colors.red,
            ),
          ),
          Text(DateTime.fromMillisecondsSinceEpoch(widget.record.recordDate).toString().substring(0, 19))
        ],
      ),
      onTap: () async {
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
          widget.manualOverrides[widget.record.id] = selectedCategory;
        });
      },
      onLongPress: () {
        final previous = widget.manualOverrides[widget.record.id];
        if (previous == null) {
          return;
        }

        setState(() {
          widget.manualOverrides.remove(widget.record.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Removed override'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              widget.manualOverrides[widget.record.id] = previous;

              if (context.mounted) {
                setState(() {
                    // The set isn't here in case the undo button is pressed on a different screen
                });
              }
            },
          ),
        ));
      },
    );
  }
}
