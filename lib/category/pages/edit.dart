import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/components/common_values.dart';
import 'package:flutter/material.dart';

class CategoryEditPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryEditPage(this.category, {super.key});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late final _nameCtrl = TextEditingController(text: widget.category.name);
  final _childNameCtrl = TextEditingController();
  var _childNameEmpty = true;
  var _childColor = const Color(0xFFBDBDBD);
  var _childIcon = Icons.question_mark;
  final _formKey = GlobalKey<FormState>();
  late var _color = widget.category.color;
  late var _icon = widget.category.icon;

  @override
  void initState() {
    super.initState();
    _childNameCtrl.addListener(() {
      setState(() {
        _childNameEmpty = _childNameCtrl.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _childNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    await CategoryService.instance.addChild(
      widget.category,
      name: _childNameCtrl.text,
      color: _childColor,
      icon: _childIcon,
    );

    _childNameCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = widget.category.children;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit category'),
      ),
      body: Column(
        children: [
          Material(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Row(
                  children: [
                    CategoryIcon(
                      icon: _icon,
                      color: _color,
                      onChange: (newColor, newIcon) {
                        setState(() {
                          _color = newColor;
                          _icon = newIcon;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.only(top: 16),
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final movedItem = subcategories.removeAt(oldIndex);

                setState(() {
                  subcategories.insert(newIndex, movedItem);
                });
              },
              footer: Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: CategoryIcon(
                      color: _childColor,
                      icon: _childIcon,
                      onChange: (newColor, newIcon) {
                        setState(() {
                          _childColor = newColor;
                          _childIcon = newIcon;
                        });
                      },
                    ),
                    title: TextField(
                      controller: _childNameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'New category name',
                        border: UnderlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      scrollPadding: const EdgeInsets.only(top: double.infinity),
                    ),
                    trailing: FilledButton(
                      onPressed: !_childNameEmpty
                          ? () async {
                              await _addCategory();
                            }
                          : null,
                      child: const Text('Add'),
                    ),
                  ),
                  const SizedBox(height: fabHeight),
                ],
              ),
              children: [
                for (var category in subcategories)
                  ListTile(
                    key: ObjectKey(category),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryEditPage(category),
                        ),
                      );

                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                    title: Text(category.name),
                    leading: CategoryIcon(
                      icon: category.icon,
                      color: category.color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          await CategoryService.instance.update(
            widget.category,
            newName: _nameCtrl.text,
            newColor: _color,
            newIcon: _icon,
          );

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
