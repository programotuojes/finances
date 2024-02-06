import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/expense/models/expense.dart';
import 'package:finances/expense/service.dart';
import 'package:finances/extensions/money.dart';
import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final formKey = GlobalKey<FormState>();
  Account account = AccountService.instance.lastSelection;
  CategoryModel category = CategoryService.instance.lastSelection;
  String formAmount = '';
  String? formDescription;
  DateTime dateTime = DateTime.now();

  void submit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    ExpenseService.instance.add(Expense(
      account: account,
      category: category,
      amount: formAmount.toMoney('EUR'),
      dateTime: dateTime,
      description: formDescription,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownMenu<Account>(
                        expandedInsets: const EdgeInsets.all(0),
                        initialSelection: account,
                        label: const Text('Account'),
                        onSelected: (selected) {
                          if (selected == null) return;
                          setState(() {
                            account = selected;
                          });
                        },
                        dropdownMenuEntries:
                            AccountService.instance.accounts.map(
                          (account) {
                            return DropdownMenuEntry<Account>(
                              value: account,
                              label: account.name,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SquareButton(
                      onPressed: () async {
                        var selection = await Navigator.push<CategoryModel>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryListPage(CategoryService.instance.root),
                          ),
                        );
                        if (selection == null) return;
                        CategoryService.instance.lastSelection = selection;
                        setState(() {
                          category = selection;
                        });
                      },
                      child: Text(category.name),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                onSaved: (value) => formAmount = value!,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '€ ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Must be a number';
                  }
                  return null;
                },
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                onSaved: (value) {
                  if (value!.trim().isNotEmpty) {
                    formDescription = value;
                  }
                },
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SquareButton(
                    onPressed: () async {
                      var selected = await showDatePicker(
                        context: context,
                        initialDate: dateTime,
                        firstDate: DateTime(0),
                        lastDate: DateTime(9999),
                      );
                      if (selected == null) return;
                      setState(() {
                        dateTime = dateTime.copyWith(
                          year: selected.year,
                          month: selected.month,
                          day: selected.day,
                        );
                      });
                    },
                    child: Text(dateTime.toIso8601String().split('T')[0]),
                  ),
                ),
                Expanded(
                  child: SquareButton(
                    onPressed: () async {
                      var selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(dateTime),
                      );
                      if (selected == null) return;
                      setState(() {
                        dateTime = dateTime.copyWith(
                          hour: selected.hour,
                          minute: selected.minute,
                        );
                      });
                    },
                    child: Text(dateTime
                        .toIso8601String()
                        .split('T')[1]
                        .substring(0, 5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          submit(context);
        },
      ),
    );
  }
}
