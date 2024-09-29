import 'package:finances/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_symbols_icons/symbols.dart';

const _iconSize = 40.0;

class AutocompleteListTile extends StatefulWidget {
  final EdgeInsets? listTilePadding;
  final TextEditingController controller;

  const AutocompleteListTile({
    super.key,
    this.listTilePadding,
    required this.controller,
  });

  @override
  State<AutocompleteListTile> createState() => _AutocompleteListTileState();
}

class _AutocompleteListTileState extends State<AutocompleteListTile> {
  final _textFieldKey = GlobalKey();
  final _focusNode = FocusNode();
  List<String> _lastDescriptions = [];
  String? _searching;
  double _textFieldWidth = 0;

  @override
  void initState() {
    super.initState();
    _updateWidth();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _updateWidth() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      final renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || _textFieldWidth == renderBox.size.width) {
        return;
      }
      setState(() {
        _textFieldWidth = renderBox.size.width;
      });
    });
  }

  void _ensureOptionsVisible() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_textFieldKey.currentContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        _textFieldKey.currentContext!,
        alignment: 0.4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: widget.listTilePadding,
      leading: const SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: Icon(Symbols.description),
      ),
      title: RawAutocomplete(
        textEditingController: widget.controller,
        focusNode: _focusNode,
        optionsBuilder: _search,
        optionsViewBuilder: (context, onSelected, options) {
          _ensureOptionsVisible();

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _updateWidth();
                  final width = _textFieldWidth - _iconSize;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width > 30 ? width : 30,
                      maxHeight: 160,
                    ),
                    // Not using a ListView because it does not render
                    // children outside the visible portion. This makes
                    // Scrollable.ensureVisible() not function for them.
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var index = 0; index < options.length; index++)
                            InkWell(
                              onTap: () => onSelected(options.elementAt(index)),
                              child: Builder(
                                builder: (context) {
                                  final highlight = AutocompleteHighlightedOption.of(context) == index;
                                  if (highlight) {
                                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                                      Scrollable.ensureVisible(
                                        context,
                                        alignment: 0.5,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    });
                                  }
                                  return Container(
                                    color: highlight ? Theme.of(context).focusColor : null,
                                    padding: const EdgeInsets.all(16),
                                    child: Text(options.elementAt(index)),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            key: _textFieldKey,
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (value) => onFieldSubmitted(),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Description',
            ),
          );
        },
        displayStringForOption: (value) => value,
      ),
    );
  }

  Future<List<String>> _search(TextEditingValue value) async {
    if (value.text.length < 3) {
      return const [];
    }

    _searching = value.text;
    final actualSearch = '%$_searching%';
    final dbDescriptions = await database.rawQuery(
      '''
      SELECT DISTINCT
        description
      FROM
        expenses
      WHERE
        description LIKE ? AND description != ""
      UNION
      SELECT DISTINCT
        description
      FROM
        transfers
      WHERE
        description LIKE ? AND description != ""
          ''',
      [actualSearch, actualSearch],
    );

    if (_searching == value.text) {
      // Only set the results if the search didn't change
      _lastDescriptions = dbDescriptions.map((x) => x['description'] as String).toList();
    }

    return _lastDescriptions;
  }
}
