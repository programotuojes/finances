import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:flutter/material.dart';

class CategoryListTile extends StatefulWidget {
  final CategoryModel initialCategory;
  final void Function(CategoryModel) onCategorySelected;
  final EdgeInsets? listTilePadding;

  const CategoryListTile({
    super.key,
    required this.initialCategory,
    required this.onCategorySelected,
    this.listTilePadding,
  });

  @override
  State<CategoryListTile> createState() => _CategoryListTileState();
}

class _CategoryListTileState extends State<CategoryListTile> {
  late CategoryModel category = widget.initialCategory;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: widget.listTilePadding,
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

        await CategoryService.instance.setLastSelection(selectedCategory);

        widget.onCategorySelected(selectedCategory);
        setState(() {
          category = selectedCategory;
        });
      },
      leading: CategoryIconSquare(
        icon: category.icon,
        color: category.color,
      ),
      title: Text(category.name),
    );
  }
}
