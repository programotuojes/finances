import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final IconData icon;

  const CategoryIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
