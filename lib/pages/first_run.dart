import 'package:finances/account/service.dart';
import 'package:finances/components/amount_text_field.dart';
import 'package:finances/components/currency_dropdown.dart';
import 'package:finances/importers/pages/importer_list_page.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

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
  var _currency = CommonCurrencies().euro;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _sumbitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    await AccountService.instance.add(
      name: _nameCtrl.text,
      initialMoney: _currency.parse(_amountCtrl.text),
    );

    AppPaths.notifyListeners();
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
                padding: const EdgeInsets.all(24),
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
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }

                          return null;
                        },
                        onFieldSubmitted: (value) => _sumbitForm(context),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Cash, bank...',
                        ),
                      ),
                      const SizedBox(height: 24),
                      AmountTextField(
                        controller: _amountCtrl,
                        labelText: 'Initial amount',
                        onFieldSubmitted: (value) => _sumbitForm(context),
                        currency: _currency,
                      ),
                      const SizedBox(height: 24),
                      CurrencyDropdown(
                        currency: _currency,
                        onChange: (newCurrency) {
                          setState(() {
                            _currency = newCurrency;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _sumbitForm(context),
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ImporterListPage()),
                          );
                        },
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Import'),
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
