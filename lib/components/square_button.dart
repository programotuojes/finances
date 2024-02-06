import 'package:flutter/material.dart';

// TODO add a label ala text fields
class SquareButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const SquareButton({
    super.key,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 96,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          // TODO change text color
          textStyle: Theme.of(context).primaryTextTheme.bodyLarge,
          shape: const RoundedRectangleBorder(
            side: BorderSide(),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
