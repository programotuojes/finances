import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/recurring/service.dart';
import 'package:finances/utils/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RecurringEditPage extends StatefulWidget {
  final RecurringModel? model;

  const RecurringEditPage({super.key, this.model});

  @override
  State<RecurringEditPage> createState() => _RecurringEditPageState();
}

class _RecurringEditPageState extends State<RecurringEditPage> {
  final tempModel = RecurringModel(
    account: AccountService.instance.lastSelection,
    category: CategoryService.instance.lastSelection,
    money: '0'.toMoney('EUR')!,
    description: null,
    periodicity: Periodicity.month,
    interval: 1,
    from: DateTime.now(),
    until: null,
  );

  late TextEditingController amountCtrl;
  late TextEditingController intervalCtrl;
  late TextEditingController descriptionCtrl;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(
      text: widget.model?.money.amount.toString(),
    );
    intervalCtrl = TextEditingController(
      text: widget.model?.interval.toString(),
    );
    descriptionCtrl = TextEditingController(
      text: widget.model?.description,
    );

    isEditing = widget.model != null;

    if (isEditing) {
      tempModel.account = widget.model!.account;
      tempModel.category = widget.model!.category;
      tempModel.periodicity = widget.model!.periodicity;
      tempModel.interval = widget.model!.interval;
      tempModel.from = widget.model!.from;
      tempModel.until = widget.model!.until;
    }
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    intervalCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFromString = tempModel.from.toIso8601String().substring(0, 10);
    final dateUntilString =
        (tempModel.until ?? DateTime.now()).toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: isEditing
            ? [
                IconButton(
                  onPressed: () async {
                    final accepted = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              const Text('Delete this recurring transaction?'),
                          content: const Text(
                              'All of the confirmed transactions will be kept.'),
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
                      RecurringService.instance.delete(widget.model!);
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(
                    Symbols.delete,
                  ),
                )
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: scaffoldPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownMenu<Account>(
              expandedInsets: const EdgeInsets.all(0),
              initialSelection: tempModel.account,
              label: const Text('Account'),
              onSelected: (selected) {
                if (selected == null) return;
                setState(() {
                  tempModel.account = selected;
                });
              },
              dropdownMenuEntries: [
                for (final x in AccountService.instance.accounts)
                  DropdownMenuEntry(value: x, label: x.name)
              ],
            ),
            const SizedBox(height: 16),
            SquareButton(
              onPressed: () async {
                var selected = await showDatePicker(
                  context: context,
                  initialDate: tempModel.from,
                  firstDate: DateTime(0),
                  lastDate: DateTime(9999),
                );
                if (selected == null) {
                  return;
                }
                setState(() {
                  tempModel.from = selected;
                });
              },
              child: Text(dateFromString),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Has end date'),
              value: tempModel.until != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    tempModel.until = DateTime.now();
                  } else {
                    tempModel.until = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            SquareButton(
              onPressed: tempModel.until != null
                  ? () async {
                      var selected = await showDatePicker(
                        context: context,
                        initialDate: tempModel.until,
                        firstDate: tempModel.from,
                        lastDate: DateTime(9999),
                      );
                      if (selected == null) {
                        return;
                      }
                      setState(() {
                        tempModel.until = selected;
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
                    builder: (context) =>
                        CategoryListPage(CategoryService.instance.root),
                  ),
                );
                if (selection == null) {
                  return;
                }
                CategoryService.instance.lastSelection = selection;
                setState(() {
                  tempModel.category = selection;
                });
              },
              child: Text(tempModel.category.name),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            DropdownMenu<Periodicity>(
              expandedInsets: const EdgeInsets.all(0),
              initialSelection: tempModel.periodicity,
              label: const Text('Periodicity'),
              onSelected: (selected) {
                if (selected == null) {
                  return;
                }
                setState(() {
                  tempModel.periodicity = selected;
                });
              },
              dropdownMenuEntries: [
                for (final x in Periodicity.values)
                  DropdownMenuEntry(value: x, label: x.toLy())
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: intervalCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
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
            const SizedBox(height: 56 + 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final money = amountCtrl.text.toMoney('EUR');
          if (money == null) {
            print('Invalid amount (${amountCtrl.text})');
            return;
          }

          final interval = int.tryParse(intervalCtrl.text);
          if (interval == null) {
            print('Invalid interval (${intervalCtrl.text})');
            return;
          }

          tempModel.money = money;
          tempModel.interval = interval;
          tempModel.description = descriptionCtrl.text;

          if (isEditing) {
            RecurringService.instance.update(widget.model!, tempModel);
          } else {
            RecurringService.instance.add(tempModel);
          }
          Navigator.of(context).pop();
        },
        child: const Icon(Symbols.save),
      ),
    );
  }
}

extension LyNaming on Periodicity {
  String toLy() {
    return switch (this) {
      Periodicity.day => 'Daily',
      Periodicity.week => 'Weekly',
      Periodicity.month => 'Monthly',
      Periodicity.year => 'Yearly',
    };
  }
}
