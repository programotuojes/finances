import 'package:finances/bank_sync/go_cardless_http_client.dart';
import 'package:flutter/material.dart';

class GoCardlessErrorContainer extends StatefulWidget {
  final ValueNotifier<GoCardlessError?> listenable;

  const GoCardlessErrorContainer({
    super.key,
    required this.listenable,
  });

  @override
  State<GoCardlessErrorContainer> createState() => _GoCardlessErrorContainerState();
}

class _GoCardlessErrorContainerState extends State<GoCardlessErrorContainer> with TickerProviderStateMixin {
  late final _animationCtrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
  late final Animation<double> _animation = CurvedAnimation(parent: _animationCtrl, curve: Curves.ease);

  /// To prevent the text from disappearing when closing the error message.
  GoCardlessError? _previousError;

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      child: ListenableBuilder(
        listenable: widget.listenable,
        builder: (context, child) {
          var error = widget.listenable.value;

          if (error != null) {
            _animationCtrl.forward();
            _previousError = error;
          } else {
            _animationCtrl.reverse();
            error = _previousError;
          }

          return SizeTransition(
            sizeFactor: _animation,
            child: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error?.summary ?? 'Error',
                          textScaler: const TextScaler.linear(1.5),
                        ),
                        Text(error?.detail ?? 'Something went wrong'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
