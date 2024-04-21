import 'package:finances/account/pages/edit.dart';
import 'package:finances/account/service.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/components/current_account_money.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit accounts'),
      ),
      body: ListenableBuilder(
        listenable: AccountService.instance,
        builder: (context, _) => ListView(
          children: [
            for (var i in AccountService.instance.accounts)
              ListTile(
                title: Text(i.name),
                leading: const CategoryIcon(icon: Symbols.account_balance),
                subtitle: CurrentAccountMoney(account: i),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountEditPage(account: i),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountEditPage(),
            ),
          );
        },
      ),
    );
  }
}
