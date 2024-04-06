import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/recurring/pages/edit.dart';
import 'package:finances/recurring/service.dart';
import 'package:flutter/material.dart';

class RecurringTransactionCard extends StatelessWidget {
  const RecurringTransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: RecurringService.instance,
          builder: (context, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Recurring transactions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              for (final i in RecurringService.instance.transactions)
                _RecurringListItem(recurringModel: i),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecurringListItem extends StatelessWidget {
  const _RecurringListItem({
    required this.recurringModel,
  });

  final RecurringModel recurringModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          recurringModel.category.icon,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      title: Text(recurringModel.category.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recurringModel.money.toString()),
          if (recurringModel.description != null)
            Text(recurringModel.description!),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NextTransactionDate(recurringModel: recurringModel),
          TextButton(
            onPressed: () {
              RecurringService.instance.confirm(recurringModel);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecurringEditPage(),
          ),
        );
      },
    );
  }
}

class _NextTransactionDate extends StatelessWidget {
  const _NextTransactionDate({
    required this.recurringModel,
  });

  final RecurringModel recurringModel;

  @override
  Widget build(BuildContext context) {
    final now = DateUtils.dateOnly(DateTime.now());
    final nextDate = recurringModel.nextDate(now);

    if (nextDate == null) {
      print('Recurring transaction has ended');
      return const Placeholder();
    }

    String durationText;
    Color? color;

    if (now.isAfter(nextDate)) {
      final duration = DateTimeRange(start: nextDate, end: now).duration.inDays;
      final days = duration != 1 ? 'days' : 'day';
      durationText = '$duration $days ago';
      color = Theme.of(context).colorScheme.error;
    } else if (now.isBefore(nextDate)) {
      final duration = DateTimeRange(start: now, end: nextDate).duration.inDays;
      final days = duration != 1 ? 'days' : 'day';
      durationText = 'In $duration $days';
    } else {
      durationText = 'Due today';
    }

    return Text(
      durationText,
      style: TextStyle(color: color),
    );
  }
}
