import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/edit.dart';
import 'package:finances/category/service.dart';
import 'package:flutter/material.dart';

class CategoryListPage extends StatelessWidget {
  final CategoryModel category;

  const CategoryListPage(this.category, {super.key});

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
                onTap: () {
                  if (i.children.isNotEmpty) {
                    goDeeper(context, i);
                  } else {
                    editCategory(context, i);
                  }
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          editCategory(context, category);
        },
      ),
    );
  }

  void goDeeper(BuildContext context, CategoryModel selectedCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryListPage(selectedCategory)),
    );
  }

  void editCategory(BuildContext context, CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryEditPage(category)),
    );
  }
}

