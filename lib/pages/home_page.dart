import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:finances/account/pages/list.dart';
import 'package:finances/account/service.dart';
import 'package:finances/automation/pages/list.dart';
import 'package:finances/budget/pages/list.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/cards/accounts_card.dart';
import 'package:finances/components/cards/balance_graph_card.dart';
import 'package:finances/components/cards/budget_card.dart';
import 'package:finances/components/cards/pie_chart_card/pie_chart_card.dart';
import 'package:finances/components/cards/recurring_transaction_card.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/importers/pages/importer_list_page.dart';
import 'package:finances/main.dart';
import 'package:finances/pages/first_run.dart';
import 'package:finances/pages/settings.dart';
import 'package:finances/recurring/pages/list.dart';
import 'package:finances/transaction/models/temp_combined.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/pages/edit_transaction.dart';
import 'package:finances/transaction/pages/edit_transfer.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:finances/utils/date.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:finances/utils/transaction_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:money2/money2.dart';
import 'package:quick_actions/quick_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final ExpandableFabPos pos = ExpandableFabPos.right;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  final _expandableFabKey = GlobalKey<ExpandableFabState>();

  Periodicity? _period;
  _LastPeriod? _lastPeriod = _LastPeriod.days30;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  var _historyGroupingPeriod = Periodicity.week;
  var index = 0;
  late TextStyle? _incomeStyle;
  late TextStyle? _expenseStyle;
  late TextStyle? _transferStyle;
  String? _currentQuickAction;

  @override
  void initState() {
    super.initState();

    _setupQuickActions();

    AppPaths.listenable.addListener(() {
      if (context.mounted) {
        setState(() {
          // Listening for changes in `main.dart` does not work
        });
      }
    });
  }

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

  void _setupQuickActions() {
    final supportsQuickActions = Platform.isAndroid;
    if (!supportsQuickActions) {
      return;
    }

    const newTransaction = 'new_transaction';
    const newTransfer = 'new_transfer';
    const quickActions = QuickActions();

    quickActions.initialize((shortcutType) async {
      logger.i('Handling $shortcutType quick action');

      if (_currentQuickAction == shortcutType) {
        // https://github.com/flutter/flutter/issues/131121
        return;
      }

      _currentQuickAction = shortcutType;

      Widget page;
      if (shortcutType == newTransaction) {
        page = const TransactionEditPage();
      } else if (shortcutType == newTransfer) {
        page = const EditTransferPage();
      } else {
        return;
      }

      await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      unawaited(SystemNavigator.pop()); // Cleaner exit screen
    });

    quickActions.setShortcutItems(const [
      ShortcutItem(type: newTransaction, localizedTitle: 'New transaction', icon: 'add'),
      ShortcutItem(type: newTransfer, localizedTitle: 'New transfer', icon: 'swap_horiz'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (AccountService.instance.accounts.isEmpty) {
      return const FirstRunPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: 'Open grouping and filtering options',
                icon: const Icon(Icons.filter_list_rounded),
              );
            },
          ),
        ],
      ),
      // TODO use a switch to not render both pages
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _expandableFabKey,
        distance: 56 + 24,
        type: ExpandableFabType.up,
        openCloseStackAlignment: Alignment.centerRight,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white70 : Colors.black54,
        ),
        openButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (context, onPressed, animationProgress) {
            return FloatingActionButton(
              onPressed: onPressed,
              child: const Icon(Icons.add),
            );
          },
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (context, onPressed, animationProgress) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Card.outlined(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('New transaction'),
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    onPressed?.call();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionEditPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),
        children: [
          Row(
            children: [
              const Card.outlined(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Transfer between accounts'),
                ),
              ),
              const SizedBox(width: 24),
              FloatingActionButton.small(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                heroTag: null,
                onPressed: () {
                  _expandableFabKey.currentState?.toggle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditTransferPage(),
                    ),
                  );
                },
                child: const Icon(Icons.swap_horiz),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Pages',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
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
                      CategoryService.instance.rootCategory,
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
            ListTile(
              title: const Text('Budgets'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetListPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Import'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImporterListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Reload database'),
              onTap: () async {
                await AppPaths.init();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        width: 480,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  width: 440,
                  child: _GroupByOptions(
                    period: _historyGroupingPeriod,
                    onSelected: (value) {
                      setState(() {
                        _historyGroupingPeriod = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 440,
                  child: _DateRangeFilter(
                    dateRange: _dateRange,
                    period: _period,
                    lastPeriod: _lastPeriod,
                    onChanged: (newRange, newPeriod, newLastPeriod) {
                      setState(() {
                        _dateRange = newRange;
                        _period = newPeriod;
                        _lastPeriod = newLastPeriod;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget home() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AccountsCard(),
          const SizedBox(height: 8),
          const BudgetCard(),
          const SizedBox(height: 8),
          PieChartCard(dateRange: _dateRange),
          const SizedBox(height: 8),
          BalanceGraphCard(range: _dateRange),
          const SizedBox(height: 8),
          const RecurringTransactionCard(),
          const SizedBox(height: 88),
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
            .where((expense) => expense.transaction.dateTime.isIn(_dateRange) && expense.matchesFilter(regex))
            .map((e) => TempCombined.fromExpense(e));

        final transfers = TransactionService.instance.transfers
            .where((transfer) => transfer.dateTime.isIn(_dateRange) && transfer.matchesFilter(regex))
            .map((e) => TempCombined.fromTransfer(e));

        final combined = [...expenses, ...transfers].sortedBy((element) => element.dateTime);

        var moneyPerPeriod = combined.groupFoldBy<String, Money>(
          (x) => x.dateTime.getGrouping(_historyGroupingPeriod).display,
          (acc, x) => (acc ?? zeroEur) + x.signedMoney,
        );

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: _SliverSearch(
                textController: _searchCtrl,
              ),
              floating: true,
            ),
            SliverVisibility(
              visible: combined.isEmpty,
              sliver: const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No entries found')),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: combined.isNotEmpty ? 88 : 0),
              sliver: SliverGroupedListView(
                elements: combined,
                order: GroupedListOrder.DESC,
                itemComparator: (a, b) => a.dateTime.compareTo(b.dateTime),
                groupBy: (x) => x.dateTime.getGrouping(_historyGroupingPeriod),
                groupSeparatorBuilder: (format) {
                  var dateGroup = format.display;
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 24, 4),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateGroup),
                            Text(moneyPerPeriod[dateGroup].toString()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemBuilder: (context, x) {
                  return ListTile(
                    title: Text(x.category.name),
                    leading: CategoryIconSquare(
                      icon: x.category.icon,
                      color: x.category.color,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          style: _textStyle(x.type),
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  _amountSymbol(x.type),
                                  color: _textStyle(x.type)?.color,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              TextSpan(text: x.money.toString()),
                            ],
                          ),
                        ),
                        Text(x.accountName),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(x.dateTime.toString().substring(0, 16)),
                        if (x.description != null && x.description!.isNotEmpty)
                          Text(
                            x.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    onTap: () {
                      if (x.type == TransactionType.transfer) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTransferPage(transfer: x.transfer),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionEditPage(transaction: x.transaction),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
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

const _searchPadding = 16.0;

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
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        textInputAction: TextInputAction.search,
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

enum _LastPeriod {
  days7(
    period: Periodicity.week,
    duration: Duration(days: 7),
    title: '7 days',
  ),
  days30(
    period: Periodicity.month,
    duration: Duration(days: 30),
    title: '30 days',
  ),
  weeks12(
    period: Periodicity.month,
    duration: Duration(days: 7 * 12),
    title: '12 weeks',
  ),
  months6(
    period: Periodicity.month,
    duration: Duration(days: 30 * 6),
    title: '6 months',
  ),
  year1(
    period: Periodicity.year,
    duration: Duration(days: 365),
    title: '1 year',
  ),
  allTime(
    period: Periodicity.year,
    duration: Duration.zero,
    title: 'All time',
  );

  final Periodicity period;
  final Duration duration;
  final String title;

  const _LastPeriod({
    required this.period,
    required this.duration,
    required this.title,
  });
}

class _GroupByOptions extends StatelessWidget {
  final Periodicity period;
  final void Function(Periodicity value) onSelected;

  const _GroupByOptions({
    required this.period,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Group by',
              textScaler: TextScaler.linear(1.8),
            ),
            const SizedBox(height: 16),
            SegmentedButton(
              style: const ButtonStyle(
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
              ),
              segments: const [
                ButtonSegment(
                  value: Periodicity.day,
                  label: Text('Day'),
                  icon: Icon(Icons.calendar_view_day),
                ),
                ButtonSegment(
                  value: Periodicity.week,
                  label: Text('Week'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: Periodicity.month,
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment(
                  value: Periodicity.year,
                  label: Text('Year'),
                  icon: Icon(Icons.calendar_today),
                ),
              ],
              selected: {period},
              onSelectionChanged: (newSelection) {
                onSelected(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  final DateTimeRange dateRange;
  final Periodicity? period;
  final _LastPeriod? lastPeriod;
  final void Function(DateTimeRange newRange, Periodicity? newPeriod, _LastPeriod? newLastPeriod) onChanged;

  const _DateRangeFilter({
    required this.dateRange,
    required this.period,
    required this.lastPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Text(
              'Filter dates',
              textScaler: TextScaler.linear(1.8),
            ),
            const SizedBox(height: 16),
            Text(
              '${dateRange.start.toString().substring(0, 10)} – ${dateRange.end.toString().substring(0, 10)}',
              textScaler: const TextScaler.linear(1.3),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                var newRange = await showDateRangePicker(
                  context: context,
                  firstDate: TransactionService.instance.transactions.last.dateTime,
                  lastDate: TransactionService.instance.transactions.first.dateTime,
                );

                if (newRange != null) {
                  onChanged(newRange, null, null);
                }
              },
              child: const Text('Edit'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            const Text(
              'View specific period',
              textScaler: TextScaler.linear(1.3),
            ),
            const SizedBox(height: 8),
            SegmentedButton(
              style: const ButtonStyle(
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
              ),
              segments: const [
                ButtonSegment(
                  value: Periodicity.month,
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment(
                  value: Periodicity.year,
                  label: Text('Year'),
                  icon: Icon(Icons.calendar_today),
                ),
              ],
              selected: {period},
              onSelectionChanged: (newSelection) {
                var newPeriod = newSelection.first;
                var now = DateTime.now();

                var start = switch (newPeriod) {
                  Periodicity.month => DateTime(now.year, now.month),
                  Periodicity.year => DateTime(now.year),
                  _ => throw ArgumentError('Other periodicity values not supported'),
                };
                var end = switch (newPeriod) {
                  Periodicity.month => DateUtils.addMonthsToMonthDate(start, 1).subtract(const Duration(days: 1)),
                  Periodicity.year => DateUtils.addMonthsToMonthDate(start, 12).subtract(const Duration(days: 1)),
                  _ => throw ArgumentError('Other periodicity values not supported'),
                };

                onChanged(
                  DateTimeRange(start: start, end: end),
                  newPeriod,
                  null,
                );
              },
            ),
            Visibility(
              visible: period != null,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        var previous = dateRange.start;
                        var range = switch (period) {
                          Periodicity.month => DateTimeRange(
                              start: DateTime(previous.year, previous.month - 1),
                              end: DateTime(previous.year, previous.month, 0),
                            ),
                          Periodicity.year => DateTimeRange(
                              start: DateTime(dateRange.start.year - 1, 1, 1),
                              end: DateTime(dateRange.start.year - 1, 12, 31),
                            ),
                          _ => throw ArgumentError('Other periodicity values not supported'),
                        };
                        onChanged(range, period, null);
                      },
                      icon: const Icon(Icons.navigate_before_rounded),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(period != null ? dateRange.start.getGrouping(period!).display : ''),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        var previous = dateRange.end;
                        var range = switch (period) {
                          Periodicity.month => DateTimeRange(
                              start: DateTime(previous.year, previous.month, previous.day + 1),
                              end: DateTime(previous.year, previous.month + 2, 0),
                            ),
                          Periodicity.year => DateTimeRange(
                              start: DateTime(dateRange.start.year + 1, 1, 1),
                              end: DateTime(dateRange.start.year + 1, 12, 31),
                            ),
                          _ => throw ArgumentError('Other periodicity values not supported'),
                        };
                        onChanged(range, period, null);
                      },
                      icon: const Icon(Icons.navigate_next_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            const Text(
              'View last',
              textScaler: TextScaler.linear(1.3),
            ),
            const SizedBox(height: 8),
            for (var x in _LastPeriod.values)
              RadioListTile(
                title: Text(x.title),
                value: x,
                groupValue: lastPeriod,
                onChanged: _setLastPeriod,
              ),
          ],
        ),
      ),
    );
  }

  void _setLastPeriod(_LastPeriod? value) {
    var newRange = dateRange;

    if (value != null) {
      var now = DateTime.now();

      if (value == _LastPeriod.allTime) {
        var start = TransactionService.instance.transactions.last.dateTime;
        newRange = DateTimeRange(start: start, end: now);
      } else {
        newRange = DateTimeRange(start: now.subtract(value.duration), end: now);
      }
    }

    onChanged(
      newRange,
      null,
      value,
    );
  }
}
