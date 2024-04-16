import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/components/conditional_tooltip.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mime/mime.dart';
import 'package:thumbnailer/thumbnailer.dart';

const _thumbnailHeight = 100.0;
const _deleteButtonOffset = 16.0;

class AttachmentRow extends StatefulWidget {
  final List<Attachment> attachments;
  final void Function(Attachment attachment)? onTap;
  final void Function(Attachment attachment)? onOcr;
  final bool Function()? allowOcr;

  const AttachmentRow({
    super.key,
    required this.attachments,
    this.onTap,
    this.onOcr,
    this.allowOcr,
  });

  @override
  State<AttachmentRow> createState() => _AttachmentRowState();
}

class _AttachmentRowState extends State<AttachmentRow> {
  Future<void> selectFile() async {
    const jpgsTypeGroup = XTypeGroup(
      label: 'Images',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    const pdfTypeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: ['pdf'],
    );
    final files = await openFiles(acceptedTypeGroups: [
      jpgsTypeGroup,
      pdfTypeGroup,
    ]);

    if (files.isEmpty) {
      return;
    }

    setState(() {
      widget.attachments.addAll(files.map((x) => Attachment(file: x)));
    });
  }

  @override
  void initState() {
    super.initState();
    Thumbnailer.addCustomGenerationStrategies(
      <String, GenerationStrategyFunction>{
        'image': (
          String? name,
          String mimeType,
          int? dataSize,
          DataResolvingFunction getData,
          double widgetSize,
          WidgetDecoration? widgetDecoration,
        ) async {
          try {
            return Image.memory(
              await getData(),
              fit: BoxFit.cover,
              semanticLabel: name,
              width: widgetSize,
              height: widgetSize,
              filterQuality: FilterQuality.none,
            );
          } catch (e) {
            return const Placeholder();
          }
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 35),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 24),
            for (final attachment in widget.attachments)
              Thumb(
                attachment: attachment,
                onTap: widget.onTap != null
                    ? () {
                        widget.onTap?.call(attachment);
                      }
                    : null,
                onOcr: widget.onOcr != null
                    ? () {
                        widget.onOcr?.call(attachment);
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
            const SizedBox(width: 24),
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
  final VoidCallback? onOcr;

  /// Called before automatically categorizing.
  /// If the result is false, parsing won't be done.
  final bool Function()? allowOcr;

  const Thumb({
    super.key,
    required this.attachment,
    this.onRemove,
    this.onTap,
    this.onOcr,
    this.allowOcr,
  });

  @override
  State<Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<Thumb> {
  final _menuController = MenuController();
  final _parsedCtrl = TextEditingController();
  var _menuWasEnabled = false;
  var _processing = false;

  @override
  void initState() {
    super.initState();
    _disableContextMenu();
  }

  @override
  void dispose() {
    _reenableContextMenu();
    _parsedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        const SizedBox(
          width: 136,
          // TODO different height on different platforms
          height: _thumbnailHeight + _deleteButtonOffset,
        ),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Thumbnail(
                key: Key(widget.attachment.file.path),
                mimeType: lookupMimeType(
                        widget.attachment.file.path) ?? // For desktop
                    widget.attachment.file.mimeType ?? // For mobile and web
                    'default',
                widgetSize: 100,
                dataResolver: widget.attachment.file.readAsBytes,
              ),
              Visibility(
                visible: _processing,
                child: const CircularProgressIndicator(),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onLongPress: () {
                      _menuController.open();
                    },
                    onTapDown: _handleTapDown,
                    onSecondaryTapDown: _handleSecondaryTapDown,
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
                                    if (allowed != null && !allowed) {
                                      return;
                                    }

                                    var text = widget.attachment.text;
                                    if (text == null) {
                                      setState(() {
                                        _processing = true;
                                      });
                                      var extracted =
                                          await extractText(widget.attachment);
                                      setState(() {
                                        _processing = false;
                                      });
                                      text = extracted;
                                      widget.attachment.text = extracted;
                                    }
                                    widget.onOcr?.call();
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
                            onPressed: _isOcrAvailable()
                                ? () async {
                                    setState(() {
                                      _processing = true;
                                    });
                                    var text =
                                        await extractText(widget.attachment);
                                    widget.attachment.text = text;
                                    setState(() {
                                      _processing = false;
                                    });
                                  }
                                : null,
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
          content: SizedBox(
            height: 400,
            child: TextField(
              controller: _parsedCtrl,
              expands: true,
              maxLines: null,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
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
