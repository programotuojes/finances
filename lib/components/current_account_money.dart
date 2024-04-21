import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/service.dart';
import 'package:flutter/material.dart';

class CurrentAccountMoney extends StatelessWidget {
  final Account account;

  const CurrentAccountMoney({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TransactionService.instance,
      builder: (context, child) {
        var total = TransactionService.instance.expenses
            .where((x) => x.transaction.account == account)
            .map((x) => x.signedMoney)
            .fold(account.initialMoney, (acc, x) => acc + x);

        return Text(total.toString());
      },
    );
  }
}
