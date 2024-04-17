import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppBarDelete extends StatelessWidget {
  final bool visible;
  final String title;
  final String description;
  final VoidCallback onDelete;

  const AppBarDelete({
    super.key,
    required this.title,
    required this.description,
    required this.onDelete,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: IconButton(
        tooltip: 'Delete',
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(title),
                content: Text(description),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      onDelete();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Symbols.delete),
      ),
    );
  }
}
