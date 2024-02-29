import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const EditTransactionPage({super.key, this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  var account = AccountService.instance.lastSelection;
  var category = CategoryService.instance.lastSelection;
  var dialogCategory = CategoryService.instance.lastSelection;
  var dateTime = DateTime.now();
  final splits = List<_TempExpense>.empty(growable: true);

  late TextEditingController amountCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController dialogAmountCtrl;
  late TextEditingController dialogDescriptionCtrl;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController();
    descriptionCtrl = TextEditingController();
    dialogAmountCtrl = TextEditingController();
    dialogDescriptionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    dialogAmountCtrl.dispose();
    dialogDescriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeParts = dateTime.toIso8601String().split('T');
    final date = dateTimeParts[0];
    final time = dateTimeParts[1].substring(0, 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          Material(
            elevation: 5,
            child: Column(
              children: [
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
                        child: Text(date),
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
                        child: Text(time),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 100,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: Text('+'),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
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
                        dropdownMenuEntries: [
                          for (final x in AccountService.instance.accounts)
                            DropdownMenuEntry(value: x, label: x.name)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: SquareButton(
                          onPressed: () async {
                            var selection = await Navigator.push<CategoryModel>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryListPage(
                                    CategoryService.instance.root),
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
                    ),
                  ],
                ),
                TextField(
                  controller: amountCtrl,
                  inputFormatters: amountFormatter,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '€ ',
                  ),
                ),
                TextField(
                  controller: descriptionCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final x in splits)
            _ExpenseCard(
              expense: x,
              onDelete: () {
                final money = amountCtrl.text.toMoney('EUR') ??
                    CommonCurrencies().euro.parse('0');
                final splitMoney = x.amount.toMoney('EUR');

                setState(() {
                  splits.remove(x);

                  if (splitMoney != null) {
                    amountCtrl.text = (money + splitMoney).amount.toString();
                  }
                });
              },
            ),
          Visibility(
            visible: splits.isEmpty,
            child: const Center(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Text('Click the "split" button to'),
                  Text('subcategorize this transaction'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
      // TODO when onPressed is null, FABs aren't grayed out
      floatingActionButton: ListenableBuilder(
        listenable: amountCtrl,
        builder: (context, _) {
          final amountIsValid = amountCtrl.text.toMoney('EUR') != null;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                onPressed: amountIsValid
                    ? () {
                        split(context);
                      }
                    : null,
                tooltip: 'Split into a new category',
                child: const Icon(Icons.call_split),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: amountIsValid
                    ? () {
                        final transaction = Transaction(
                          account: account,
                          dateTime: dateTime,
                        );
                        final mainExpense = Expense(
                          transaction: transaction,
                          money: amountCtrl.text.toMoney('EUR')!,
                          category: category,
                          description: descriptionCtrl.text,
                        );
                        final otherExpenses = splits.map((e) => Expense(
                              transaction: transaction,
                              money: e.amount.toMoney('EUR')!,
                              category: e.category,
                              description: e.description,
                            ));
                        transaction.expenses = [mainExpense, ...otherExpenses];
                        TransactionService.instance.add(transaction);
                        Navigator.of(context).pop();
                      }
                    : null,
                tooltip: 'Save',
                child: const Icon(Icons.save),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Show a dialog to create a new subcategory.
  /// Returns true if a split was successful, false if there were validation errors.
  Future<bool> split(BuildContext context) async {
    final result = await showDialog<_TempExpense>(
      context: context,
      builder: (context) => PopScope(
        onPopInvoked: (didPop) {
          dialogAmountCtrl.clear();
          dialogDescriptionCtrl.clear();
        },
        child: AlertDialog(
          title: const Text('Split the amount into'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: dialogAmountCtrl,
                inputFormatters: amountFormatter,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '€ ',
                ),
              ),
              TextField(
                controller: dialogDescriptionCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return SquareButton(
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
                        dialogCategory = selection;
                      });
                    },
                    child: Text(dialogCategory.name),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ListenableBuilder(
              listenable: dialogAmountCtrl,
              builder: (context, setState) {
                final money = amountCtrl.text.toMoney('EUR');
                final moneyToSplit = dialogAmountCtrl.text.toMoney('EUR');

                final isValid = money != null &&
                    moneyToSplit != null &&
                    moneyToSplit < money;

                return TextButton(
                  onPressed: isValid
                      ? () {
                          Navigator.of(context).pop(_TempExpense(
                            category: dialogCategory,
                            amount: dialogAmountCtrl.text,
                            description: dialogDescriptionCtrl.text,
                          ));
                        }
                      : null,
                  child: const Text('Save'),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (result == null) {
      return false;
    }

    final money = amountCtrl.text.toMoney('EUR');
    final moneySplitOff = result.amount.toMoney('EUR');

    if (money == null || moneySplitOff == null) {
      return false;
    }

    setState(() {
      amountCtrl.text = (money - moneySplitOff).amount.toString();
      splits.add(result);
    });

    return true;
  }
}

class _ExpenseCard extends StatefulWidget {
  final _TempExpense expense;
  final VoidCallback? onDelete;

  const _ExpenseCard({
    required this.expense,
    this.onDelete,
  });

  @override
  State<_ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<_ExpenseCard> {
  late TextEditingController amountCtrl;
  late TextEditingController descriptionCtrl;
  late CategoryModel category;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(text: widget.expense.amount);
    descriptionCtrl = TextEditingController(text: widget.expense.description);
    category = widget.expense.category;

    amountCtrl.addListener(() {
      widget.expense.amount = amountCtrl.text;
    });

    descriptionCtrl.addListener(() {
      widget.expense.description = descriptionCtrl.text;
    });
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: amountCtrl,
            inputFormatters: amountFormatter,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '€ ',
            ),
          ),
          TextField(
            controller: descriptionCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
          ),
          SquareButton(
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
        ],
      ),
      trailing: IconButton(
        onPressed: widget.onDelete,
        icon: const Icon(Icons.delete),
      ),
    );
  }
}

class _TempExpense {
  CategoryModel category;
  String amount;
  String? description;

  _TempExpense({
    required this.category,
    required this.amount,
    this.description,
  });
}
