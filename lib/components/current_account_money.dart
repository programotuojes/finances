import 'package:finances/account/models/account.dart';
import 'package:finances/transaction/service.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

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
        final expenses = TransactionService.instance.expenses
            .where((x) => x.transaction.account == account)
            .map((x) => x.signedMoney.amount)
            .fold(account.initialMoney.amount, (acc, x) => acc + x);

        final incoming = TransactionService.instance.transfers
            .where((x) => x.to == account)
            .map((x) => x.money.amount)
            .fold(expenses, (acc, x) => acc + x);

        final total = TransactionService.instance.transfers
            .where((x) => x.from == account)
            .map((x) => -x.money.amount)
            .fold(incoming, (acc, x) => acc + x);

        // TODO move this into a method in `Account`
        return Text(Money.fromFixedWithCurrency(total, account.currency).toString());
      },
    );
  }
}
