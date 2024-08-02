import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class ImportRecordsPage extends StatelessWidget {
  final List<wallet_db.Record> records;
  final Map<String, String> categories;
  final Map<String, String> accounts;

  const ImportRecordsPage({
    super.key,
    required this.records,
    required this.categories,
    required this.accounts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet records')),
      body: ListView.builder(
        itemCount: records.length,
        prototypeItem: _listTile(context, records.firstOrNull),
        itemBuilder: (context, index) {
          final record = records[index];
          return _listTile(context, record);
        },
      ),
    );
  }

  Widget? _listTile(BuildContext context, wallet_db.Record? record) {
    if (record == null) {
      return null;
    }

    return ListTile(
      isThreeLine: true,
      title: Text(categories[record.categoryId]!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(accounts[record.accountId]!),
          Text(record.note),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Money.fromNumWithCurrency(record.amountReal, CommonCurrencies().euro).toString(),
            textScaler: const TextScaler.linear(1.3),
            style: TextStyle(
              color: record.amountReal > 0 ? Colors.green : Colors.red,
            ),
          ),
          Text(DateTime.fromMillisecondsSinceEpoch(record.recordDate).toString().substring(0, 19))
        ],
      ),
    );
  }
}
