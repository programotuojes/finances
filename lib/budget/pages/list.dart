import 'package:finances/budget/models/budget.dart';
import 'package:finances/budget/pages/edit.dart';
import 'package:finances/budget/service.dart';
import 'package:flutter/material.dart';

class BudgetListPage extends StatelessWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: ListenableBuilder(
        listenable: BudgetService.instance,
        builder: (context, _) {
          var budgets = BudgetService.instance.budgets;

          if (budgets.isEmpty) {
            return const Center(
              child: Text('No budgets found'),
            );
          }

          return ListView(
            children: [
              for (var i in budgets)
                ListTile(
                  title: Text(i.name),
                  subtitle: Text(_subtitle(i)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BudgetEditPage(budget: i),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BudgetEditPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _subtitle(Budget budget) {
    var now = DateTime.now();
    var moneyLeft = budget.limit - budget.usedThisPeriod(now);

    if (moneyLeft.isNegative) {
      return 'Overspent by ${(-moneyLeft).format('0S')}';
    } else {
      return '${moneyLeft.format('0S')} left this ${budget.period.name}';
    }
  }
}
