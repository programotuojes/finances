import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';

const double _paddingForFab = 100;

class CategoryEditPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryEditPage(this.category, {super.key});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late String categoryName;
  VoidCallback? onPressed;

  final textCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    textCtrl.addListener(() {
      setState(() {
        onPressed = textCtrl.text.isNotEmpty ? addCategory : null;
      });
    });
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  void addCategory() {
    setState(() {
      widget.category.addChild(textCtrl.text);
      textCtrl.clear();
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  onSaved: (value) => categoryName = value!,
                  initialValue: widget.category.name,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onTapOutside: (event) {
                    // FocusManager.instance.primaryFocus?.unfocus();
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
                        Icons.food_bank,
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
                      Icons.food_bank,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  title: TextField(
                    controller: textCtrl,
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        // TODO disable if the form content hasn't changed
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            return;
          }

          formKey.currentState!.save();
          widget.category.update(categoryName);
        },
      ),
    );
  }
}

// class NewCategoryListTile extends StatefulWidget {
//   final CategoryModel parent;
//   const NewCategoryListTile(this.parent, {super.key});
//
//   @override
//   State<NewCategoryListTile> createState() => _NewCategoryListTileState();
// }
//
// class _NewCategoryListTileState extends State<NewCategoryListTile> {
//   late TextEditingController textCtrl;
//   VoidCallback? onPressed;
//
//   @override
//   void initState() {
//     super.initState();
//     textCtrl = TextEditingController();
//     textCtrl.addListener(() {
//       setState(() {
//         onPressed = textCtrl.text.isNotEmpty ? addCategory : null;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     textCtrl.dispose();
//     super.dispose();
//   }
//
//   void addCategory() {
//     widget.parent.addChild(textCtrl.text);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//         child: Icon(
//           Icons.food_bank,
//           color: Theme.of(context).colorScheme.onPrimary,
//         ),
//       ),
//       title: TextField(
//         controller: textCtrl,
//         decoration: const InputDecoration(
//           hintText: 'New category name',
//           border: UnderlineInputBorder(),
//         ),
//         textCapitalization: TextCapitalization.sentences,
//         scrollPadding: const EdgeInsets.all(_paddingForFab),
//       ),
//       trailing: FilledButton(
//         onPressed: onPressed,
//         child: const Text('Add'),
//       ),
//     );
//   }
// }
