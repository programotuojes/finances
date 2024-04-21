import 'package:flutter/material.dart';

const _cardPadding = 16.0;

class HomeCard extends StatelessWidget {
  final String title;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;

  const HomeCard({
    super.key,
    required this.title,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.symmetric(horizontal: _cardPadding),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.all(_cardPadding),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _cardPadding),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
          const SizedBox(height: _cardPadding),
        ],
      ),
    );
  }
}
