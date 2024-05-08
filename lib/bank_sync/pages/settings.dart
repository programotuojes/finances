import 'dart:io';

import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/bank_sync/services/bank_background_sync_service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

const _uniqueTaskName = backgroundBankSyncTaskName;
const backgroundBankSyncTaskName = 'bank sync';

class BankSyncSettings extends StatefulWidget {
  const BankSyncSettings({super.key});

  @override
  State<BankSyncSettings> createState() => _BankSyncSettingsState();
}

class _BankSyncSettingsState extends State<BankSyncSettings> {
  final _options = BankBackgroundSyncService.instance;

  @override
  Widget build(BuildContext context) {
    var hasWorkmanager = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank sync settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable daily syncing'),
            subtitle: const Text('Only available on mobile'),
            value: _options.enabled,
            onChanged: hasWorkmanager
                ? (value) async {
                    if (_options.enabled) {
                      await _cancelTask();
                    } else {
                      await _registerTask();
                    }

                    setState(() {
                      _options.setEnabled(value);
                    });
                  }
                : null,
          ),
          ListTile(
            onTap: () async {
              await _selectTime();
            },
            enabled: _options.enabled,
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Time of day'),
            subtitle: Text(_options.time.format(context)),
          ),
          ListTile(
            onTap: () async {
              await _showAccountSelection(context);
            },
            enabled: _options.enabled,
            leading: const Icon(Icons.account_balance_rounded),
            title: const Text('Account'),
            subtitle: Text(_options.account.name),
          ),
          ListTile(
            onTap: () async {
              var selectedCategory = await Navigator.push<CategoryModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryListPage(CategoryService.instance.rootCategory),
                ),
              );

              if (selectedCategory == null) {
                return;
              }

              setState(() {
                _options.setDefaultCategory(selectedCategory);
              });
            },
            enabled: _options.enabled,
            leading: Icon(_options.defaultCategory.icon),
            title: const Text('Default category'),
            subtitle: Text(
                '"${_options.defaultCategory.name}" will be used for expenses that do not match any automation rules'),
          ),
          SwitchListTile(
            title: const Text('Set description'),
            subtitle: const Text('Use the remittance info field as the expense description'),
            secondary: const Icon(Icons.description),
            value: _options.remittanceInfoAsDescription,
            onChanged: _options.enabled
                ? (value) {
                    setState(() {
                      _options.setRemittanceInfoAsDescription(value);
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    var selected = await showTimePicker(
      context: context,
      initialTime: _options.time,
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _options.setTime(selected);
    });
  }

  Future<void> _registerTask() async {
    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      backgroundBankSyncTaskName,
      frequency: const Duration(days: 1),
      initialDelay: Duration.zero, // TODO calculate initial delay to avoid running it instantly
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  Future<void> _cancelTask() {
    return Workmanager().cancelByUniqueName(_uniqueTaskName);
  }

  Future<void> _showAccountSelection(BuildContext context) async {
    var account = await showDialog<Account>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose an account'),
        children: [
          for (var account in AccountService.instance.accounts)
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop(account);
              },
              child: Text(account.name),
            ),
        ],
      ),
    );

    if (account == null) {
      return;
    }

    setState(() {
      _options.setAccount(account);
    });
  }
}
