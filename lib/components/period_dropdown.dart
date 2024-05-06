import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';

class PeriodDropdown extends StatelessWidget {
  final Periodicity initialSelection;
  final void Function(Periodicity) onSelected;

  const PeriodDropdown({
    super.key,
    required this.initialSelection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Periodicity>(
      expandedInsets: const EdgeInsets.all(0),
      initialSelection: initialSelection,
      label: const Text('Periodicity'),
      onSelected: (selected) {
        if (selected == null) {
          return;
        }

        onSelected(selected);
      },
      dropdownMenuEntries: [for (final x in Periodicity.values) DropdownMenuEntry(value: x, label: x.toLy())],
    );
  }
}
