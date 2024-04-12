import 'package:finances/components/home_card.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/recurring/pages/edit.dart';
import 'package:finances/recurring/service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RecurringTransactionCard extends StatelessWidget {
  const RecurringTransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: 'Recurring transactions',
      withoutChildPadding: true,
      child: ListenableBuilder(
        listenable: RecurringService.instance,
        builder: (context, child) {
          return Column(
            children: [
              for (final i in RecurringService.instance.activeTransactions)
                _RecurringListItem(recurringModel: i),
            ],
          );
        },
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
      contentPadding: const EdgeInsets.only(
        left: 16,
        right: 12, // Otherwise `trailing` is too far from the edge
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NextTransactionDate(recurringModel: recurringModel),
          IconButton(
            onPressed: () {
              RecurringService.instance.confirm(recurringModel);
            },
            tooltip: 'Confirm',
            icon: const Icon(Symbols.post_add),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecurringEditPage(
              model: recurringModel,
            ),
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
      final name = recurringModel.category.name;
      print('Recurring for $name has ended, but was displayed in the list');
      return const Text('Ended');
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
