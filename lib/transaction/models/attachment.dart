import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:file_selector/file_selector.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/main.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:finances/utils/money.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:money2/money2.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

List<Rect> boundingBoxes = [];

class Attachment {
  int? id;
  int? transactionId;
  XFile file;
  String? text;
  Uint8List? _bytes;

  Attachment({
    this.id,
    this.transactionId,
    required this.file,
    this.text,
  });

  Future<Uint8List> get bytes async {
    if (_bytes != null) {
      return _bytes!;
    }

    _bytes = await file.readAsBytes();
    return _bytes!;
  }

  Stream<({String text, Money money})> extractLineItems() async* {
    if (text == null) {
      return;
    }

    var fromLidl = lidlNameVariants.any((lidlString) => text!.contains(lidlString));

    if (fromLidl) {
      for (var match in lidlRegex.allMatches(text!)) {
        var lineItem = _parseLineItem(match);
        if (lineItem != null) {
          yield lineItem;
        }
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> extractText() async {
    var scaledImagePath = p.join(Directory.systemTemp.path, 'scaled');

    // This is >3 times faster than using the `image` lib
    await FcNativeImageResize().resizeFile(
      srcFile: file.path,
      srcFileUri: true,
      destFile: scaledImagePath,
      width: 550,
      height: 10000,
      keepAspectRatio: true,
      format: 'png',
    );

    var inputImage = InputImage.fromFilePath(scaledImagePath);
    var textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    var recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    var lines = recognizedText.blocks.expand((element) => element.lines).sorted(_lineComparer);
    boundingBoxes = lines.map((e) => e.boundingBox).toList();

    if (lines.isEmpty) {
      logger.w('Did not extract any text from the image');
      return;
    }

    var stringBuffer = StringBuffer();
    stringBuffer.write(lines[0].text);

    for (var i = 1; i < lines.length; i++) {
      stringBuffer
        ..write(_getLineSeparator(lines[i - 1], lines[i]))
        ..write(lines[i].text);
    }

    var extractedText = stringBuffer.toString();
    logger.i(extractedText);
    text = extractedText;
    await File(scaledImagePath).delete();
  }

  Map<String, Object?> toMap() {
    return {
      'path': p.basename(file.path),
      'attachmentText': text,
      'transactionId': transactionId,
    };
  }

  String _getLineSeparator(TextLine t1, TextLine t2) {
    var diffOfTops = t1.boundingBox.top - t2.boundingBox.top;
    var height = t1.boundingBox.height + t2.boundingBox.height;

    if (diffOfTops.abs() > height * 0.23) {
      return '\n';
    }

    return ' ';
  }

  int _lineComparer(TextLine t1, TextLine t2) {
    var diffOfTops = t1.boundingBox.top - t2.boundingBox.top;
    var diffOfLefts = t1.boundingBox.left - t2.boundingBox.left;
    var avgHeight = (t1.boundingBox.height + t2.boundingBox.height) / 2;

    if (diffOfTops.abs() > avgHeight * 0.35) {
      return diffOfTops.toInt();
    }

    return diffOfLefts.toInt();
  }

  ({String text, Money money})? _parseLineItem(RegExpMatch match) {
    var name = match.group(1);
    if (name == null) {
      return null;
    }

    var money = match.group(2)?.toMoney();
    if (money == null) {
      return null;
    }

    var discount = match.group(3)?.toMoney();
    if (discount != null) {
      money -= discount;
    }

    return (text: name, money: money);
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table attachments (
        id integer primary key autoincrement,
        path text not null,
        attachmentText text,
        transactionId integer not null,
        foreign key (transactionId) references transactions(id) on delete cascade
      )
    ''');
  }

  factory Attachment.fromMap(Map<String, Object?> map) {
    return Attachment(
      id: map['id'] as int,
      file: XFile(p.join(AppPaths.attachments, map['path'] as String)),
      text: map['attachmentText'] as String?,
      transactionId: map['transactionId'] as int,
    );
  }
}
