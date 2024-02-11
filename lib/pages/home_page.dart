import 'package:finances/account/pages/list.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/expense/pages/add.dart';
import 'package:finances/expense/pages/edit.dart';
import 'package:finances/expense/service.dart';
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
              builder: (context) => const AddExpensePage(),
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
    return const Placeholder();
  }

  Widget history() {
    return ListenableBuilder(
      listenable: ExpenseService.instance,
      builder: (context, _) {
        if (ExpenseService.instance.expenses.isEmpty) {
          return const Center(child: Text('There are no expenses'));
        }
        return ListView(
          children: [
            for (var i in ExpenseService.instance.expenses)
              ListTile(
                title: Text(i.category.name),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.food_bank,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(i.account.name),
                    Text(i.amount.toString()),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.dateTime.toString().substring(0, 16)),
                    if (i.description != null) Text(i.description!),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditExpensePage(i),
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
