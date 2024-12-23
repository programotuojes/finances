import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/amount_text_field.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/period_dropdown.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/recurring/service.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:finances/utils/transaction_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RecurringEditPage extends StatefulWidget {
  final RecurringModel? model;

  const RecurringEditPage({super.key, this.model});

  @override
  State<RecurringEditPage> createState() => _RecurringEditPageState();
}

class _RecurringEditPageState extends State<RecurringEditPage> with SingleTickerProviderStateMixin {
  late var _account = widget.model?.account ?? AccountService.instance.lastSelection;
  late var _category = widget.model?.category ?? CategoryService.instance.lastSelection;
  late var _period = widget.model?.periodicity ?? Periodicity.month;
  late var _from = widget.model?.from ?? DateTime.now();
  late var _until = widget.model?.until;
  late var _type = widget.model?.type ?? TransactionType.expense;

  late TextEditingController amountCtrl;
  late TextEditingController intervalCtrl;
  late TextEditingController descriptionCtrl;
  late var isEditing = widget.model != null;
  late TabController _tabCtrl;
  late TransactionTheme _theme;
  final _formKey = GlobalKey<FormState>();
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(text: widget.model?.money.amount.toString());
    intervalCtrl = TextEditingController(text: widget.model?.interval.toString());
    descriptionCtrl = TextEditingController(text: widget.model?.description);

    _tabCtrl = TabController(
      initialIndex: _type.index,
      length: 2,
      vsync: this,
    );
    _tabCtrl.addListener(() {
      setState(() {
        _type = TransactionType.values[_tabCtrl.index];
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
    amountCtrl.dispose();
    intervalCtrl.dispose();
    descriptionCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFromString = _from.toIso8601String().substring(0, 10);
    final dateUntilString = (_until ?? DateTime.now()).toIso8601String().substring(0, 10);

    return AnimatedTheme(
      data: _theme.current(_tabCtrl.index),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recurring transaction'),
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
            AppBarDelete(
              visible: isEditing,
              title: 'Delete this recurring transaction?',
              description: 'All of the confirmed transactions will be kept.',
              onDelete: () {
                RecurringService.instance.delete(widget.model!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: scaffoldPadding,
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownMenu<Account>(
                  expandedInsets: const EdgeInsets.all(0),
                  initialSelection: _account,
                  label: const Text('Account'),
                  onSelected: (selected) {
                    if (selected != null) {
                      setState(() {
                        _account = selected;
                      });
                    }
                  },
                  dropdownMenuEntries: [
                    for (final x in AccountService.instance.accounts) DropdownMenuEntry(value: x, label: x.name)
                  ],
                ),
                const SizedBox(height: 16),
                SquareButton(
                  onPressed: () async {
                    var selected = await showDatePicker(
                      context: context,
                      initialDate: _from,
                      firstDate: DateTime(0),
                      lastDate: DateTime(9999),
                      builder: (context, child) {
                        return Theme(
                          data: _theme.current(_tabCtrl.index),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (selected == null) {
                      return;
                    }
                    setState(() {
                      _from = selected;
                    });
                  },
                  child: Text(dateFromString),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Has end date'),
                  value: _until != null,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _until = DateTime.now();
                      } else {
                        _until = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                SquareButton(
                  onPressed: _until != null
                      ? () async {
                          var selected = await showDatePicker(
                            context: context,
                            initialDate: _until,
                            firstDate: _from,
                            lastDate: DateTime(9999),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                                child: child!,
                              );
                            },
                          );
                          if (selected == null) {
                            return;
                          }
                          setState(() {
                            _until = selected;
                          });
                        }
                      : null,
                  child: Text(dateUntilString),
                ),
                const SizedBox(height: 16),
                SquareButton(
                  onPressed: () async {
                    var selection = await Navigator.push<CategoryModel>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryListPage(CategoryService.instance.rootCategory),
                      ),
                    );
                    if (selection == null) {
                      return;
                    }

                    await CategoryService.instance.setLastSelection(selection);

                    setState(() {
                      _category = selection;
                    });
                  },
                  child: Text(_category.name),
                ),
                const SizedBox(height: 16),
                AmountTextField(
                  controller: amountCtrl,
                  currency: _account.currency,
                ),
                const SizedBox(height: 16),
                PeriodDropdown(
                  initialSelection: _period,
                  onSelected: (newPeriod) {
                    setState(() {
                      _period = newPeriod;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: intervalCtrl,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an interval';
                    }

                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Interval',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: fabHeight),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              setState(() {
                _autovalidateMode = AutovalidateMode.onUserInteraction;
              });
              return;
            }

            var money = amountCtrl.text.toMoneyWithCurrency(_account.currency);
            var interval = int.parse(intervalCtrl.text);

            assert(money != null, 'Should have been checked with the amountFormatter');

            if (isEditing) {
              await RecurringService.instance.update(
                widget.model!,
                account: _account,
                category: _category,
                description: descriptionCtrl.text,
                from: _from,
                interval: interval,
                money: money,
                period: _period,
                type: _type,
                until: _until,
              );
            } else {
              await RecurringService.instance.add(
                account: _account,
                category: _category,
                description: descriptionCtrl.text,
                from: _from,
                interval: interval,
                money: money!,
                period: _period,
                type: _type,
                until: _until,
              );
            }

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Icon(Symbols.save),
        ),
      ),
    );
  }
}
