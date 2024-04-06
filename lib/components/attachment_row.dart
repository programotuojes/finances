import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mime/mime.dart';
import 'package:thumbnailer/thumbnailer.dart';

const _thumbnailHeight = 100.0;
const _deleteButtonOffset = 16.0;

class AttachmentRow extends StatefulWidget {
  final List<XFile> attachments;
  const AttachmentRow({super.key, required this.attachments});

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
      widget.attachments.addAll(files);
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
            final Uint8List resolvedData = await getData();
            return Center(
              child: Image.memory(
                resolvedData,
                errorBuilder: (context, obj, stacktrace) => const Placeholder(),
                fit: BoxFit.cover,
                semanticLabel: name,
                width: widgetSize,
                height: widgetSize,
                filterQuality: FilterQuality.none,
              ),
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
                child: Ink(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // color: Theme.of(context).colorScheme.secondary,
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

class Thumb extends StatelessWidget {
  final XFile attachment;
  final VoidCallback? onRemove;

  const Thumb({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        const SizedBox(
          width: 136,
          height: _thumbnailHeight + _deleteButtonOffset,
        ),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Thumbnail(
            key: Key(attachment.path),
            mimeType: lookupMimeType(attachment.path) ??
                attachment.mimeType ?? // For web (probably)
                'default',
            widgetSize: 100,
            dataResolver: attachment.readAsBytes,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: ElevatedButton(
            onPressed: onRemove,
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
}
