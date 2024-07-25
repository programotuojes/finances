import 'package:finances/transaction/pages/edit_transaction.dart';
import 'package:finances/transaction/pages/edit_transfer.dart';
import 'package:flutter/material.dart';

@immutable
class HomeFab extends StatefulWidget {
  const HomeFab({
    super.key,
  });

  @override
  State<HomeFab> createState() => _HomeFabState();
}

class _HomeFabState extends State<HomeFab> {
  var _open = false;

  void _setOpen(bool state) {
    setState(() {
      _open = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        _setOpen(false);
      },
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              right: 8,
              bottom: (_open ? 56 + 16 : 0) + 8,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: FloatingActionButton.small(
                heroTag: null,
                tooltip: 'New transfer',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditTransferPage(),
                    ),
                  );
                },
                child: const Icon(Icons.swap_horiz),
              ),
            ),
            FloatingActionButton(
              onPressed: () async {
                if (_open) {
                  _setOpen(false);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionEditPage(),
                    ),
                  );
                } else {
                  _setOpen(true);
                }
              },
              tooltip: 'New expense',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
