import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/transaction/components/expense_card.dart';
import 'package:finances/transaction/models/temp_combined.dart';
import 'package:finances/transaction/models/transfer.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

final _accountOutsideApp = Account(name: 'Outside the app', initialMoney: zeroEur);

class EditTransferPage extends StatefulWidget {
  final Transfer? transfer;

  const EditTransferPage({
    super.key,
    this.transfer,
  });

  @override
  State<EditTransferPage> createState() => _EditTransferPageState();
}

class _EditTransferPageState extends State<EditTransferPage> {
  late final _amountCtrl = TextEditingController(text: widget.transfer?.money.amount.toString());
  late final _descriptionCtrl = TextEditingController(text: widget.transfer?.description);
  late final _isEditing = widget.transfer != null;
  late final _transfer = Transfer(
    id: widget.transfer?.id,
    money: widget.transfer?.money ?? zeroEur,
    description: widget.transfer?.description ?? '',
    from: widget.transfer?.from,
    to: widget.transfer?.to,
    dateTime: widget.transfer?.dateTime ?? DateTime.now(),
  );

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeParts = _transfer.dateTime.toIso8601String().split('T');
    final date = dateTimeParts[0];
    final time = dateTimeParts[1].substring(0, 5);

    return Scaffold(
      appBar: AppBar(
        title: _isEditing ? const Text('Edit transfer') : const Text('New transfer'),
        actions: [
          AppBarDelete(
            visible: _isEditing,
            title: 'Delete this transfer?',
            description: 'This cannot be undone.',
            onDelete: () async {
              await TransactionService.instance.deleteTransfer(widget.transfer!);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isEditing) {
            await TransactionService.instance.updateTransfer(widget.transfer!, _transfer);
          } else {
            await TransactionService.instance.addTransfer(_transfer);
          }

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: scaffoldPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownMenu<Account>(
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: _transfer.from,
                    label: const Text('From account'),
                    onSelected: (selected) {
                      if (selected == null) {
                        return;
                      }
                      setState(() {
                        _transfer.from = selected;
                      });
                    },
                    dropdownMenuEntries: [
                      for (final x in AccountService.instance.accounts) DropdownMenuEntry(value: x, label: x.name),
                      DropdownMenuEntry(
                        value: _accountOutsideApp,
                        label: _accountOutsideApp.name,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownMenu<Account>(
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: _transfer.to,
                    label: const Text('To account'),
                    onSelected: (selected) {
                      if (selected == null) {
                        return;
                      }
                      setState(() {
                        _transfer.to = selected;
                      });
                    },
                    dropdownMenuEntries: [
                      for (final x in AccountService.instance.accounts) DropdownMenuEntry(value: x, label: x.name),
                      DropdownMenuEntry(
                        value: _accountOutsideApp,
                        label: _accountOutsideApp.name,
                      ),
                    ],
                  ),
                ),
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
                        initialDate: _transfer.dateTime,
                        firstDate: DateTime(0),
                        lastDate: DateTime(9999),
                      );
                      if (selected == null) return;
                      setState(() {
                        _transfer.dateTime = _transfer.dateTime.copyWith(
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
                        initialTime: TimeOfDay.fromDateTime(_transfer.dateTime),
                      );
                      if (selected == null) return;
                      setState(() {
                        _transfer.dateTime = _transfer.dateTime.copyWith(
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
            const SizedBox(height: 16),
            ExpenseCard(
              entity: TempCombined(transfer: _transfer),
              showCategory: false,
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}
