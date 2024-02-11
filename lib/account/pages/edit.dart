import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/extensions/money.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class AccountEditPage extends StatefulWidget {
  final Account? account;

  const AccountEditPage({super.key, this.account});

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  late String formAccountName;
  late String formBalance;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account?.name ?? 'Create a new account'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 20,
        ),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  onSaved: (value) => formAccountName = value!,
                  initialValue: widget.account?.name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    helperText: '', // Prevents layout jumping on error
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
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  onSaved: (value) => formBalance = value!,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  initialValue: widget.account?.balance.amount.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    helperText: '',
                    prefixText: '€ ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (!amountValidator.hasMatch(value)) {
                      return 'Must be a number';
                    }
                    return null;
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            return;
          }

          formKey.currentState!.save();
          var balance = formBalance.toMoney('EUR');

          if (widget.account == null) {
            AccountService.instance.add(
              name: formAccountName,
              balance: balance,
            );
          } else {
            widget.account!.name = formAccountName;
            widget.account!.balance = balance;
            AccountService.instance.update();
          }

          Navigator.pop(context);
        },
      ),
    );
  }
}
