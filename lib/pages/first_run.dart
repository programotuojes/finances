import 'package:finances/account/service.dart';
import 'package:finances/components/amount_text_field.dart';
import 'package:finances/pages/home_page.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';

class FirstRunPage extends StatefulWidget {
  const FirstRunPage({super.key});

  @override
  State<FirstRunPage> createState() => _FirstRunPageState();
}

class _FirstRunPageState extends State<FirstRunPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  var _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Set up your first account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }

                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Cash, bank...',
                        ),
                      ),
                      const SizedBox(height: 24),
                      AmountTextField(
                        controller: _amountCtrl,
                        labelText: 'Initial amount',
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            setState(() {
                              _autoValidateMode = AutovalidateMode.onUserInteraction;
                            });
                            return;
                          }

                          await AccountService.instance.add(
                            name: _nameCtrl.text,
                            initialMoney: _amountCtrl.text.toMoney()!,
                          );

                          if (context.mounted) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}