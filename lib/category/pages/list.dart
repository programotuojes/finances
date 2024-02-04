import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/edit.dart';
import 'package:finances/category/service.dart';
import 'package:flutter/material.dart';

class CategoryListPage extends StatelessWidget {
  final CategoryModel category;
  final bool isForEditing;

  const CategoryListPage(
    this.category, {
    super.key,
    this.isForEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: CategoryService.instance,
        builder: (context, _) => ListView(
          children: [
            for (var i in category.children)
              ListTile(
                title: Text(i.name),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.food_bank,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                trailing: i.children.isNotEmpty
                    ? const Icon(Icons.navigate_next)
                    : null,
                onTap: () async {
                  if (i.children.isNotEmpty) {
                    await goDeeper(context, i);
                  } else {
                    emptyCategoryClicked(context, i);
                  }
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryEditPage(category),
            ),
          );
        },
      ),
    );
  }

  Future<void> goDeeper(BuildContext context, CategoryModel selected) async {
    var result = await Navigator.push<CategoryModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryListPage(
          selected,
          isForEditing: isForEditing,
        ),
      ),
    );

    if (!context.mounted) return;

    if (!isForEditing) {
      Navigator.pop(context, result);
    }
  }

  void emptyCategoryClicked(BuildContext context, CategoryModel category) {
    if (isForEditing) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryEditPage(category),
        ),
      );
    } else {
      Navigator.pop(context, category);
    }
  }
}

