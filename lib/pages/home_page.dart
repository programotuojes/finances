import 'package:finances/account/pages/list.dart';
import 'package:finances/automation/pages/list.dart';
import 'package:finances/bank_sync/pages/bank_setup.dart';
import 'package:finances/bank_sync/pages/settings.dart';
import 'package:finances/bank_sync/pages/transaction_list.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/accounts_card.dart';
import 'package:finances/components/balance_graph_card.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/components/common_values.dart';
import 'package:finances/components/recurring_transaction_card.dart';
import 'package:finances/recurring/pages/list.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/pages/edit.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/transaction_theme.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  var index = 0;
  late TextStyle? _incomeStyle;
  late TextStyle? _expenseStyle;
  late TextStyle? _transferStyle;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var theme = TransactionTheme(context);
    _incomeStyle = theme.createTextStyle(context, TransactionType.income);
    _expenseStyle = theme.createTextStyle(context, TransactionType.expense);
    _transferStyle = theme.createTextStyle(context, TransactionType.transfer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
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
        heroTag: 'home',
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
            ListTile(
              title: const Text('Recurring transactions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecurringListPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Automation'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AutomationListPage(),
                  ),
                );
              },
            ),
            const Divider(),
            const ListTile(
              subtitle: Text('Bank sync'),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded),
              title: const Text('Secrets'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankSetupPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: const Text('Transactions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankTransactionList(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankSyncSettings(),
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
    return const SingleChildScrollView(
      padding: scaffoldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountsCard(),
          BalanceGraphCard(),
          RecurringTransactionCard(),
          SizedBox(height: 88),
        ],
      ),
    );
  }

  Widget history() {
    return ListenableBuilder(
      listenable: Listenable.merge([TransactionService.instance, _searchCtrl]),
      builder: (context, child) {
        var regex = RegExp(_searchCtrl.text, caseSensitive: false);
        var expenses = TransactionService.instance.expenses
            .where((expense) =>
                expense.description?.contains(regex) == true ||
                expense.category.name.contains(regex) ||
                expense.transaction.attachments.any((attachment) => attachment.text?.contains(regex) == true))
            .toList();

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: _SliverSearch(
                textController: _searchCtrl,
              ),
              floating: true,
            ),
            SliverVisibility(
              visible: expenses.isEmpty,
              sliver: const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No expenses found')),
              ),
            ),
            SliverList.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                var expense = expenses[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: expenses.length - 1 == index ? 88 : 0),
                  child: ListTile(
                    title: Text(expense.category.name),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: CategoryIcon(icon: expense.category.icon),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          style: _textStyle(expense.transaction.type),
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  _amountSymbol(expense.transaction.type),
                                  color: _textStyle(expense.transaction.type)?.color,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              TextSpan(text: expense.money.toString()),
                            ],
                          ),
                        ),
                        Text(expense.transaction.account.name),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.transaction.dateTime.toString().substring(0, 16)),
                        if (expense.description != null)
                          Text(
                            expense.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                );
              },
            ),
          ],
        );
      },
    );
  }

  TextStyle? _textStyle(TransactionType type) {
    return switch (type) {
      TransactionType.income => _incomeStyle,
      TransactionType.expense => _expenseStyle,
      TransactionType.transfer => _transferStyle,
    };
  }

  IconData? _amountSymbol(TransactionType type) {
    return switch (type) {
      TransactionType.income => Icons.arrow_drop_up_rounded,
      TransactionType.expense => Icons.arrow_drop_down_rounded,
      TransactionType.transfer => null,
    };
  }
}

const _searchPadding = 8.0;

class _SliverSearch extends SliverPersistentHeaderDelegate {
  final TextEditingController textController;

  const _SliverSearch({
    required this.textController,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _MySearch(
      textController: textController,
    );
  }

  @override
  double get maxExtent => 56 + _searchPadding * 2;

  @override
  double get minExtent => 56 + _searchPadding * 2;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _MySearch extends StatelessWidget {
  final TextEditingController textController;

  const _MySearch({required this.textController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_searchPadding),
      child: SearchBar(
        controller: textController,
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        leading: const Icon(Icons.search),
        trailing: [
          ListenableBuilder(
            listenable: textController,
            child: IconButton(
              onPressed: () {
                textController.clear();
              },
              icon: const Icon(Icons.close),
            ),
            builder: (context, child) {
              return Visibility(
                visible: textController.text.isNotEmpty,
                child: child!,
              );
            },
          ),
        ],
      ),
    );
  }
}
