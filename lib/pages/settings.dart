import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/bank_sync/services/bank_background_sync_service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

const _uniqueTaskName = backgroundBankSyncTaskName;
const backgroundBankSyncTaskName = 'bank sync';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _options = BankBackgroundSyncService.instance;

  @override
  Widget build(BuildContext context) {
    var hasWorkmanager = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const SizedBox.shrink(),
            title: Text(
              'General',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            onTap: () async {
              // `permission_handler` supported platforms
              if ((Platform.isAndroid || Platform.isIOS || kIsWeb || Platform.isWindows) &&
                  !await Permission.storage.request().isGranted &&
                  !await Permission.manageExternalStorage.isGranted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Don't have storage permissions"),
                      action: SnackBarAction(
                        label: 'Open settings',
                        onPressed: () async {
                          await openAppSettings();
                        },
                      ),
                    ),
                  );
                }
                return;
              }

              var dir = await getDirectoryPath();
              if (dir != null) {
                await AppPaths.setAppPath(dir);
                setState(() {});
              }
            },
            leading: const Icon(Icons.folder_open),
            title: const Text('Location'),
            subtitle: Text(AppPaths.base),
          ),
          ListTile(
            onTap: () async {
              await AppPaths.setAppPath(AppPaths.baseDefault);
              setState(() {});
            },
            leading: const SizedBox.shrink(),
            title: const Text('Reset to default location'),
            // subtitle: Text(AppPaths.baseDefault),
          ),
          const Divider(),
          ListTile(
            leading: const SizedBox.shrink(),
            title: Text(
              'Automatic bank syncing',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          SwitchListTile(
            secondary: const SizedBox.shrink(),
            title: const Text('Daily bank sync'),
            subtitle: !hasWorkmanager ? const Text('Only available on mobile') : null,
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
              await _registerTask();
            },
            enabled: _options.enabled,
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Time of day'),
            subtitle: Text(_options.time.format(context)),
          ),
          ListTile(
            onTap: () async {
              await _showAccountSelection(context);
              await _registerTask();
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

              await _registerTask();
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
                ? (value) async {
                    setState(() {
                      _options.setRemittanceInfoAsDescription(value);
                    });
                    await _registerTask();
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
    var now = DateTime.now();
    var then = now.copyWith(hour: _options.time.hour, minute: _options.time.minute);

    if (now.isAfter(then)) {
      then.add(const Duration(days: 1));
    }

    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      backgroundBankSyncTaskName,
      frequency: const Duration(days: 1),
      initialDelay: then.difference(now),
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
