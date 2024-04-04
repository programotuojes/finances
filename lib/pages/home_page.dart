import 'package:finances/account/pages/list.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/accounts_card.dart';
import 'package:finances/components/balance_history.dart';
import 'package:finances/transaction/pages/edit.dart';
import 'package:finances/transaction/service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: [
        home(),
        history(),
      ][index],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            this.index = index;
          });
        },
        selectedIndex: index,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.receipt_long),
            icon: Icon(Icons.receipt_long_outlined),
            label: 'History',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditTransactionPage(),
            ),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Text('Finances'),
            ),
            ListTile(
              title: const Text('Accounts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Categories'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryListPage(
                      CategoryService.instance.root,
                      isForEditing: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget home() {
    return Column(
      children: [
        const AccountsCard(),
        BalanceGraphCard(),
      ],
    );
  }

  Widget history() {
    return ListenableBuilder(
      listenable: TransactionService.instance,
      builder: (context, _) {
        if (TransactionService.instance.transactions.isEmpty) {
          return const Center(child: Text('There are no transactions'));
        }
        return ListView(
          children: [
            for (var expense in TransactionService.instance.expenses)
              ListTile(
                title: Text(expense.category.name),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Icon(
                    expense.category.icon,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(expense.transaction.account.name),
                    Text(expense.money.toString()),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.transaction.dateTime
                        .toString()
                        .substring(0, 16)),
                    if (expense.description != null) Text(expense.description!),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTransactionPage(
                        transaction: expense.transaction,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
