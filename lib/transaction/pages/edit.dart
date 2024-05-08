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
import 'package:finances/components/image_viewer.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/amount_input_formatter.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/transaction_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const EditTransactionPage({super.key, this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> with SingleTickerProviderStateMixin {
  final transaction = Transaction(
    account: AccountService.instance.lastSelection,
    dateTime: DateTime.now(),
    type: TransactionType.expense,
  );

  var _mainExpenseKey = UniqueKey();
  late Expense mainExpense = Expense(
    transaction: transaction,
    money: '0'.toMoney()!,
    category: category,
    description: null,
  );

  var category = CategoryService.instance.lastSelection;
  var dialogCategory = CategoryService.instance.lastSelection;

  late TextEditingController dialogAmountCtrl;
  late TextEditingController dialogDescriptionCtrl;
  late bool isEditing;
  late TabController _tabCtrl;
  late TransactionTheme _theme;

  @override
  void initState() {
    super.initState();
    isEditing = widget.transaction != null;

    if (isEditing) {
      transaction.account = widget.transaction!.account;
      transaction.dateTime = widget.transaction!.dateTime;
      transaction.expenses = widget.transaction!.expenses.map((e) => e.copy()).toList();
      transaction.attachments = widget.transaction!.attachments.toList();
      transaction.type = widget.transaction!.type;
      transaction.bankInfo = widget.transaction!.bankInfo;
    }

    dialogAmountCtrl = TextEditingController();
    dialogDescriptionCtrl = TextEditingController();

    _tabCtrl = TabController(
      initialIndex: transaction.type.index,
      length: 2,
      vsync: this,
    );
    _tabCtrl.addListener(() {
      setState(() {
        transaction.type = TransactionType.values[_tabCtrl.index];
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = TransactionTheme(context);
  }

  @override
  void dispose() {
    dialogAmountCtrl.dispose();
    dialogDescriptionCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeParts = transaction.dateTime.toIso8601String().split('T');
    final date = dateTimeParts[0];
    final time = dateTimeParts[1].substring(0, 5);

    return AnimatedTheme(
      data: _theme.current(_tabCtrl.index),
      child: Scaffold(
        appBar: AppBar(
          title: !isEditing ? const Text('New transaction') : const Text('Edit a transaction'),
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
              // Tab(
              //   icon: Icon(Symbols.swap_horiz),
              //   text: 'Transfer',
              // ),
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
              visible: isEditing,
              title: 'Delete this transaction?',
              description: 'Deleting a transaction also removes all expenses associated with it.',
              onDelete: () {
                TransactionService.instance.delete(widget.transaction!);
                Navigator.of(context).pop();
              },
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
                          initialDate: transaction.dateTime,
                          firstDate: DateTime(0),
                          lastDate: DateTime(9999),
                          builder: (context, child) => Theme(
                            data: _theme.current(_tabCtrl.index),
                            child: child!,
                          ),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: SquareButton(
                      onPressed: () async {
                        var selected = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(transaction.dateTime),
                          builder: (context, child) => Theme(
                            data: _theme.current(_tabCtrl.index),
                            child: child!,
                          ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: AttachmentRow(
                  attachments: transaction.attachments,
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
                    if (isEditing) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Only supported for new transactions'),
                        ),
                      );
                      return false;
                    }

                    var money = mainExpense.money;
                    if (money == zeroEur) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter the total amount'),
                        ),
                      );
                      return false;
                    }

                    return true;
                  },
                  onAutoCategorize: (attachment) async {
                    var auto = await _autoExpenses(attachment).toList();
                    if (auto.isEmpty && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No rules matched'),
                        ),
                      );
                      return;
                    }
                    var combinedMoney = auto.map((e) => e.money).reduce((total, expense) => total + expense);

                    setState(() {
                      transaction.expenses.addAll(auto);
                      mainExpense.money -= combinedMoney;
                      _rerenderMainExpense();
                    });
                  },
                ),
              ),
              Visibility(
                visible: !isEditing,
                child: _ExpenseCard(
                  key: _mainExpenseKey,
                  expense: mainExpense,
                ),
              ),
              Visibility(
                visible: !isEditing && transaction.expenses.isNotEmpty,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  child: Divider(),
                ),
              ),
              for (final expense in transaction.expenses)
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
              const SizedBox(height: 120),
            ],
          ),
        ),
        // TODO gray out FABs when they are disabled
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: !isEditing,
              child: FloatingActionButton.small(
                heroTag: 'split',
                onPressed: () {
                  split(context);
                },
                tooltip: 'Split into a new category',
                child: const Icon(Icons.call_split),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'add',
              onPressed: () async {
                if (isEditing) {
                  await update();
                } else {
                  await save();
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
      ),
    );
  }

  Future<void> update() async {
    await TransactionService.instance.update(
      target: widget.transaction!,
      newValues: transaction,
    );
  }

  Future<void> save() async {
    await TransactionService.instance.add(
      transaction,
      expenses: [mainExpense, ...transaction.expenses],
    );
  }

  Stream<Expense> _autoExpenses(Attachment attachment) async* {
    var lineItems = attachment.extractLineItems();

    await for (var lineItem in lineItems) {
      var category = AutomationService.instance.getCategory(remittanceInfo: lineItem.text);

      if (category != null) {
        yield Expense(
          transaction: transaction,
          money: lineItem.money,
          category: category,
          description: lineItem.text,
        );
      }
    }
  }

  Future<void> _deleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    if (!isEditing) {
      var moneySplitOff = expense.money;
      setState(() {
        transaction.expenses.remove(expense);
        mainExpense.money += moneySplitOff;
      });
      return;
    }

    if (transaction.expenses.length > 1) {
      setState(() {
        transaction.expenses.remove(expense);
      });
      return;
    }

    var acceptedDeletion = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Theme(
          data: _theme.current(_tabCtrl.index),
          child: AlertDialog(
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
          ),
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
          child: Theme(
            data: _theme.current(_tabCtrl.index),
            child: AlertDialog(
              title: const Text('Split the amount into'),
              contentPadding: const EdgeInsets.symmetric(vertical: 24),
              content: _ExpenseColumn(
                initialCategory: dialogCategory,
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
                    final money = mainExpense.money;
                    final moneyToSplit = dialogAmountCtrl.text.toMoney();

                    final isValid = moneyToSplit != null && moneyToSplit < money;

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
          ),
        );
      },
    );

    if (newExpense == null) {
      return false;
    }

    setState(() {
      mainExpense.money -= newExpense.money;
      transaction.expenses.add(newExpense);
      _rerenderMainExpense();
    });

    return true;
  }

  /// Needed to update the amount text field inside the card.
  /// Call inside a `setState()`.
  void _rerenderMainExpense() {
    _mainExpenseKey = UniqueKey();
  }
}

