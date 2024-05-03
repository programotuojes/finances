import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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
  late final nameTextCtrl = TextEditingController(text: widget.category.name);
  final newChildTextCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late var _color = widget.category.color;

  @override
  void dispose() {
    nameTextCtrl.dispose();
    newChildTextCtrl.dispose();
    super.dispose();
  }

  void addCategory() {
    setState(() {
      CategoryService.instance.addChild(
        widget.category,
        CategoryModel(
          id: 0,
          name: newChildTextCtrl.text,
          icon: Symbols.attach_money, // TODO allow selecting the icon
          color: _color,
        ),
      );
      newChildTextCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.category.name.toLowerCase()}'),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        CategoryIcon(icon: Icons.map, color: _color),
                        Expanded(
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
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _colorPickerDialog(context);
                      },
                      child: const Text('Change color'),
                    ),
                  ],
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
                    leading: CategoryIcon(
                      icon: i.icon,
                      color: i.color,
                    ),
                    onTap: () {},
                  ),
                const Divider(),
                ListTile(
                  leading: const CategoryIcon(
                    icon: Symbols.question_mark,
                    color: Colors.red,
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            return;
          }

          CategoryService.instance.update(
            widget.category,
            newName: nameTextCtrl.text,
            newColor: _color,
          );

          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _colorPickerDialog(BuildContext context) async {
    var newColor = await showColorPickerDialog(
      context,
      _color,
      barrierColor: Colors.black54,
      wheelDiameter: 172,
      wheelSquarePadding: 8,
      wheelSquareBorderRadius: 0,
      showColorCode: true,
      colorCodeHasColor: true,
      enableShadesSelection: false,
      enableTonalPalette: true,
      tonalColorSameSize: true,
      hasBorder: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
      ),
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 250,
      ),
      tonalSubheading: const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Tones'),
      ),
    );

    setState(() {
      _color = newColor;
    });
  }
}
