import 'dart:math';

import 'package:finances/budget/models/budget.dart';
import 'package:finances/budget/pages/edit.dart';
import 'package:finances/budget/service.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/home_card.dart';
import 'package:finances/transaction/service.dart';

import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: 'Budgets',
      child: ListenableBuilder(
          listenable: Listenable.merge([
            BudgetService.instance,
            TransactionService.instance,
            CategoryService.instance,
          ]),
          builder: (context, child) {
            var budgets = BudgetService.instance.budgets;

            if (budgets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('No budgets found'),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetEditPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [for (var i in budgets) _BudgetChart(i)],
            );
          }),
    );
  }
}

class _BudgetChart extends StatelessWidget {
  final Budget budget;

  const _BudgetChart(this.budget);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    var currentSpending = budget.usedThisPeriod(now);
    var value = currentSpending.dividedBy(budget.limit);
    var moneyLeft = budget.limit - currentSpending;

    var range = budget.currentRange(now);
    var timeValue = (now.millisecondsSinceEpoch - range.start.millisecondsSinceEpoch) /
        (range.end.millisecondsSinceEpoch - range.start.millisecondsSinceEpoch);
    var timeLeft = DateTimeRange(start: now, end: range.end).duration.inDays;
    if (timeLeft == 0) {
      timeLeft = 1;
    }

    String message;
    if (moneyLeft.isNegative) {
      message = 'Overspent by ${(-moneyLeft).format('0S')}';
    } else {
      var days = timeLeft == 1 ? 'day' : 'days';
      message = 'You can spend ${(moneyLeft / timeLeft).format('0S')} per day for the next $timeLeft $days';
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.name,
                    textScaler: const TextScaler.linear(1.3),
                  ),
                  Text(message),
                ],
              ),
            ),
            Text('${currentSpending.format('0S')} / ${budget.limit.format('0S')}'),
          ],
        ),
        const SizedBox(height: 4),
        _BarChart(
          color: budget.categories.first.category.color,
          value: value,
          timeValue: timeValue,
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final Color color;
  final double value;
  final double timeValue;

  const _BarChart({
    required this.color,
    required this.value,
    required this.timeValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var left = constraints.maxWidth * timeValue;

        return SizedBox(
          height: 70,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 30,
                  color: color,
                  value: value,
                ),
              ),
              Positioned(
                left: max(0, left - 48),
                right: min(constraints.maxWidth - 48, constraints.maxWidth - left),
                child: SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          border: const Border.symmetric(vertical: BorderSide(width: 0.5)),
                        ),
                        width: 3,
                        height: 30,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: value < timeValue
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            'Today',
                            textScaler: TextScaler.linear(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
