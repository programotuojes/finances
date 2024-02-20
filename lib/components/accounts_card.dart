import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:flutter/material.dart';

class AccountsCard extends StatelessWidget {
  const AccountsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AccountService.instance,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Accounts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i in AccountService.instance.accounts)
                      smallCard(context, i),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget smallCard(BuildContext context, Account account) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(
          style: AccountService.instance.selectedFilter == account
              ? BorderStyle.solid
              : BorderStyle.none,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        onTap: () {
          AccountService.instance.filterBy(account);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(account.name),
            Text(account.balance.toString()),
          ],
        ),
      ),
    );
  }
}
