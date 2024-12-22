import 'package:finances/transaction/components/expense_column.dart';
import 'package:finances/transaction/models/temp_combined.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ExpenseCard extends StatefulWidget {
  final VoidCallback? onDelete;
  final bool showCategory;
  final TempCombined entity;

  const ExpenseCard({
    super.key,
    this.onDelete,
    this.showCategory = true,
    required this.entity,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  late TextEditingController _amountCtrl;
  late TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    var amount = widget.entity.money.amount;
    _amountCtrl = TextEditingController(text: amount.isZero ? null : amount.toString());
    _descriptionCtrl = TextEditingController(text: widget.entity.description);

    _amountCtrl.addListener(() {
      var money = _amountCtrl.text.toMoney();
      if (money != null) {
        widget.entity.money = money;
      }
    });

    _descriptionCtrl.addListener(() {
      widget.entity.description = _descriptionCtrl.text;
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
              child: ExpenseColumn(
                showCategory: widget.showCategory,
                initialCategory: widget.entity.category,
                onCategorySelected: (category) {
                  setState(() {
                    widget.entity.category = category;
                  });
                },
                amountCtrl: _amountCtrl,
                descriptionCtrl: _descriptionCtrl,
                currency: widget.entity.currency,
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
                  visible: widget.entity.expense?.importedWalletDbExpense != null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        _showWalletDbImportInfo(context);
                      },
                      tooltip: 'Wallet info',
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

  Future<void> _showWalletDbImportInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet import info'),
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
                _fieldRow('Record ID', widget.entity.expense!.importedWalletDbExpense!.recordId),
                _fieldRow('Account ID', widget.entity.expense!.importedWalletDbExpense!.accountId),
                _fieldRow('Category ID', widget.entity.expense!.importedWalletDbExpense!.categoryId),
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
