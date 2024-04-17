import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/extensions/money.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account?.name ?? 'Create a new account'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              TextFormField(
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
          var balance = formBalance.toMoney('EUR')!; // TODO check if valid

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
