import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const double _paddingForFab = 100;

class CategoryEditPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryEditPage(this.category, {super.key});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  VoidCallback? onPressed;
  bool showFab = false;
  late TextEditingController nameTextCtrl;
  late TextEditingController newChildTextCtrl;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameTextCtrl = TextEditingController(text: widget.category.name);
    newChildTextCtrl = TextEditingController();

    newChildTextCtrl.addListener(() {
      setState(() {
        onPressed = newChildTextCtrl.text.isNotEmpty ? addCategory : null;
      });
    });
  }

  @override
  void dispose() {
    nameTextCtrl.dispose();
    newChildTextCtrl.dispose();
    super.dispose();
  }

  void addCategory() {
    setState(() {
      widget.category.addChild(
        newChildTextCtrl.text,
        Symbols.attach_money, // TODO allow selecting the icon
      );
      newChildTextCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.category.name.toLowerCase()}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Material(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Form(
                key: formKey,
                onChanged: () {
                  setState(() {
                    showFab = widget.category.name != nameTextCtrl.text;
                  });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: nameTextCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    helperText: '',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [
                for (var i in widget.category.children)
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
                        i.icon,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    onTap: () {},
                  ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      Symbols.attach_money,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  title: TextField(
                    controller: newChildTextCtrl,
                    decoration: const InputDecoration(
                      hintText: 'New category name',
                      border: UnderlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    scrollPadding: const EdgeInsets.all(_paddingForFab),
                  ),
                  trailing: FilledButton(
                    onPressed: onPressed,
                    child: const Text('Add'),
                  ),
                ),
                // NewCategoryListTile(widget.category),
                const Padding(padding: EdgeInsets.only(bottom: _paddingForFab)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        switchInCurve: Curves.easeOutExpo,
        switchOutCurve: Curves.easeInExpo,
        duration: const Duration(milliseconds: 300),
        child: !showFab
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.save),
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  widget.category.update(nameTextCtrl.text);
                },
              ),
      ),
    );
  }
}
