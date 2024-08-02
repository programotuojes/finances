import 'package:finances/account/models/account.dart';
import 'package:finances/account/pages/edit.dart';
import 'package:finances/account/service.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/importers/wallet_db/pages/categories.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

final _createNew = Account(name: '', initialMoney: zeroEur);

class WalletDbAccountPage extends StatefulWidget {
  final List<wallet_db.Account> walletAccounts;
  final List<wallet_db.Category> walletCategories;
  final List<wallet_db.Record> records;

  const WalletDbAccountPage({
    super.key,
    required this.walletAccounts,
    required this.walletCategories,
    required this.records,
  });

  @override
  State<WalletDbAccountPage> createState() => _WalletDbAccountPageState();
}

class _WalletDbAccountPageState extends State<WalletDbAccountPage> {
  final Map<String, Account> _accountMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map accounts')),
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
            for (final walletAccount in widget.walletAccounts)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(walletAccount.name),
                    ),
                  ),
                  const Icon(Icons.arrow_right),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListenableBuilder(
                        listenable: AccountService.instance,
                        builder: (context, child) {
                          return DropdownMenu<Account>(
                            key: UniqueKey(),
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: _accountMap[walletAccount.id],
                            hintText: 'Select an account',
                            onSelected: (selected) async {
                              if (selected == null) {
                                return;
                              }

                              if (selected == _createNew) {
                                final createdAccount = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AccountEditPage(),
                                  ),
                                );
                                setState(() {
                                  if (createdAccount != null) {
                                    _accountMap[walletAccount.id] = createdAccount;
                                  }
                                });
                                return;
                              }

                              setState(() {
                                _accountMap[walletAccount.id] = selected;
                              });
                            },
                            dropdownMenuEntries: [
                              for (final account in AccountService.instance.accounts)
                                DropdownMenuEntry(value: account, label: account.name),
                              DropdownMenuEntry(value: _createNew, label: 'Create new...'),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _accountMap.length != widget.walletAccounts.length
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletDbCategoryPage(
                            walletAccounts: widget.walletAccounts,
                            walletCategories: widget.walletCategories,
                            records: widget.records,
                            accountMap: _accountMap,
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
