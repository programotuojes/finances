import 'package:finances/expense/models/expense.dart';
import 'package:flutter/material.dart';

class EditExpensePage extends StatelessWidget {
  final Expense expense;

  const EditExpensePage(this.expense, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {},
      ),
    );
  }
}
