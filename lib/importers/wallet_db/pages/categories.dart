import 'package:finances/category/models/category.dart';
import 'package:finances/category/pages/list.dart';
import 'package:finances/category/service.dart';
import 'package:finances/importers/wallet_db/models.dart' as wallet_db;
import 'package:finances/transaction/components/category_list_tile.dart';
import 'package:flutter/material.dart';

class WalletDbCategoryPage extends StatefulWidget {
  final List<wallet_db.Category> walletCategories;

  const WalletDbCategoryPage({
    super.key,
    required this.walletCategories,
  });

  @override
  State<WalletDbCategoryPage> createState() => _WalletDbCategoryPageState();
}

class _WalletDbCategoryPageState extends State<WalletDbCategoryPage> {
  final Map<wallet_db.Category, CategoryModel> _categoryMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map categories'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Wallet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Local',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            for (final walletCategory in widget.walletCategories)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(walletCategory.name),
                    ),
                  ),
                  const Icon(Icons.arrow_right),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: _categoryMap[walletCategory] == null
                          ? ListTile(
                              onTap: () async {
                                final selectedCategory = await Navigator.push<CategoryModel>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryListPage(CategoryService.instance.rootCategory),
                                  ),
                                );
                                if (selectedCategory != null && mounted) {
                                  setState(() {
                                    _categoryMap[walletCategory] = selectedCategory;
                                  });
                                }
                              },
                              title: const Text('Select a category'),
                            )
                          : CategoryListTile(
                              initialCategory: _categoryMap[walletCategory]!,
                              onCategorySelected: (selected) {
                                setState(() {
                                  _categoryMap[walletCategory] = selected;
                                });
                              },
                              morePadding: false,
                            ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const WalletDbCategoryPage()),
                // );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
