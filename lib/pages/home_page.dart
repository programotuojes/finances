import 'package:finances/account/pages/list.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/expense/pages/add.dart';
import 'package:finances/expense/service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
          listenable: ExpenseService.instance,
          builder: (context, _) {
            return ListView(
              children: [
                for (var i in ExpenseService.instance.expenses)
                  ListTile(
                    title: Text(i.category.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i.description != null) Text(i.description!),
                        Text(i.amount.toString()),
                        Text(i.account.name),
                        Text(i.dateTime.toString()),
                      ],
                    ),
                  ),
              ],
            );
          }),
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
}
