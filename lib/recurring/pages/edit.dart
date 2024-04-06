import 'package:flutter/material.dart';

class RecurringEditPage extends StatelessWidget {
  const RecurringEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring payments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Placeholder(),
    );
  }
}
