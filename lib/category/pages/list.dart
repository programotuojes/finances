import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/edit.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
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
      ),
      body: ListenableBuilder(
        listenable: CategoryService.instance,
        builder: (context, _) => ListView(
          children: [
            for (var i in category.children)
              ListTile(
                title: Text(i.name),
                leading: CategoryIconSquare(
                  icon: i.icon,
                  color: i.color,
                ),
                contentPadding: const EdgeInsets.only(
                  left: 16,
                  right: 12, // Otherwise `trailing` is too far from the edge
                ),
                trailing: i.children.isNotEmpty
                    ? InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          await goDeeper(context, i);
                        },
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.navigate_next),
                        ),
                      )
                    : null,
                onTap: () {
                  listItemSelected(context, i);
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

    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  void listItemSelected(BuildContext context, CategoryModel selected) {
    if (isForEditing) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryEditPage(selected),
        ),
      );
    } else {
      Navigator.pop(context, selected);
    }
  }
}
