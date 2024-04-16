import 'package:flutter/material.dart';

class ConditionalTooltip extends StatelessWidget {
  final bool showTooltip;
  final String message;
  final Widget child;

  const ConditionalTooltip({
    super.key,
    required this.showTooltip,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTooltip) {
      return child;
    }

    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 500),
      exitDuration: Duration.zero,
      child: child,
    );
  }
}
