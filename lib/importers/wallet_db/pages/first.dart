import 'package:finances/importers/wallet_db/models.dart';
import 'package:finances/importers/wallet_db/pages/accounts.dart';
import 'package:flutter/material.dart';

class WalletDbFirstPage extends StatelessWidget {
  const WalletDbFirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Wallet (database files)'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text('Record database'),
              subtitle: const Text('/home/gustas/...'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Other database'),
              subtitle: const Text('/home/gustas/...'),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletDbAccountPage(
                      walletAccounts: [
                        Account(
                          id: 'kek',
                          archived: false,
                          initAmount: 100,
                          name: 'Test',
                        ),
                        Account(
                          id: 'ayay',
                          archived: false,
                          initAmount: 200,
                          name: 'Neste',
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