class _ExpenseCard extends StatefulWidget {
  final Expense expense;
  final VoidCallback? onDelete;

  const _ExpenseCard({
    super.key,
    required this.expense,
    this.onDelete,
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
    var amount = widget.expense.money.amount;
    _amountCtrl = TextEditingController(text: amount.isZero ? null : amount.toString());
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ExpenseColumn(
                initialCategory: widget.expense.category,
                onCategorySelected: (category) {
                  setState(() {
                    widget.expense.category = category;
                  });
                },
                amountCtrl: _amountCtrl,
                descriptionCtrl: _descriptionCtrl,
              ),
            ),
            Column(
              children: [
                Visibility(
                  visible: widget.onDelete != null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Symbols.close),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.expense.transaction.bankInfo != null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        _showBankInfo(context);
                      },
                      tooltip: 'Bank info',
                      icon: const Icon(Symbols.info),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBankInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank info'),
        content: SingleChildScrollView(
          child: SelectionArea(
            child: DataTable(
              dataRowMinHeight: 50,
              dataRowMaxHeight: double.infinity,
              clipBehavior: Clip.hardEdge,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600),
              horizontalMargin: 0,
              columns: const [
                DataColumn(label: Text('Field')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                if (widget.expense.transaction.bankInfo?.transactionId != null)
                  _fieldRow('Transaction ID', widget.expense.transaction.bankInfo!.transactionId),
                if (widget.expense.transaction.bankInfo?.creditorName != null)
                  _fieldRow('Receiver name', widget.expense.transaction.bankInfo!.creditorName!),
                if (widget.expense.transaction.bankInfo?.creditorIban != null)
                  _fieldRow('Receiver IBAN', widget.expense.transaction.bankInfo!.creditorIban!),
                if (widget.expense.transaction.bankInfo?.remittanceInfo != null)
                  _fieldRow('Remittance info', widget.expense.transaction.bankInfo!.remittanceInfo!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  DataRow _fieldRow(String name, String value) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(value)),
      ],
    );
  }
}

class _ExpenseColumn extends StatelessWidget {
  final CategoryModel initialCategory;
  final void Function(CategoryModel) onCategorySelected;
  final TextEditingController amountCtrl;
  final TextEditingController descriptionCtrl;
  final bool morePadding;

  const _ExpenseColumn({
    required this.initialCategory,
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
        CategoryListTile(
          initialCategory: initialCategory,
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

class CategoryListTile extends StatefulWidget {
  final CategoryModel initialCategory;
  final void Function(CategoryModel) onCategorySelected;
  final bool morePadding;

  const CategoryListTile({
    super.key,
    required this.initialCategory,
    required this.onCategorySelected,
    required this.morePadding,
  });

  @override
  State<CategoryListTile> createState() => _CategoryListTileState();
}

class _CategoryListTileState extends State<CategoryListTile> {
  late CategoryModel category = widget.initialCategory;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        var selectedCategory = await Navigator.push<CategoryModel>(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryListPage(CategoryService.instance.rootCategory),
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
      contentPadding: widget.morePadding ? const EdgeInsets.symmetric(horizontal: 24) : null,
      leading: CategoryIcon(
        icon: category.icon,
        color: category.color,
      ),
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
      contentPadding: morePadding ? const EdgeInsets.symmetric(horizontal: 24) : null,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon),
      ),
      title: TextField(
        controller: controller,
        keyboardType: money ? const TextInputType.numberWithOptions(decimal: true) : null,
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
