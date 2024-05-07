import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/components/current_account_money.dart';
import 'package:finances/components/home_card.dart';
import 'package:flutter/material.dart';

class AccountsCard extends StatelessWidget {
  const AccountsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: 'Accounts',
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: ListenableBuilder(
        listenable: AccountService.instance,
        builder: (context, child) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i in AccountService.instance.accounts) smallCard(context, i),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget smallCard(BuildContext context, Account account) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(
          style: AccountService.instance.filter == account ? BorderStyle.solid : BorderStyle.none,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: SizedBox(
        height: 60,
        width: 120,
        child: InkWell(
          onTap: () {
            AccountService.instance.filterBy(account);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(account.name), CurrentAccountMoney(account: account)],
          ),
        ),
      ),
    );
  }
}
