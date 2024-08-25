import 'package:finances/importers/wallet_db/pages/first.dart';
import 'package:flutter/material.dart';

class ImporterListPage extends StatelessWidget {
  const ImporterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('From Wallet by BudgetBakers'),
            subtitle: const Text('Database files'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletDbFirstPage()),
              );
            },
          )
        ],
      ),
    );
  }
}
