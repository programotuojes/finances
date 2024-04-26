import 'package:finances/bank_sync/go_cardless_http_client.dart';
import 'package:finances/bank_sync/models/bank_transaction.dart';
import 'package:finances/bank_sync/service.dart';
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
            _BankTransactionProp('bookingDateTime', tr[index].bookingDateTime),
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
            for (var i
                in tr[index].remittanceInformationUnstructuredArray ?? [])
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
    result.match((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requisition not found'),
        ),
      );
    }, (transactions) {
      setState(() {
        _transactions = transactions;
      });
    });
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

    return Text('$_name = $_text');
  }
}
