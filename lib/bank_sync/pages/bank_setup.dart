import 'package:finances/bank_sync/models/go_cardless_token.dart';
import 'package:finances/bank_sync/models/institution.dart';
import 'package:finances/bank_sync/services/go_cardless_service.dart';
import 'package:finances/components/go_cardless_error_container.dart';
import 'package:finances/components/hidden_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher.dart';

final _secretsUri = Uri.https(
  'bankaccountdata.gocardless.com',
  '/user-secrets/',
);

class BankSetupPage extends StatefulWidget {
  const BankSetupPage({super.key});

  @override
  State<BankSetupPage> createState() => _BankSetupPageState();
}

class _BankSetupPageState extends State<BankSetupPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bank sync setup'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Secrets',
                icon: ListenableBuilder(
                  listenable: GoCardlessToken.instance.error,
                  builder: (context, child) {
                    var error = GoCardlessToken.instance.error.value;
                    return Badge(
                      isLabelVisible: error != null,
                      smallSize: 10,
                      offset: const Offset(20, -4),
                      label: const Text('!'),
                      child: const Icon(Icons.password),
                    );
                  },
                ),
              ),
              Tab(
                text: 'Banks',
                icon: ListenableBuilder(
                    listenable: GoCardlessSerivce.instance,
                    builder: (context, child) {
                      var bank = GoCardlessSerivce.instance.institution;
                      return Badge(
                        isLabelVisible: bank == null,
                        smallSize: 10,
                        offset: const Offset(20, -4),
                        label: const Text('!'),
                        child: const Icon(Icons.account_balance_outlined),
                      );
                    }),
              ),
              Tab(
                text: 'Agreements',
                icon: ListenableBuilder(
                    listenable: GoCardlessSerivce.instance,
                    builder: (context, child) {
                      var agreement = GoCardlessSerivce.instance.endUserAgreement;
                      return Badge(
                        isLabelVisible: agreement == null,
                        smallSize: 10,
                        offset: const Offset(20, -4),
                        label: const Text('!'),
                        child: const Icon(Icons.description_outlined),
                      );
                    }),
              ),
              Tab(
                text: 'Requisitions',
                icon: ListenableBuilder(
                    listenable: GoCardlessSerivce.instance,
                    builder: (context, child) {
                      var requisition = GoCardlessSerivce.instance.requisition;
                      return Badge(
                        isLabelVisible: requisition == null,
                        smallSize: 10,
                        offset: const Offset(20, -4),
                        label: const Text('!'),
                        child: const Icon(Icons.link),
                      );
                    }),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SecretsTab(),
            _BanksTab(),
            _AgreementsTab(),
            _RequisitionsTab(),
          ],
        ),
      ),
    );
  }
}

class _SecretsTab extends StatefulWidget {
  const _SecretsTab();

  @override
  State<_SecretsTab> createState() => __SecretsTabState();
}

class __SecretsTabState extends State<_SecretsTab> with AutomaticKeepAliveClientMixin {
  final _idCtrl = TextEditingController(text: GoCardlessToken.instance.secretId);
  final _keyCtrl = TextEditingController(text: GoCardlessToken.instance.secretKey);
  late bool _disableSave = _idCtrl.text.isEmpty || _keyCtrl.text.isEmpty;

