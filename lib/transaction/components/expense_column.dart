import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/components/autocomplete_list_tile.dart';
import 'package:finances/transaction/components/category_list_tile.dart';
import 'package:finances/transaction/components/text_field_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:money2/money2.dart';

class ExpenseColumn extends StatelessWidget {
  final CategoryModel initialCategory;
  final void Function(CategoryModel) onCategorySelected;
  final TextEditingController amountCtrl;
  final TextEditingController descriptionCtrl;
  final EdgeInsets? listTilePadding;
  final bool showCategory;
  final Currency currency;

  const ExpenseColumn({
    super.key,
    required this.initialCategory,
    required this.onCategorySelected,
    required this.amountCtrl,
    required this.descriptionCtrl,
    this.listTilePadding,
    this.showCategory = true,
    required this.currency,
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
            listTilePadding: listTilePadding,
          ),
        TextFieldListTile(
          controller: amountCtrl,
          icon: Symbols.euro,
          hintText: 'Amount',
          listTilePadding: listTilePadding,
          currency: currency,
        ),
        AutocompleteListTile(
          listTilePadding: listTilePadding,
          controller: descriptionCtrl,
        ),
      ],
    );
  }
}
