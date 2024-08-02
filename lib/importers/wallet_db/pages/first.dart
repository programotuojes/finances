import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:finances/importers/wallet_db/models.dart';
import 'package:finances/importers/wallet_db/pages/accounts.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class WalletDbFirstPage extends StatefulWidget {
  const WalletDbFirstPage({super.key});

  @override
  State<WalletDbFirstPage> createState() => _WalletDbFirstPageState();
}

class _WalletDbFirstPageState extends State<WalletDbFirstPage> {
  var _loadingRecords = false;
  var _loadingMaps = false;
  List<Record>? _records;
  List<Account>? _accounts;
  List<Category>? _categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Wallet (database files)'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SelectionArea(
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
                        Text.rich(
                          TextSpan(
                            text: "Copy these files from your Android device's folder ",
                            children: [
                              TextSpan(
                                text: '/data/data/com.droid4you.application.wallet',
                                style: TextStyle(fontFamily: 'monospace'),
                              ),
                              TextSpan(text: ' to somewhere regular apps can access files (e.g. "Downloads").'),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            text: '\u2022 ',
                            children: [
                              TextSpan(text: 'databases/<guid>-records.db', style: TextStyle(fontFamily: 'monospace'))
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: '\u2022 ',
                            children: [
                              TextSpan(
                                  text: 'files/local-<guid>.cblite2/db.sqlite3',
                                  style: TextStyle(fontFamily: 'monospace'))
                            ],
                          ),
                        ),
                        Text('• include files ending in "-shm" and "-wal"'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Database of records'),
              subtitle: _records == null
                  ? const Text('Tap to select records.db')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_records!.length} records'),
                        Text(
                            'Last recorded on ${DateTime.fromMillisecondsSinceEpoch(_records!.first.recordDate).toString().substring(0, 19)}'),
                        Text('Last amount ${_records!.first.amountReal}'),
                      ],
                    ),
              trailing: _loadingRecords ? const CircularProgressIndicator() : null,
              onTap: _onRecordDatabase,
            ),
            if (_records != null)
              ListTile(
                title: const Text('Database of maps'),
                subtitle: _accounts == null || _categories == null
                    ? const Text('Tap to select db.sqlite3')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Accounts: ${_accounts!.map((e) => e.name).join(', ')}'),
                          Text('${_categories!.length} categories'),
                        ],
                      ),
                trailing: _loadingMaps ? const CircularProgressIndicator() : null,
                onTap: _onMapsDatabase,
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _records == null || _accounts == null || _categories == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletDbAccountPage(
                            walletAccounts: _accounts!,
                            walletCategories: _categories!,
                            records: _records!,
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

  Future<void> _onRecordDatabase() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: '<guid>-records.db', extensions: ['db'])
      ],
    );

    if (file == null) {
      return;
    }

    setState(() => _loadingRecords = true);
    Database? db;

    try {
      db = await openDatabase(file.path);

      final recordRows = await db.query(
        'records',
        columns: [
          '_id',
          'note',
          'accountId',
          'categoryId',
          'recordDate',
          'amountReal',
          'transfer',
          'transferAccountId',
          'transferId',
        ],
        orderBy: 'recordDate desc',
      );

      final mapped = recordRows
          .map((row) => Record(
                id: row['_id'] as String,
                note: row['note'] as String,
                accountId: row['accountId'] as String,
                categoryId: row['categoryId'] as String,
                recordDate: row['recordDate'] as int,
                amountReal: row['amountReal'] as double,
                transfer: row['transfer'] as int == 1,
                transferAccountId: row['transferAccountId'] as String?,
                transferId: row['transferId'] as String?,
              ))
          .toList();

      setState(() {
        _records = mapped;
      });
    } catch (e) {
      _onFail('Failed to get records', e.toString());
      setState(() => _records = null);
    } finally {
      setState(() => _loadingRecords = false);
      await db?.close();
    }
  }

  Future<void> _onMapsDatabase() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'db.sqlite3', extensions: ['sqlite3'])
      ],
    );

    if (file == null) {
      return;
    }

    setState(() => _loadingMaps = true);
    Database? db;

    try {
      db = await openDatabase(file.path);

      final accountJsons = await db.query('maps_6', columns: ['value']);
      final accounts = accountJsons.map((row) {
        final json = jsonDecode(row['value'] as String);
        return Account(
          id: json['_id'] as String,
          name: json['name'] as String,
        );
      }).toList();

      final categoryJsons = await db.query('maps_7', columns: ['value']);
      final categories = categoryJsons.map((row) {
        final json = jsonDecode(row['value'] as String);
        return Category(
          id: json['_id'] as String,
          name: json['name'] as String,
        );
      }).toList();

      setState(() {
        _accounts = accounts;
        _categories = categories;
      });
    } catch (e) {
      _onFail('Failed to get accounts and categories', e.toString());
      setState(() {
        _accounts = null;
        _categories = null;
      });
    } finally {
      setState(() => _loadingMaps = false);
      await db?.close();
    }
  }

  void _onFail(String snackBarText, String exceptionMessage) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(snackBarText),
      action: SnackBarAction(
        label: 'Details',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exception message'),
              content: SingleChildScrollView(
                child: Text(
                  exceptionMessage,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                )
              ],
            ),
          );
        },
      ),
    ));
  }
}
