import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

class Attachment {
  XFile file;
  String? text;
  Uint8List? _bytes;

  Future<Uint8List> get bytes async {
    if (_bytes != null) {
      return _bytes!;
    }

    _bytes = await file.readAsBytes();
    return _bytes!;
  }

  Attachment({
    required this.file,
    this.text,
  });
}
