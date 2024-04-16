import 'package:file_selector/file_selector.dart';

class Attachment {
  XFile file;
  String? text;

  Attachment({
    required this.file,
    this.text,
  });
}
