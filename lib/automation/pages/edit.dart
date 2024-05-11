import 'package:finances/automation/models/automation.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/common_values.dart';
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
  final _newRuleFormKey = GlobalKey<FormState>();
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
        actions: [
          AppBarDelete(
            visible: isEditing,
            title: 'Delete this automation?',
            description: 'Expenses categorized by this automation will be kept.',
            onDelete: () {
              AutomationService.instance.delete(widget.model!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: scaffoldPadding,
        controller: scrollCtrl,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      builder: (context) => CategoryListPage(CategoryService.instance.rootCategory),
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
                key: _newRuleFormKey,
                child: _RuleListItem(
                  formKey: _newRuleFormKey,
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
        onPressed: () async {
          if (!formKey.currentState!.validate()) {
            return;
          }

          formKey.currentState!.save();
          tempModel.name = nameCtrl.text;

          if (isEditing) {
            await AutomationService.instance.update(
              widget.model!,
              name: nameCtrl.text,
              category: tempModel.category,
              newRules: tempModel.rules,
            );
          } else {
            await AutomationService.instance.add(tempModel);
          }

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: const Icon(Symbols.save),
      ),
    );
  }
}

class _RuleListItem extends StatefulWidget {
  final void Function(Rule) onAction;
  final Rule? rule;
  final GlobalKey<FormState>? formKey;

  const _RuleListItem({
    super.key,
    required this.onAction,
    this.rule,
    this.formKey,
  });

  @override
  State<_RuleListItem> createState() => _RuleListItemState();
}

class _RuleListItemState extends State<_RuleListItem> {
  late final _remittanceInfoCtrl = TextEditingController(text: widget.rule?.remittanceInfo?.pattern);
  late final _creditorNameCtrl = TextEditingController(text: widget.rule?.creditorName?.pattern);
  late final _creditorIbanCtrl = TextEditingController(text: widget.rule?.creditorIban?.pattern);
  late final _isEditing = widget.rule != null;
  bool _showBottomError = false;

  @override
  void initState() {
    super.initState();
    Listenable.merge([
      _remittanceInfoCtrl,
      _creditorNameCtrl,
      _creditorIbanCtrl,
    ]).addListener(() {
      if (_showBottomError) {
        setState(() {
          _showBottomError = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _remittanceInfoCtrl.dispose();
    _creditorNameCtrl.dispose();
    _creditorIbanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onSaved: (value) {
                  if (_isEditing && _remittanceInfoCtrl.text.isNotEmpty) {
                    widget.rule!.remittanceInfo = RegExp(_remittanceInfoCtrl.text);
                  } else {
                    widget.rule!.remittanceInfo = null;
                  }
                },
                validator: _isValidRegex,
                controller: _remittanceInfoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Remittance info',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onSaved: (value) {
                  if (_isEditing && _creditorNameCtrl.text.isNotEmpty) {
                    widget.rule!.creditorName = RegExp(_creditorNameCtrl.text);
                  } else {
                    widget.rule!.creditorName = null;
                  }
                },
                validator: _isValidRegex,
                controller: _creditorNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Creditor name',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onSaved: (value) {
                  if (_isEditing && _creditorIbanCtrl.text.isNotEmpty) {
                    widget.rule!.creditorIban = RegExp(_creditorIbanCtrl.text);
                  } else {
                    widget.rule!.creditorIban = null;
                  }
                },
                validator: _isValidRegex,
                controller: _creditorIbanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Creditor IBAN',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        // When editing, the `onAction` is for deleting
                        // Don't validate when deleting
                        widget.onAction(widget.rule!);
                        return;
                      }

                      if (_remittanceInfoCtrl.text.isEmpty &&
                          _creditorNameCtrl.text.isEmpty &&
                          _creditorIbanCtrl.text.isEmpty) {
                        setState(() {
                          _showBottomError = true;
                        });
                        return;
                      }

                      if (widget.formKey?.currentState!.validate() == true) {
                        widget.onAction(Rule.fromStrings(
                          remittanceInfo: _remittanceInfoCtrl.text,
                          creditorName: _creditorNameCtrl.text,
                          creditorIban: _creditorIbanCtrl.text,
                        ));
                        setState(() {
                          _remittanceInfoCtrl.clear();
                          _creditorNameCtrl.clear();
                          _creditorIbanCtrl.clear();
                        });
                      }
                    },
                    label: Text(_isEditing ? 'Delete' : 'Add'),
                    icon: Icon(_isEditing ? Symbols.delete : Symbols.add),
                  ),
                  const SizedBox(width: 16),
                  Visibility(
                    visible: _showBottomError,
                    child: Text(
                      'Enter at least one field',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _isValidRegex(String? value) {
    if (value == null) {
      return null;
    }

    try {
      RegExp(value);
    } catch (e) {
      return 'Please enter a valid regex';
    }

    return null;
  }
}
