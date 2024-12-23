import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/automation/pages/list.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/attachment_row.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/image_viewer.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/main.dart';
import 'package:finances/transaction/components/expense_card.dart';
import 'package:finances/transaction/components/expense_column.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/temp_combined.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart' as sql;

class TransactionEditPage extends StatefulWidget {
  final Transaction? transaction;

  const TransactionEditPage({
    super.key,
    this.transaction,
  });

  @override
  State<TransactionEditPage> createState() => TransactionEditPageState();
}

class TransactionEditPageState extends State<TransactionEditPage> with SingleTickerProviderStateMixin {
  late final _isEditing = widget.transaction != null;
  late final _transaction = Transaction(
    account: widget.transaction?.account ?? AccountService.instance.lastSelection,
    dateTime: widget.transaction?.dateTime ?? DateTime.now(),
    type: widget.transaction?.type ?? TransactionType.expense,
    attachments: widget.transaction?.attachments.toList() ?? [],
    expenses: widget.transaction?.expenses.toList() ?? [],
  );
  late final _mainExpense = Expense(
    transaction: _transaction,
    money: Money.fromFixedWithCurrency(Fixed.zero, _transaction.account.currency),
    category: CategoryService.instance.lastSelection,
    description: null,
  );
  var _mainExpenseKey = UniqueKey();
  late final _tabCtrl = TabController(
    vsync: this,
    length: 2,
    initialIndex: widget.transaction?.type.index ?? TransactionType.expense.index,
  );
  final _dialogAmountCtrl = TextEditingController();
  final _dialogDescriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() {
      _transaction.type = TransactionType.values[_tabCtrl.index];
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _dialogAmountCtrl.dispose();
    _dialogDescriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeParts = _transaction.dateTime.toIso8601String().split('T');
    final date = dateTimeParts[0];
    final time = dateTimeParts[1].substring(0, 5);

    return Scaffold(
      appBar: AppBar(
        title: _isEditing ? const Text('Edit transaction') : const Text('New transaction'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(
              icon: Icon(Symbols.download),
              text: 'Income',
            ),
            Tab(
              icon: Icon(Symbols.upload),
              text: 'Expense',
            ),
          ],
        ),
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
            visible: _isEditing,
            title: 'Delete this transaction?',
            description: 'Deleting a transaction also removes all expenses associated with it.',
            onDelete: () async {
              await TransactionService.instance.delete(widget.transaction!);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: !_isEditing,
            child: FloatingActionButton.small(
              heroTag: 'split',
              onPressed: () async {
                // TODO show snackbar on error
                await _split(context);
              },
              tooltip: 'Split into a new category',
              child: const Icon(Icons.call_split),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              try {
                if (_isEditing) {
                  await TransactionService.instance.update(
                    widget.transaction!,
                    account: _transaction.account,
                    dateTime: _transaction.dateTime,
                    type: _transaction.type,
                    attachments: _transaction.attachments,
                    expenses: _transaction.expenses,
                  );
                } else {
                  await TransactionService.instance.add(
                    _transaction,
                    expenses: [_mainExpense, ..._transaction.expenses],
                  );
                }
              } on sql.DatabaseException catch (e) {
                // TODO add a catch for other entities
                logger.w('Call to the database failed', error: e);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Database error'),
                    action: SnackBarAction(
                      label: 'Reload database',
                      onPressed: () async {
                        await AppPaths.init();
                      },
                    ),
                  ));
                }

                return;
              }

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Save',
            child: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: scaffoldPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownMenu<Account>(
              expandedInsets: const EdgeInsets.all(0),
              initialSelection: _transaction.account,
              label: const Text('Account'),
              onSelected: (selected) async {
                if (selected == null) {
                  return;
                }
                setState(() {
                  _transaction.account = selected;
                });
                await AccountService.instance.setLastSelection(selected);
              },
              dropdownMenuEntries: [
                for (final x in AccountService.instance.accounts) DropdownMenuEntry(value: x, label: x.name)
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SquareButton(
                    onPressed: () async {
                      var selected = await showDatePicker(
                        context: context,
                        initialDate: _transaction.dateTime,
                        firstDate: DateTime(0),
                        lastDate: DateTime(9999),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                            child: child!,
                          );
                        },
                      );
                      if (selected == null) return;
                      setState(() {
                        _transaction.dateTime = _transaction.dateTime.copyWith(
                          year: selected.year,
                          month: selected.month,
                          day: selected.day,
                        );
                      });
                    },
                    child: Text(date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SquareButton(
                    onPressed: () async {
                      var selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_transaction.dateTime),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                            child: child!,
                          );
                        },
                      );
                      if (selected == null) return;
                      setState(() {
                        _transaction.dateTime = _transaction.dateTime.copyWith(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: AttachmentRow(
                attachments: _transaction.attachments,
                onTap: (attachment) async {
                  var bytes = await attachment.bytes;

                  if (!context.mounted) {
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(
                        imageProvider: MemoryImage(bytes),
                        tag: attachment,
                      ),
                    ),
                  );
                },
                allowOcr: () {
                  if (_isEditing) {
                    // TODO remove this limitation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Only supported for new transactions'),
                      ),
                    );
                    return false;
                  }

                  return true;
                },
                onAutoCategorize: (attachment) async {
                  var lineItems = await attachment.extractLineItems().toList();
                  var sum = lineItems.fold(Fixed.zero, (acc, x) => acc + x.money.amount);

                  var expected = '${sum.integerPart},${sum.decimalPart}';
                  logger.i('Expecting to find $expected in receipt');

                  if (attachment.text?.contains(expected) != true) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter the total amount'),
                        ),
                      );
                    }
                    return;
                  }

                  setState(() {
                    _mainExpense.money = Money.fromFixedWithCurrency(sum, _mainExpense.money.currency);
                  });

                  final auto = <Expense>[];
                  for (final lineItem in lineItems) {
                    final category = AutomationService.instance.getCategory(remittanceInfo: lineItem.text);

                    if (category != null) {
                      auto.add(Expense(
                        transaction: _transaction,
                        money: lineItem.money,
                        category: category,
                        description: lineItem.text,
                      ));
                    }
                  }

                  if (auto.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No rules matched'),
                        ),
                      );
                    }
                    return;
                  }

                  final combinedMoney = auto.map((e) => e.money).reduce((total, expense) => total + expense);

                  setState(() {
                    _transaction.expenses.addAll(auto);
                    _mainExpense.money -= combinedMoney;
                    _rerenderMainExpense();
                  });
                },
              ),
            ),
            Visibility(
              visible: !_isEditing,
              child: ExpenseCard(
                key: _mainExpenseKey,
                entity: TempCombined(expense: _mainExpense),
              ),
            ),
            Visibility(
              visible: !_isEditing && _transaction.expenses.isNotEmpty,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Divider(),
              ),
            ),
            for (final expense in _transaction.expenses)
              ExpenseCard(
                key: ObjectKey(expense),
                entity: TempCombined(expense: expense),
                onDelete: () async {
                  await _deleteExpense(context, expense);
                },
              ),
            Visibility(
              visible: !_isEditing && _transaction.expenses.isEmpty,
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
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  /// Show a dialog to create a new expense.
  /// Returns true if a split was successful, false if there were validation errors.
  Future<bool> _split(BuildContext context) async {
    var dialogCategory = CategoryService.instance.lastSelection;

    final newExpense = await showDialog<Expense>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Split the amount into'),
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 440),
            child: ExpenseColumn(
              initialCategory: dialogCategory,
              onCategorySelected: (category) {
                dialogCategory = category;
              },
              amountCtrl: _dialogAmountCtrl,
              descriptionCtrl: _dialogDescriptionCtrl,
              listTilePadding: const EdgeInsets.symmetric(horizontal: 24),
              currency: _transaction.account.currency,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ListenableBuilder(
              listenable: _dialogAmountCtrl,
              builder: (context, setState) {
                final moneyToSplit = _dialogAmountCtrl.text.toMoneyWithCurrency(_mainExpense.money.currency);
                final isValid = moneyToSplit != null && moneyToSplit < _mainExpense.money;

                return TextButton(
                  onPressed: isValid
                      ? () {
                          Navigator.of(context).pop(Expense(
                            transaction: _transaction,
                            money: moneyToSplit,
                            category: dialogCategory,
                            description: _dialogDescriptionCtrl.text,
                          ));
                        }
                      : null,
                  child: const Text('Save'),
                );
              },
            ),
          ],
        );
      },
    );

    _dialogAmountCtrl.clear();
    _dialogDescriptionCtrl.clear();

    if (newExpense == null) {
      return false;
    }

    setState(() {
      _mainExpense.money -= newExpense.money;
      _transaction.expenses.add(newExpense);
      _rerenderMainExpense();
    });

    return true;
  }

  /// Needed to update the amount text field inside the card.
  /// Call inside a `setState()`.
  void _rerenderMainExpense() {
    _mainExpenseKey = UniqueKey();
  }

  Future<void> _deleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    if (!_isEditing) {
      final moneySplitOff = expense.money;
      setState(() {
        _transaction.expenses.remove(expense);
        _mainExpense.money += moneySplitOff;
        _rerenderMainExpense();
      });
      return;
    }

    if (_transaction.expenses.length > 1) {
      setState(() {
        _transaction.expenses.remove(expense);
      });
      return;
    }

    var acceptedDeletion = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this transaction?'),
          content: const Text('Deleting the last expense will also delete this transaction.'),
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

    await TransactionService.instance.delete(widget.transaction!);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
