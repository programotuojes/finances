import 'package:finances/automation/models/automation.dart';
import 'package:finances/automation/pages/edit.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AutomationListPage extends StatelessWidget {
  const AutomationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation'),
      ),
      body: ListenableBuilder(
        listenable: AutomationService.instance,
        builder: (context, child) {
          var automations = AutomationService.instance.automations;
          if (automations.isEmpty) {
            return const Center(
              child: Text('No automations found'),
            );
          }
          return ListView.builder(
            itemCount: automations.length,
            itemBuilder: (context, index) {
              var automation = automations.elementAt(index);
              return ListTile(
                leading: CategoryIconSquare(
                  icon: automation.category.icon,
                  color: automation.category.color,
                ),
                title: Text(automation.name),
                subtitle: Text(_subtitle(automation)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AutomationEditPage(model: automation),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AutomationEditPage(),
            ),
          );
        },
        child: const Icon(Symbols.add),
      ),
    );
  }

  String _subtitle(Automation automation) {
    var count = automation.rules.length;

    if (count == 1) {
      return '1 rule';
    }

    return '$count rules';
  }
}
