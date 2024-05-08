import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/bank_sync/go_cardless_http_client.dart';
import 'package:finances/bank_sync/models/bank_transaction.dart';
import 'package:finances/bank_sync/services/go_cardless_service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class BankTransactionList extends StatefulWidget {
  const BankTransactionList({super.key});

  @override
  State<BankTransactionList> createState() => _BankTransactionListState();
}

class _BankTransactionListState extends State<BankTransactionList> {
  var _index = 0;
  var _transactions = BankTransactions(
    booked: [],
    pending: [],
  );
  var _account = AccountService.instance.lastSelection;
  var _importing = false;
  var _remittanceInfoAsDescription = false;
  var _importCategory = CategoryService.instance.otherCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank transactions'),
        actions: [
          IconButton(
            onPressed: _fetchTransactions,
            tooltip: 'Fetch',
            icon: const Icon(Symbols.sync_rounded),
          ),
        ],
      ),
      body: [
        list(_transactions.booked),
        list(_transactions.pending),
      ][_index],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.assignment_turned_in_rounded),
            icon: Icon(Icons.assignment_turned_in_outlined),
            label: 'Booked',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.hourglass_bottom_rounded),
            icon: Icon(Icons.hourglass_empty_rounded),
            label: 'Pending',
          )
        ],
      ),
      floatingActionButton: Visibility(
        visible: _index == 0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            var importing = await _setImportOptions();
            if (importing != true) {
              return;
            }

            try {
              setState(() {
                _importing = true;
              });
              await GoCardlessSerivce.instance.importTransactions(
                account: _account,
                remittanceInfoAsDescription: _remittanceInfoAsDescription,
                defaultCategory: _importCategory,
              );
            } finally {
              if (context.mounted) {
                setState(() {
                  _importing = false;
                });
              }
            }
          },
          label: const Text('Import'),
          icon: _importing
              ? const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CircularProgressIndicator(),
                )
              : const Icon(Symbols.download_rounded),
        ),
      ),
    );
  }

  Widget list(List<BankTransaction> tr) {
    if (tr.isEmpty) {
      return const Center(child: Text('Empty list'));
    }

    return ListView.separated(
      itemCount: tr.length,
      separatorBuilder: (builder, index) {
        return const Divider();
      },
      itemBuilder: (builder, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BankTransactionProp('transactionId', tr[index].transactionId),
            _BankTransactionProp('entryReference', tr[index].entryReference),
            _BankTransactionProp('endToEndId', tr[index].endToEndId),
            _BankTransactionProp('mandateId', tr[index].mandateId),
            _BankTransactionProp('checkId', tr[index].checkId),
            _BankTransactionProp('creditorId', tr[index].creditorId),
            _BankTransactionProp('bookingDate', tr[index].bookingDate),
            _BankTransactionProp('valueDate', tr[index].valueDate),
            _BankTransactionProp('bookingDateTime', tr[index].bookingDateTime.toString()),
            _BankTransactionProp('valueDateTime', tr[index].valueDateTime),
            _BankTransactionProp(
              'transactionAmount.amount',
              tr[index].transactionAmount?.amount,
            ),
            _BankTransactionProp(
              'transactionAmount.currency',
              tr[index].transactionAmount?.currency,
            ),
            _BankTransactionProp(
              'currencyExchange.targetExchange',
              tr[index].currencyExchange?.targetCurrency,
            ),
            _BankTransactionProp(
              'creditorName',
              tr[index].creditorName,
            ),
            _BankTransactionProp(
              'creditorAccount.iban',
              tr[index].creditorAccount?.iban,
            ),
            _BankTransactionProp(
              'ultimateCreditor',
              tr[index].ultimateCreditor,
            ),
            _BankTransactionProp(
              'debtorName',
              tr[index].debtorName,
            ),
            _BankTransactionProp(
              'debtorAccount.iban',
              tr[index].debtorAccount?.iban,
            ),
            _BankTransactionProp(
              'ultimateDebtor',
              tr[index].ultimateDebtor,
            ),
            _BankTransactionProp(
              'remittanceInformationUnstructured',
              tr[index].remittanceInformationUnstructured,
            ),
            for (var i in tr[index].remittanceInformationUnstructuredArray ?? [])
              _BankTransactionProp('remittanceInformationUnstructuredArray', i),
            _BankTransactionProp(
              'remittanceInformationStructured',
              tr[index].remittanceInformationStructured,
            ),
            for (var i in tr[index].remittanceInformationStructuredArray ?? [])
              _BankTransactionProp('remittanceInformationStructuredArray', i),
            _BankTransactionProp(
              'additionalInformation',
              tr[index].additionalInformation,
            ),
            _BankTransactionProp(
              'purposeCode',
              tr[index].purposeCode,
            ),
            _BankTransactionProp(
              'bankTransactionCode',
              tr[index].bankTransactionCode,
            ),
            _BankTransactionProp(
              'proprietaryBankTransactionCode',
              tr[index].proprietaryBankTransactionCode,
            ),
            _BankTransactionProp(
              'internalTransactionId',
              tr[index].internalTransactionId,
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchTransactions() async {
    var accountId = GoCardlessSerivce.instance.requisition?.accounts.first;
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requisition not found'),
        ),
      );
      return;
    }

    var result = await GoCardlessHttpClient.getTransactions(accountId);
    result.match(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requisition not found'),
          ),
        );
      },
      (transactions) {
        setState(() {
          _transactions = transactions;
        });
      },
    );
  }

  Future<bool?> _setImportOptions() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownMenu<Account>(
                expandedInsets: const EdgeInsets.all(0),
                initialSelection: _account,
                label: const Text('Account'),
                onSelected: (selected) {
                  if (selected == null) {
                    return;
                  }
                  _account = selected;
                },
                dropdownMenuEntries: [
                  for (final x in AccountService.instance.accounts) DropdownMenuEntry(value: x, label: x.name)
                ],
              ),
              StatefulBuilder(
                builder: (context, setter) {
                  return SwitchListTile(
                    title: const Text('Set description'),
                    subtitle: const Text('Use the remittance info field as the expense description'),
                    value: _remittanceInfoAsDescription,
                    onChanged: (value) {
                      setter(() {
                        _remittanceInfoAsDescription = value;
                      });
                    },
                  );
                },
              ),
              StatefulBuilder(
                builder: (context, setter) {
                  return ListTile(
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

                      CategoryService.instance.lastSelection = selectedCategory;
                      setter(() {
                        _importCategory = selectedCategory;
                      });
                    },
                    title: const Text('Default category'),
                    subtitle: Text(
                        '"${_importCategory.name}" will be used for expenses that did not match any automation rules'),
                    trailing: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CategoryIcon(
                        icon: _importCategory.icon,
                        color: _importCategory.color,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }
}

class _BankTransactionProp extends StatelessWidget {
  final String _name;
  final String? _text;

  const _BankTransactionProp(this._name, this._text);

  @override
  Widget build(BuildContext context) {
    if (_text == null) {
      return const SizedBox.shrink();
    }

    return SelectableText('$_name = $_text');
  }
}
