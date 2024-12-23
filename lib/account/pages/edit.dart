import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/components/amount_text_field.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/currency_dropdown.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class AccountEditPage extends StatefulWidget {
  final Account? account;

  const AccountEditPage({super.key, this.account});

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  late final _editing = widget.account != null;
  var _autovalidateMode = AutovalidateMode.disabled;
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.account?.name);
  late final _initialAmountCtrl = TextEditingController(text: widget.account?.initialMoney.amount.toString());
  final _dialogAmountCtrl = TextEditingController();
  late var _currency = widget.account?.initialMoney.currency ?? CommonCurrencies().euro;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _initialAmountCtrl.dispose();
    _dialogAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit account' : 'Create new account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 32),
              AmountTextField(
                controller: _initialAmountCtrl,
                onFieldSubmitted: (value) {
                  _submit();
                },
                labelText: 'Initial amount',
                suffixIcon: Visibility(
                  visible: widget.account != null,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: IconButton(
                      onPressed: () async {
                        await _recalculate();
                      },
                      tooltip: 'Calculate based on current amount',
                      icon: const Icon(Icons.calculate_rounded),
                    ),
                  ),
                ),
                currency: _currency,
              ),
              const SizedBox(height: 32),
              CurrencyDropdown(
                currency: _currency,
                onChange: (newCurrency) {
                  setState(() {
                    _currency = newCurrency;
                  });
                },
              ),
              const SizedBox(height: fabHeight),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submit();
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });

      return;
    }

    Account? createdAccount;

    if (_editing) {
      await AccountService.instance.update(
        widget.account!,
        name: _nameCtrl.text,
        initialMoney: _initialAmountCtrl.text.toMoneyWithCurrency(_currency)!,
      );
    } else {
      createdAccount = await AccountService.instance.add(
        name: _nameCtrl.text,
        initialMoney: _initialAmountCtrl.text.toMoneyWithCurrency(_currency)!,
      );
    }

    if (mounted) {
      Navigator.of(context).pop(createdAccount);
    }
  }

  Future<void> _recalculate() async {
    _dialogAmountCtrl.clear();

    var agreed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recalculate the initial amount'),
        content: SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will be done using your saved transactions.'),
              const SizedBox(height: 16),
              AmountTextField(
                controller: _dialogAmountCtrl,
                currency: _currency,
                labelText: 'Current amount',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ListenableBuilder(
              listenable: _dialogAmountCtrl,
              builder: (context, child) {
                var money = _dialogAmountCtrl.text.toMoneyWithCurrency(_currency);
                return TextButton(
                  onPressed: money != null && money != _currency.zero()
                      ? () {
                          Navigator.of(context).pop(true);
                        }
                      : null,
                  child: const Text('Recalculate'),
                );
              }),
        ],
      ),
    );

    if (agreed != true) {
      return;
    }

    var currentMoney = _dialogAmountCtrl.text.toMoneyWithCurrency(_currency)!;

    final newInitial = calculateInitialAmount(
      currentMoney,
      TransactionService.instance.expenses,
      TransactionService.instance.transfers,
      widget.account!, // Covered by the Visibility() widget
    );

    setState(() {
      _initialAmountCtrl.text = newInitial.amount.toString();
    });
  }
}

Money calculateInitialAmount(
  Money current,
  Iterable<Expense> expenses,
  Iterable<Transfer> transfers,
  Account account,
) {
  var expenseAndIncome = expenses
      .where((expense) => expense.transaction.account == account)
      .map((expense) => expense.signedMoney.toFixed())
      .fold(Fixed.zero, (acc, x) => acc + x);

  var totalTransfers = Fixed.zero;
  for (final transfer in transfers) {
    if (transfer.from == account && transfer.to == account) {
      // Ignored
      // Could happen in case multiple separate imported accounts were mapped to a single app account
      continue;
    }

    if (transfer.from == account) {
      totalTransfers += transfer.money.toFixed();
    } else if (transfer.to == account) {
      totalTransfers -= transfer.money.toFixed();
    }
  }

  return Money.fromFixedWithCurrency(
    current.toFixed() - expenseAndIncome + totalTransfers,
    current.currency,
  );
}
