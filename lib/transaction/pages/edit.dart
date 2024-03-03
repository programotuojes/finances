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
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const EditTransactionPage({super.key, this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final transaction = Transaction(
    account: AccountService.instance.lastSelection,
    dateTime: DateTime.now(),
  );

  var category = CategoryService.instance.lastSelection;
  var dialogCategory = CategoryService.instance.lastSelection;
  var expenses = List<Expense>.empty(growable: true);

  late TextEditingController amountCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController dialogAmountCtrl;
  late TextEditingController dialogDescriptionCtrl;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.transaction != null;

    if (isEditing) {
      transaction.account = widget.transaction!.account;
      transaction.dateTime = widget.transaction!.dateTime;
      expenses = widget.transaction!.expenses;
    }

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
    final dateTimeParts = transaction.dateTime.toIso8601String().split('T');
    final date = dateTimeParts[0];
    final time = dateTimeParts[1].substring(0, 5);

    return Scaffold(
      appBar: AppBar(
        title: !isEditing
            ? const Text('New transaction')
            : const Text('Edit a transaction'),
        actions: isEditing
            ? [
                IconButton(
                  onPressed: () async {
                    final accepted = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete this transaction?'),
                          content: const Text(
                              'Deleting a transaction also removes all expenses associated with it.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text(
                                'Cancel',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text(
                                'Delete',
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (accepted == true && context.mounted) {
                      TransactionService.instance.delete(widget.transaction!);
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ]
            : null,
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
                            initialDate: transaction.dateTime,
                            firstDate: DateTime(0),
                            lastDate: DateTime(9999),
                          );
                          if (selected == null) return;
                          setState(() {
                            transaction.dateTime =
                                transaction.dateTime.copyWith(
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
                            initialTime:
                                TimeOfDay.fromDateTime(transaction.dateTime),
                          );
                          if (selected == null) return;
                          setState(() {
                            transaction.dateTime =
                                transaction.dateTime.copyWith(
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
                        initialSelection: transaction.account,
                        label: const Text('Account'),
                        onSelected: (selected) {
                          if (selected == null) return;
                          setState(() {
                            transaction.account = selected;
                          });
                        },
                        dropdownMenuEntries: [
                          for (final x in AccountService.instance.accounts)
                            DropdownMenuEntry(value: x, label: x.name)
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isEditing,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: SquareButton(
                            onPressed: () async {
                              var selection =
                                  await Navigator.push<CategoryModel>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryListPage(
                                      CategoryService.instance.root),
                                ),
                              );
                              if (selection == null) return;
                              CategoryService.instance.lastSelection =
                                  selection;
                              setState(() {
                                category = selection;
                              });
                            },
                            child: Text(category.name),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: !isEditing,
                  child: TextField(
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
                ),
                Visibility(
                  visible: !isEditing,
                  child: TextField(
                    controller: descriptionCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final expense in expenses)
            _ExpenseCard(
              expense: expense,
              onDelete: () async {
                if (!isEditing) {
                  final money = amountCtrl.text.toMoney('EUR') ?? zeroEur;
                  final moneySplitOff = expense.money;
                  setState(() {
                    expenses.remove(expense);
                    amountCtrl.text = (money + moneySplitOff).amount.toString();
                  });
                  return;
                }

                if (expenses.length > 1) {
                  setState(() {
                    expenses.remove(expense);
                  });
                  return;
                }

                final accepted = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete this transaction?'),
                      content: const Text(
                          'Deleting the last expense will also delete this transaction.'),
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
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (accepted != true || !context.mounted) return;

                TransactionService.instance.delete(widget.transaction!);
                Navigator.of(context).pop();
              },
            ),
          Visibility(
            visible: !isEditing && transaction.expenses.isEmpty,
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
      // TODO gray out FABs when they are disabled
      floatingActionButton: ListenableBuilder(
        listenable: amountCtrl,
        builder: (context, _) {
          final money = amountCtrl.text.toMoney('EUR');
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: !isEditing,
                child: FloatingActionButton.small(
                  onPressed: money != null
                      ? () {
                          split(context);
                        }
                      : null,
                  tooltip: 'Split into a new category',
                  child: const Icon(Icons.call_split),
                ),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: money != null || isEditing
                    ? () {
                        if (isEditing) {
                          TransactionService.instance.update(
                            target: widget.transaction!,
                            account: transaction.account,
                            dateTime: transaction.dateTime,
                            expenses: expenses,
                          );
                          Navigator.of(context).pop();
                          return;
                        }

                        final mainExpense = Expense(
                          transaction: transaction,
                          money: money!, // Will return early if money is null
                          category: category,
                          description: descriptionCtrl.text,
                        );
                        expenses.add(mainExpense);
                        transaction.expenses = expenses;
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
    final result = await showDialog<Expense>(
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
                          Navigator.of(context).pop(Expense(
                            transaction: transaction,
                            category: dialogCategory,
                            money: moneyToSplit,
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
    final moneySplitOff = result.money;

    if (money == null) {
      return false;
    }

    setState(() {
      amountCtrl.text = (money - moneySplitOff).amount.toString();
      expenses.add(result);
    });

    return true;
  }
}

class _ExpenseCard extends StatefulWidget {
  final Expense expense;
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

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(text: widget.expense.money.toString());
    descriptionCtrl = TextEditingController(text: widget.expense.description);

    amountCtrl.addListener(() {
      widget.expense.money = amountCtrl.text.toMoney('EUR') ?? zeroEur;
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
                widget.expense.category = selection;
              });
            },
            child: Text(widget.expense.category.name),
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
