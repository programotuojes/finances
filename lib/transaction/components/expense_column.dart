import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/components/category_list_tile.dart';
import 'package:finances/transaction/components/text_field_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ExpenseColumn extends StatelessWidget {
  final CategoryModel initialCategory;
  final void Function(CategoryModel) onCategorySelected;
  final TextEditingController amountCtrl;
  final TextEditingController descriptionCtrl;
  final bool morePadding;
  final bool showCategory;

  const ExpenseColumn({
    super.key,
    required this.initialCategory,
    required this.onCategorySelected,
    required this.amountCtrl,
    required this.descriptionCtrl,
    this.morePadding = false,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCategory)
          CategoryListTile(
            initialCategory: initialCategory,
            onCategorySelected: onCategorySelected,
            morePadding: morePadding,
          ),
        TextFieldListTile(
          controller: amountCtrl,
          icon: Symbols.euro,
          hintText: 'Amount',
          morePadding: morePadding,
          money: true,
        ),
        TextFieldListTile(
          controller: descriptionCtrl,
          icon: Symbols.description,
          hintText: 'Description',
          morePadding: morePadding,
        ),
      ],
    );
  }
}
