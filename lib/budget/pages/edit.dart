import 'package:finances/budget/models/budget.dart';
import 'package:finances/budget/service.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/amount_text_field.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/components/currency_dropdown.dart';
import 'package:finances/components/period_dropdown.dart';
import 'package:finances/transaction/components/category_list_tile.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:money2/money2.dart';

class BudgetEditPage extends StatefulWidget {
  final Budget? budget;

  const BudgetEditPage({
    super.key,
    this.budget,
  });

  @override
  State<BudgetEditPage> createState() => _BudgetEditPageState();
}

class _BudgetEditPageState extends State<BudgetEditPage> {
  late final _nameCtrl = TextEditingController(text: widget.budget?.name);
  late final _amountCtrl = TextEditingController(text: widget.budget?.limit.amount.toString());
  late var _period = widget.budget?.period ?? Periodicity.month;
  late final _categories = widget.budget?.categories.map((e) => e.copy()).toList() ?? [];
  var _showCategoryListError = false;
  late final editing = widget.budget != null;
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  late var _currency = widget.budget?.currency ?? CommonCurrencies().euro;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit budget' : 'Create new budget'),
        actions: [
          AppBarDelete(
            visible: editing,
            title: 'Delete this budget?',
            description: 'This action cannot be undone.',
            onDelete: () async {
              await BudgetService.instance.delete(widget.budget!);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AmountTextField(
                  controller: _amountCtrl,
                  currency: _currency,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CurrencyDropdown(
                  currency: _currency,
                  onChange: (newCurrency) {
                    setState(() => _currency = newCurrency);
                    return true;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PeriodDropdown(
                  initialSelection: _period,
                  onSelected: (newPeriod) {
                    setState(() {
                      _period = newPeriod;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                  child: Text('No categories added'),
                ),
              if (_showCategoryListError)
                Text(
                  'Add at least one category',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              for (var i in _categories)
                _CategoryListItem(
                  key: ObjectKey(i),
                  budgetCategory: i,
                  onTap: (category) async {
                    var updatedBudgetCategory = await _showDialog(context, category);
                    if (updatedBudgetCategory != null) {
                      setState(() {
                        i = updatedBudgetCategory;
                      });
                    }
                  },
                  onDelete: (category) {
                    setState(() {
                      _categories.remove(category);
                    });
                  },
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  var newBudgetCategory = await _showDialog(context, null);
                  if (newBudgetCategory != null) {
                    setState(() {
                      _categories.add(newBudgetCategory);
                      _showCategoryListError = false;
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add category'),
              ),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate() || _categories.isEmpty) {
            setState(() {
              _autoValidateMode = AutovalidateMode.onUserInteraction;
              _showCategoryListError = _categories.isEmpty;
            });

            return;
          }

          if (editing) {
            await _update();
          } else {
            await _add();
          }

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _add() async {
    await BudgetService.instance.add(Budget(
      name: _nameCtrl.text,
      limit: _amountCtrl.text.toMoneyWithCurrency(_currency)!,
      period: _period,
      categories: _categories,
    ));
  }

  Future<void> _update() async {
    await BudgetService.instance.update(
      widget.budget!,
      name: _nameCtrl.text,
      limit: _amountCtrl.text.toMoneyWithCurrency(_currency)!,
      period: _period,
      budgetCategories: _categories,
    );
  }

  Future<BudgetCategory?> _showDialog(BuildContext context, BudgetCategory? original) async {
    return await showDialog<BudgetCategory>(
      context: context,
      builder: (context) {
        var budgetCategory = original ??
            BudgetCategory(
              category: CategoryService.instance.lastSelection,
              includeChildren: true,
            );
        return AlertDialog(
          title: const Text('Select category'),
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryListTile(
                initialCategory: budgetCategory.category,
                onCategorySelected: (newCategory) async {
                  await CategoryService.instance.setLastSelection(newCategory);
                  budgetCategory.category = newCategory;
                },
              ),
              StatefulBuilder(builder: (context, setter) {
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(
                      value: budgetCategory.includeChildren,
                      onChanged: (value) {
                        if (value != null) {
                          setter(() {
                            budgetCategory.includeChildren = value;
                          });
                        }
                      },
                    ),
                  ),
                  title: const Text('Include children'),
                  onTap: () {
                    setter(() {
                      budgetCategory.includeChildren = !budgetCategory.includeChildren;
                    });
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(budgetCategory);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final BudgetCategory budgetCategory;
  final void Function(BudgetCategory) onTap;
  final void Function(BudgetCategory) onDelete;

  const _CategoryListItem({
    super.key,
    required this.budgetCategory,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CategoryIconSquare(
        icon: budgetCategory.category.icon,
        color: budgetCategory.category.color,
      ),
      title: Text(budgetCategory.category.name),
      subtitle: Text(budgetCategory.includeChildren ? 'With children' : 'Without children'),
      onTap: () {
        onTap(budgetCategory);
      },
      trailing: IconButton(
        onPressed: () {
          onDelete(budgetCategory);
        },
        icon: const Icon(Symbols.delete),
      ),
    );
  }
}