  @override
  void initState() {
    super.initState();
    Listenable.merge([_idCtrl, _keyCtrl]).addListener(() {
      var isEmpty = _idCtrl.text.isEmpty || _keyCtrl.text.isEmpty;

      if (_disableSave != isEmpty) {
        setState(() {
          _disableSave = isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          GoCardlessErrorContainer(listenable: GoCardlessToken.instance.error),
          Padding(
            padding: const EdgeInsets.all(16),
            child: HiddenTextField(
              ctrl: _idCtrl,
              label: 'Secret ID',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: HiddenTextField(
              ctrl: _keyCtrl,
              label: 'Secret key',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    var launched = await launchUrl(_secretsUri);
                    if (!launched && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Failed to open the browser'),
                        action: SnackBarAction(
                          label: 'Copy URL',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: _secretsUri.toString(),
                            ));
                          },
                        ),
                      ));
                    }
                  },
                  label: const Text('Open GoCardless user secrets'),
                  icon: const Icon(Symbols.open_in_new_rounded),
                ),
                FilledButton.icon(
                  onPressed: !_disableSave
                      ? () async {
                          setState(() {
                            _disableSave = true;
                          });
                          try {
                            await GoCardlessToken.instance.setSecrets(_idCtrl.text, _keyCtrl.text);
                          } finally {
                            setState(() {
                              _disableSave = false;
                            });
                          }
                        }
                      : null,
                  icon: const Icon(Symbols.save_rounded),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BanksTab extends StatefulWidget {
  const _BanksTab();

  @override
  State<_BanksTab> createState() => _BanksTabState();
}

class _BanksTabState extends State<_BanksTab> with AutomaticKeepAliveClientMixin {
  final _countryCtrl = TextEditingController(text: 'LT');
  final _searchCtrl = TextEditingController();
  var _filteredBanks = GoCardlessSerivce.instance.institutions;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        var searchStr = _searchCtrl.text.toLowerCase();
        _filteredBanks = GoCardlessSerivce.instance.institutions
            .where((element) => element.name.toLowerCase().contains(searchStr))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const gap = SizedBox(width: 16, height: 16);

    return Column(
      children: [
        GoCardlessErrorContainer(listenable: GoCardlessSerivce.instance.bankError),
        Padding(
          padding: const EdgeInsets.all(24),
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.headlineMedium,
            child: ListenableBuilder(
              listenable: GoCardlessSerivce.instance,
              builder: (context, child) {
                var bank = GoCardlessSerivce.instance.institution;

                if (bank == null) {
                  return const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_rounded),
                      Text(' Select a bank from the list below'),
                    ],
                  );
                }

                return Text('Selected ${bank.name}');
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              gap,
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _countryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                  ),
                ),
              ),
              gap,
              IconButton.filled(
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  try {
                    await GoCardlessSerivce.instance.getInstitutions(countryCode: _countryCtrl.text);
                  } finally {
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      _filteredBanks = GoCardlessSerivce.instance.institutions;
                      _loading = false;
                    });
                  }
                },
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        gap,
        Visibility(
          visible: _filteredBanks.isEmpty,
          child: const Expanded(
            child: Center(
              child: Text('No banks found'),
            ),
          ),
        ),
        Visibility(
          visible: _filteredBanks.isNotEmpty,
          child: Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      itemCount: _filteredBanks.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 200,
                      ),
                      itemBuilder: (context, index) => _BankCard(
                        institution: _filteredBanks[index],
                        onTap: () {
                          _searchCtrl.clear();
                        },
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BankCard extends StatelessWidget {
  final Institution institution;
  final VoidCallback onTap;

  const _BankCard({
    required this.institution,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var image = Image.network(
      institution.logo,
      fit: BoxFit.fitHeight,
      height: 100,
    );

    return ImagePixels(
      imageProvider: image.image,
      builder: (context, img) {
        // TODO cache calculated color to avoid flicker when searching
        var (backgroundColor, textColor) = _getNonTransparentColor(context, img);

        return Card(
          clipBehavior: Clip.hardEdge,
          color: backgroundColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: image,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
                    child: Text(
                      textAlign: TextAlign.center,
                      institution.name,
                      style: TextStyle(
                        color: textColor,
                        height: 1.1,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await GoCardlessSerivce.instance.setInstitution(institution);
                      onTap();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  (Color? background, Color? text) _getNonTransparentColor(BuildContext context, ImgDetails img) {
    if (img.width == null || img.height == null) {
      return (null, null);
    }

    var brightness = MediaQuery.of(context).platformBrightness;
    var mid = img.width! ~/ 2;

    for (int i = 0; i < img.height!; i++) {
      var color = img.pixelColorAt!(i, mid);

      if (color.alpha != 255 || color.computeLuminance() > 0.8) {
        continue;
      }

      var background = switch (brightness) {
        Brightness.light => _lighten(color),
        Brightness.dark => _darken(color),
      };
      var text = background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      return (background, text);
    }

    return (Colors.grey[200]!, Colors.black);
  }

  Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);

    return hsl
        .withSaturation((hsl.saturation - 0.2).clamp(0.4, 1))
        .withLightness((hsl.lightness - 0.2).clamp(0.2, 1))
        .toColor();
  }

  Color _lighten(Color color) {
    final hsl = HSLColor.fromColor(color);

    return hsl
        .withSaturation((hsl.saturation - 0.15).clamp(0, 0.7))
        .withLightness((hsl.lightness + 0.25).clamp(0, 0.9))
        .toColor();
  }
}

class _AgreementsTab extends StatelessWidget {
  const _AgreementsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListenableBuilder(
            listenable: GoCardlessSerivce.instance,
            builder: (context, child) {
              var agreement = GoCardlessSerivce.instance.endUserAgreement;

              if (agreement == null) {
                return const SizedBox(height: 24);
              }

              var validUntil = agreement.validUntil.toString().substring(0, 10);

              return Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Valid until $validUntil'),
                      Text('• Grants access to the last ${agreement.maxHistorical.inDays} days'),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(agreement.balanceAccess ? Icons.check : Icons.close),
                          const Text(' Balance'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(agreement.detailsAccess ? Icons.check : Icons.close),
                          const Text(' Details'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(agreement.transactionsAccess ? Icons.check : Icons.close),
                          const Text(' Transactions'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          FilledButton.icon(
            onPressed: () async {
              await GoCardlessSerivce.instance.createEndUserAgreement();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _RequisitionsTab extends StatelessWidget {
  const _RequisitionsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListenableBuilder(
            listenable: GoCardlessSerivce.instance,
            builder: (context, child) {
              var requisition = GoCardlessSerivce.instance.requisition;

              if (requisition == null) {
                return const SizedBox(height: 24);
              }

              var account = requisition.accounts.length == 1 ? 'account' : 'accounts';

              return Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${requisition.status}'),
                      Text('${requisition.accounts.length} $account'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 100),
                          TextButton(
                            onPressed: () async {
                              await GoCardlessSerivce.instance.getRequisition();
                            },
                            child: const Text('Refresh'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await GoCardlessSerivce.instance.deleteRequisition();
                            },
                            child: const Text('Delete'),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          FilledButton.icon(
            onPressed: () async {
              await GoCardlessSerivce.instance.linkWithBank();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
