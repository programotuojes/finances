import 'package:finances/components/category_icon.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/recurring/pages/edit.dart';
import 'package:finances/recurring/service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RecurringListPage extends StatelessWidget {
  const RecurringListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring transactions'),
      ),
      body: ListenableBuilder(
        listenable: RecurringService.instance,
        builder: (context, _) => ListView(
          children: [
            for (var i in RecurringService.instance.transactions)
              ListTile(
                title: Text(i.category.name),
                leading: CategoryIcon(
                  icon: i.category.icon,
                  color: i.category.color,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.money.toString()),
                    if (i.description != null) Text(i.description!),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(i.humanReadablePeriod),
                    if (i.until != null) untilString(i),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecurringEditPage(model: i),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecurringEditPage(),
            ),
          );
        },
        child: const Icon(Symbols.add),
      ),
    );
  }

  Widget untilString(RecurringModel model) {
    var text = 'Until ${model.until!.toIso8601String().substring(0, 10)}';
    final nextDate = model.nextDate(DateUtils.dateOnly(DateTime.now()));

    if (nextDate == null) {
      text += ' (ended)';
    }

    return Text(text);
  }
}
