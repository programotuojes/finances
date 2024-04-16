import 'package:finances/automation/models/automation.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/square_button.dart';
import 'package:finances/utils/app_bar_delete.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AutomationEditPage extends StatefulWidget {
  final Automation? model;

  const AutomationEditPage({
    super.key,
    this.model,
  });

  @override
  State<AutomationEditPage> createState() => _AutomationEditPageState();
}

class _AutomationEditPageState extends State<AutomationEditPage> {
  final scrollCtrl = ScrollController();
  final formKey = GlobalKey<FormState>();
  final tempModel = Automation(
    name: '',
    category: CategoryService.instance.lastSelection,
  );
  var needsScroll = false;
  late bool isEditing;
  late TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();

    isEditing = widget.model != null;

    if (isEditing) {
      final x = widget.model!;
      tempModel.name = x.name;
      tempModel.category = x.category;
      tempModel.rules = x.rules.toList();
    }

    nameCtrl = TextEditingController(text: tempModel.name);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      needsScroll = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit automation' : 'New automation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          AppBarDelete(
            visible: isEditing,
            title: 'Delete this automation?',
            description:
                'Expenses categorized by this automation will be kept.',
            onDelete: () {
              AutomationService.instance.delete(widget.model!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        controller: scrollCtrl,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                controller: nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 32),
              SquareButton(
                onPressed: () async {
                  var selected = await Navigator.push<CategoryModel>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryListPage(CategoryService.instance.root),
                    ),
                  );
                  if (selected == null) {
                    return;
                  }
                  CategoryService.instance.lastSelection = selected;
                  setState(() {
                    tempModel.category = selected;
                  });
                },
                child: Text(tempModel.category.name),
              ),
              const SizedBox(height: 32),
              for (final rule in tempModel.rules)
                _RuleListItem(
                  key: ObjectKey(rule),
                  rule: rule,
                  onAction: (rule) {
                    setState(() {
                      tempModel.rules.remove(rule);
                    });
                  },
                ),
              const Divider(),
              Form(
                child: _RuleListItem(
                  onAction: (rule) {
                    setState(() {
                      tempModel.rules.add(rule);
                      needsScroll = true;
                    });
                  },
                ),
              ),
              const SizedBox(height: 56 + 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            return;
          }

          formKey.currentState!.save();

          tempModel.name = nameCtrl.text;
          if (isEditing) {
            AutomationService.instance.update(widget.model!, tempModel);
          } else {
            AutomationService.instance.save(tempModel);
          }
          Navigator.of(context).pop();
        },
        child: const Icon(Symbols.save),
      ),
    );
  }
}

class _RuleListItem extends StatefulWidget {
  final void Function(Rule) onAction;
  final Rule? rule;

  const _RuleListItem({
    super.key,
    required this.onAction,
    this.rule,
  });

  @override
  State<_RuleListItem> createState() => _RuleListItemState();
}

class _RuleListItemState extends State<_RuleListItem> {
  final formKey = GlobalKey<FormFieldState>();
  final patternCtrl = TextEditingController();
  var invert = false;
  late bool isEditing;

  @override
  void initState() {
    super.initState();

    isEditing = widget.rule != null;

    if (isEditing) {
      patternCtrl.text = widget.rule!.regex.pattern;
      invert = widget.rule!.invert;
    }
  }

  @override
  void dispose() {
    patternCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: formKey,
              onSaved: (value) {
                if (isEditing) {
                  widget.rule!.regex = RegExp(patternCtrl.text);
                }
              },
              // autovalidateMode: autovalidateMode,
              scrollPadding: const EdgeInsets.only(bottom: double.maxFinite),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a pattern';
                }

                try {
                  RegExp(value);
                } catch (e) {
                  return 'Please enter a valid regex';
                }

                return null;
              },
              controller: patternCtrl,
              decoration: const InputDecoration(
                labelText: 'Pattern',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Text('Invert'),
                FormField<bool>(
                  onSaved: (value) {
                    if (isEditing) {
                      widget.rule!.invert = invert;
                    }
                  },
                  builder: (state) => Switch(
                    value: invert,
                    onChanged: (value) {
                      setState(() {
                        invert = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (isEditing) {
                // Don't validate when deleting
                widget.onAction(widget.rule!);
                return;
              }

              if (formKey.currentState!.validate()) {
                widget.onAction(Rule(
                  regex: RegExp(patternCtrl.text),
                  invert: invert,
                ));
                setState(() {
                  patternCtrl.clear();
                  invert = false;
                });
              }
            },
            padding: const EdgeInsets.all(16),
            icon: Icon(isEditing ? Symbols.delete : Symbols.add),
          ),
        ],
      ),
    );
  }
}
