import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finances/components/conditional_tooltip.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const _thumbnailHeight = 100.0;
const _deleteButtonOffset = 16.0;

class AttachmentRow extends StatefulWidget {
  final List<Attachment> attachments;
  final void Function(Attachment attachment)? onTap;
  final void Function(Attachment attachment)? onAutoCategorize;
  final bool Function()? allowOcr;

  const AttachmentRow({
    super.key,
    required this.attachments,
    this.onTap,
    this.onAutoCategorize,
    this.allowOcr,
  });

  @override
  State<AttachmentRow> createState() => _AttachmentRowState();
}

class _AttachmentRowState extends State<AttachmentRow> {
  Future<void> selectFile() async {
    const images = XTypeGroup(
      label: 'Images',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    final files = await openFiles(acceptedTypeGroups: [
      images,
    ]);

    if (files.isEmpty) {
      return;
    }

    setState(() {
      widget.attachments.addAll(files.map((x) => Attachment(file: x)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _deleteButtonOffset),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final attachment in widget.attachments)
              Thumb(
                key: ObjectKey(attachment),
                attachment: attachment,
                onTap: () {
                  widget.onTap?.call(attachment);
                },
                onAutoCategorize: widget.onAutoCategorize != null
                    ? () {
                        widget.onAutoCategorize?.call(attachment);
                      }
                    : null,
                allowOcr: widget.allowOcr,
                onRemove: () {
                  setState(() {
                    widget.attachments.remove(attachment);
                  });
                },
              ),
            Padding(
              padding: const EdgeInsets.only(top: _deleteButtonOffset),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    selectFile();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Icon(
                      Symbols.attach_file_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Thumb extends StatefulWidget {
  final Attachment attachment;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onAutoCategorize;

  /// Called before automatically categorizing.
  /// If the result is false, parsing won't be done.
  final bool Function()? allowOcr;

  const Thumb({
    super.key,
    required this.attachment,
    this.onRemove,
    this.onTap,
    this.onAutoCategorize,
    this.allowOcr,
  });

  @override
  State<Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<Thumb> {
  final _borderRadius = BorderRadius.circular(10);
  final _menuController = MenuController();
  final _parsedCtrl = TextEditingController();
  var _menuWasEnabled = false;
  var _processing = false;
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _disableContextMenu();
    _bytes = widget.attachment.bytes;
  }

  @override
  void dispose() {
    _reenableContextMenu();
    _parsedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        const SizedBox(
          width: 136,
          // TODO different height on different platforms
          height: _thumbnailHeight + _deleteButtonOffset,
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: _borderRadius,
          ),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              FutureBuilder<Uint8List>(
                future: _bytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Hero(
                      tag: widget.attachment,
                      child: ClipRRect(
                        borderRadius: _borderRadius,
                        child: Image.memory(
                          snapshot.requireData,
                          width: _thumbnailHeight,
                          height: _thumbnailHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return const SizedBox(
                    width: _thumbnailHeight,
                    height: _thumbnailHeight,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
              Visibility(
                visible: _processing,
                child: Positioned.fill(
                  child: Container(
                    color: brightness == Brightness.dark ? Colors.black38 : Colors.white38,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: !_processing ? widget.onTap : null,
                    onLongPress: !_processing
                        ? () {
                            _menuController.open();
                          }
                        : null,
                    onTapDown: _processing ? _handleTapDown : null,
                    onSecondaryTapDown: _processing ? _handleSecondaryTapDown : null,
                    child: MenuAnchor(
                      controller: _menuController,
                      menuChildren: [
                        ConditionalTooltip(
                          showTooltip: !_isOcrAvailable(),
                          message: 'OCR is only available on mobile and web',
                          child: MenuItemButton(
                            leadingIcon: const Icon(Symbols.manufacturing),
                            onPressed: _isOcrAvailable()
                                ? () async {
                                    var allowed = widget.allowOcr?.call();
                                    if (allowed == false) {
                                      return;
                                    }

                                    if (widget.attachment.text == null) {
                                      await _extractText();
                                    }

                                    widget.onAutoCategorize?.call();
                                  }
                                : null,
                            child: const Text('Auto categorize'),
                          ),
                        ),
                        ConditionalTooltip(
                          showTooltip: !_isOcrAvailable(),
                          message: 'OCR is only available on mobile and web',
                          child: MenuItemButton(
                            leadingIcon: const Icon(Symbols.document_scanner),
                            onPressed: _isOcrAvailable() ? _extractText : null,
                            child: const Text('Extract text'),
                          ),
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(Symbols.edit),
                          onPressed: () {
                            _editAttachmentText(context, widget.attachment);
                          },
                          child: const Text('Edit text'),
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(Symbols.close),
                          onPressed: widget.onRemove,
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: ElevatedButton(
            onPressed: widget.onRemove,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const CircleBorder(),
              ),
            ),
            child: const Icon(Icons.clear),
          ),
        ),
      ],
    );
  }

  Future<void> _extractText() async {
    setState(() {
      _processing = true;
    });

    try {
      await widget.attachment.extractText();
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  bool _isOcrAvailable() {
    return kIsWeb || Platform.isAndroid || Platform.isIOS;
  }

  void _handleSecondaryTapDown(TapDownDetails details) {
    _menuController.open(position: details.localPosition);
  }

  void _handleTapDown(TapDownDetails details) {
    if (_menuController.isOpen) {
      _menuController.close();
      return;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Don't open the menu on these platforms with a Ctrl-tap (or a tap)
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // Only open the menu on these platforms if the control button is down when the tap occurs
        var keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
        if (keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            keysPressed.contains(LogicalKeyboardKey.controlRight)) {
          _menuController.open(position: details.localPosition);
        }
    }
  }

  Future<void> _disableContextMenu() async {
    if (!kIsWeb) {
      // Does nothing on non-web platforms.
      return;
    }
    _menuWasEnabled = BrowserContextMenu.enabled;
    if (_menuWasEnabled) {
      await BrowserContextMenu.disableContextMenu();
    }
  }

  void _reenableContextMenu() {
    if (!kIsWeb) {
      // Does nothing on non-web platforms
      return;
    }
    if (_menuWasEnabled && !BrowserContextMenu.enabled) {
      BrowserContextMenu.enableContextMenu();
    }
  }

  Future<void> _editAttachmentText(
    BuildContext context,
    Attachment attachment,
  ) async {
    _parsedCtrl.text = attachment.text ?? '';

    var saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attachment text'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 700,
              maxHeight: 400,
            ),
            child: TextField(
              controller: _parsedCtrl,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      attachment.text = _parsedCtrl.text;
    }
  }
}
