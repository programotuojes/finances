import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/amount_input_formatter.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

class AccountEditPage extends StatefulWidget {
  final Account? account;

  const AccountEditPage({super.key, this.account});

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  var autovalidateMode = AutovalidateMode.disabled;
  final formKey = GlobalKey<FormState>();
  late String formAccountName;
  late String formBalance;
  final _currentAmountCtrl = TextEditingController();
  late final _initialAmountCtrl = TextEditingController(text: widget.account?.initialMoney.amount.toString());

  @override
  void dispose() {
    _currentAmountCtrl.dispose();
    _initialAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account?.name ?? 'Create a new account'),
      ),
      body: Padding(
        padding: scaffoldPadding,
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) => formAccountName = value!,
                initialValue: widget.account?.name,
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
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _initialAmountCtrl,
                onSaved: (value) => formBalance = value!,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Initial amount',
                  prefixText: '€ ',
                  suffixIcon: Visibility(
                    visible: widget.account != null,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: IconButton(
                        onPressed: () {
                          _recalculate();
                        },
                        tooltip: 'Calculate based on current amount',
                        icon: const Icon(Icons.calculate_rounded),
                      ),
                    ),
                  ),
                ),
                inputFormatters: amountFormatter,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          setState(() {
            autovalidateMode = AutovalidateMode.onUserInteraction;
          });

          if (!formKey.currentState!.validate()) {
            return;
          }

          formKey.currentState!.save();
          var balance = formBalance.toMoney()!; // TODO check if valid

          if (widget.account == null) {
            AccountService.instance.add(
              name: formAccountName,
              balance: balance,
            );
          } else {
            widget.account!.name = formAccountName;
            widget.account!.initialMoney = balance;
            AccountService.instance.update();
          }

          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _recalculate() async {
    _currentAmountCtrl.clear();

    var agreed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recalculate the initial amount'),
        content: SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Enter the current amount below and the initial amount will be recalculated based on saved transactions.'),
              const SizedBox(height: 16),
              TextField(
                controller: _currentAmountCtrl,
                inputFormatters: amountFormatter,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Current amount',
                  prefixText: '€ ',
                ),
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
              listenable: _currentAmountCtrl,
              builder: (context, child) {
                var money = _currentAmountCtrl.text.toMoney();
                return TextButton(
                  onPressed: money != null && money != zeroEur
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

    var currentMoney = _currentAmountCtrl.text.toMoney()!;
    var totalExpenses = TransactionService.instance.expenses
        .where((expense) => expense.transaction.account == widget.account)
        .map((expense) => expense.signedMoney)
        .fold(zeroEur, (acc, x) => acc + x);

    var newInitialMoney = currentMoney - totalExpenses;

    setState(() {
      _initialAmountCtrl.text = newInitialMoney.amount.toString();
      widget.account!.initialMoney = newInitialMoney;
      AccountService.instance.update();
    });
  }
}
