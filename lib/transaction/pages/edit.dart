import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/automation/pages/list.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/attachment_row.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/amount_input_formatter.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:money2/money2.dart';

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
  var attachments = List<Attachment>.empty(growable: true);

  late TextEditingController amountCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController dialogAmountCtrl;
  late TextEditingController dialogDescriptionCtrl;
  late bool isEditing;

  String? _amountError;

  @override
  void initState() {
    super.initState();
    isEditing = widget.transaction != null;

    if (isEditing) {
      transaction.account = widget.transaction!.account;
      transaction.dateTime = widget.transaction!.dateTime;
      expenses = widget.transaction!.expenses.map((e) => e.copy()).toList();
      attachments = widget.transaction!.attachments.toList();
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AutomationListPage(),
                ),
              );
            },
            tooltip: 'Open automations',
            icon: const Icon(Symbols.manufacturing),
          ),
          AppBarDelete(
            visible: isEditing,
            title: 'Delete this transaction?',
            description:
                'Deleting a transaction also removes all expenses associated with it.',
            onDelete: () {
              TransactionService.instance.delete(widget.transaction!);
              Navigator.of(context).pop();
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: scaffoldPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        transaction.dateTime = transaction.dateTime.copyWith(
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
                        transaction.dateTime = transaction.dateTime.copyWith(
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
            AttachmentRow(
              attachments: attachments,
              allowOcr: () {
                if (isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Only supported for new transactions'),
                    ),
                  );
                  return false;
                }

                var money = amountCtrl.text.toMoney();
                if (money == null || money == zeroEur) {
                  setState(() {
                    _amountError = 'Please enter the total amount';
                  });
                  return false;
                }

                return true;
              },
              onOcr: (attachment) async {
                var auto = await _autoExpenses(attachment).toList();
                if (auto.isEmpty && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No rules matched'),
                    ),
                  );
                  return;
                }
                var combinedMoney = auto
                    .map((e) => e.money)
                    .reduce((total, expense) => total + expense);
                var existingMoney =
                    amountCtrl.text.toMoney()!; // Checked in `allowOcr`

                setState(() {
                  expenses.addAll(auto);
                  amountCtrl.text =
                      (existingMoney - combinedMoney).amount.toString();
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownMenu<Account>(
                    expandedInsets: const EdgeInsets.all(0),
                    initialSelection: transaction.account,
                    label: const Text('Account'),
                    onSelected: (selected) {
                      if (selected == null) {
                        return;
                      }
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
                ),
              ],
            ),
            Visibility(
              visible: !isEditing,
              child: TextField(
                controller: amountCtrl,
                onChanged: (value) {
                  if (_amountError != null) {
                    setState(() {
                      _amountError = null;
                    });
                  }
                },
                inputFormatters: amountFormatter,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '€ ',
                  errorText: _amountError,
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
            ),
            const SizedBox(height: 24),
            for (final expense in expenses)
              _ExpenseCard(
                key: ObjectKey(expense),
                expense: expense,
                onDelete: () {
                  _deleteExpense(context, expense);
                },
              ),
            Visibility(
              visible: !isEditing && transaction.expenses.isEmpty,
              child: const Center(
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    Text(
                      'After entering an amount,',
                    ),
                    Text.rich(
                      TextSpan(
                        text: 'click the ',
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.call_split),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          TextSpan(text: ' button to'),
                        ],
                      ),
                    ),
                    Text('split off into a different category'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
      // TODO gray out FABs when they are disabled
      floatingActionButton: ListenableBuilder(
        listenable: amountCtrl,
        builder: (context, _) {
          final mainMoney = amountCtrl.text.toMoney();
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: !isEditing,
                child: FloatingActionButton.small(
                  heroTag: 'split',
                  onPressed: mainMoney != null
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
                heroTag: 'add',
                onPressed: !isEditing && mainMoney == null
                    ? null
                    : () async {
                        if (isEditing) {
                          await update();
                        } else {
                          await save(mainMoney!);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                tooltip: 'Save',
                child: const Icon(Icons.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> update() async {
    await TransactionService.instance.update(
      target: widget.transaction!,
      account: transaction.account,
      dateTime: transaction.dateTime,
      expenses: expenses,
      attachments: attachments,
    );
  }

  Future<void> save(Money money) async {
    final mainExpense = Expense(
      transaction: transaction,
      money: money,
      category: category,
      description: descriptionCtrl.text,
    );
    await TransactionService.instance.add(
      transaction,
      expenses: [mainExpense, ...expenses],
      attachments: attachments,
    );
  }

  Stream<Expense> _autoExpenses(Attachment attachment) async* {
    var lineItems = extractLineItems(attachment.text);

    await for (var lineItem in lineItems) {
      var auto =
          AutomationService.instance.getAutomationForLineItem(lineItem.text);

      if (auto != null) {
        yield Expense(
          transaction: transaction,
          money: lineItem.money,
          category: auto.category,
          description: null,
        );
      }
    }
  }

  Future<void> _deleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    if (!isEditing) {
      var mainMoney = amountCtrl.text.toMoney() ?? zeroEur;
      var moneySplitOff = expense.money;
      setState(() {
        expenses.remove(expense);
        amountCtrl.text = (mainMoney + moneySplitOff).amount.toString();
      });
      return;
    }

    if (expenses.length > 1) {
      setState(() {
        expenses.remove(expense);
      });
      return;
    }

    var acceptedDeletion = await showDialog<bool>(
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

    if (acceptedDeletion != true || !context.mounted) {
      return;
    }

    TransactionService.instance.delete(widget.transaction!);
    Navigator.of(context).pop();
  }

  /// Show a dialog to create a new expense.
  /// Returns true if a split was successful, false if there were validation errors.
  Future<bool> split(BuildContext context) async {
    var newExpense = await showDialog<Expense>(
      context: context,
      builder: (context) {
        return PopScope(
          onPopInvoked: (didPop) {
            dialogAmountCtrl.clear();
            dialogDescriptionCtrl.clear();
          },
          child: AlertDialog(
            title: const Text('Split the amount into'),
            contentPadding: const EdgeInsets.symmetric(vertical: 24),
            content: _ExpenseColumn(
              onCategorySelected: (category) {
                dialogCategory = category;
              },
              amountCtrl: dialogAmountCtrl,
              descriptionCtrl: dialogDescriptionCtrl,
              morePadding: true,
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
                  final money = amountCtrl.text.toMoney();
                  final moneyToSplit = dialogAmountCtrl.text.toMoney();

                  final isValid = money != null &&
                      moneyToSplit != null &&
                      moneyToSplit < money;

                  return TextButton(
                    onPressed: isValid
                        ? () {
                            Navigator.of(context).pop(Expense(
                              transaction: transaction,
                              money: moneyToSplit,
                              category: dialogCategory,
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
        );
      },
    );

    if (newExpense == null) {
      return false;
    }

    var money = amountCtrl.text.toMoney();
    if (money == null) {
      return false;
    }

    setState(() {
      amountCtrl.text = (money - newExpense.money).amount.toString();
      expenses.add(newExpense);
    });

    return true;
  }
}

class _ExpenseCard extends StatefulWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  @override
  State<_ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<_ExpenseCard> {
  late TextEditingController _amountCtrl;
  late TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: widget.expense.money.amount.toString());
    _descriptionCtrl = TextEditingController(text: widget.expense.description);

    _amountCtrl.addListener(() {
      var money = _amountCtrl.text.toMoney();
      if (money != null) {
        widget.expense.money = money;
      }
    });

    _descriptionCtrl.addListener(() {
      widget.expense.description = _descriptionCtrl.text;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ExpenseColumn(
                onCategorySelected: (category) {
                  setState(() {
                    widget.expense.category = category;
                  });
                },
                amountCtrl: _amountCtrl,
                descriptionCtrl: _descriptionCtrl,
              ),
            ),
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Symbols.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseColumn extends StatelessWidget {
  final void Function(CategoryModel) onCategorySelected;
  final TextEditingController amountCtrl;
  final TextEditingController descriptionCtrl;
  final bool morePadding;

  const _ExpenseColumn({
    required this.onCategorySelected,
    required this.amountCtrl,
    required this.descriptionCtrl,
    this.morePadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CategoryListTile(
          onCategorySelected: onCategorySelected,
          morePadding: morePadding,
        ),
        _TextFieldListTile(
          controller: amountCtrl,
          icon: Symbols.euro,
          hintText: 'Amount',
          morePadding: morePadding,
          money: true,
        ),
        _TextFieldListTile(
          controller: descriptionCtrl,
          icon: Symbols.description,
          hintText: 'Description',
          morePadding: morePadding,
        ),
      ],
    );
  }
}

class _CategoryListTile extends StatefulWidget {
  final void Function(CategoryModel) onCategorySelected;
  final bool morePadding;

  const _CategoryListTile({
    required this.onCategorySelected,
    required this.morePadding,
  });

  @override
  State<_CategoryListTile> createState() => __CategoryListTileState();
}

class __CategoryListTileState extends State<_CategoryListTile> {
  var category = CategoryService.instance.lastSelection;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        var selectedCategory = await Navigator.push<CategoryModel>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CategoryListPage(CategoryService.instance.root),
          ),
        );

        if (selectedCategory == null) {
          return;
        }

        CategoryService.instance.lastSelection = selectedCategory;
        widget.onCategorySelected(selectedCategory);
        setState(() {
          category = selectedCategory;
        });
      },
      contentPadding: widget.morePadding
          ? const EdgeInsets.symmetric(horizontal: 24)
          : null,
      leading: CategoryIcon(icon: category.icon),
      title: Text(category.name),
    );
  }
}

class _TextFieldListTile extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool morePadding;
  final bool money;

  const _TextFieldListTile({
    required this.icon,
    required this.hintText,
    required this.controller,
    this.morePadding = false,
    this.money = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding:
          morePadding ? const EdgeInsets.symmetric(horizontal: 24) : null,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon),
      ),
      title: TextField(
        controller: controller,
        keyboardType:
            money ? const TextInputType.numberWithOptions(decimal: true) : null,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: money ? amountFormatter : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}
