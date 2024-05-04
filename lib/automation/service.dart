import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:finances/automation/models/automation.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/main.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:money2/money2.dart';
import 'package:path/path.dart' as p;

Iterable<Automation> _seedData() sync* {
  var groceries = CategoryService.instance.findById(CategoryIds.groceries);
  if (groceries != null) {
    yield Automation(
      name: 'Groceries',
      category: groceries,
      rules: [
        Rule(creditorName: RegExp('MAXIMA')),
        Rule(creditorName: RegExp('RIMI')),
        Rule(creditorName: RegExp('LIDL')),
      ],
    );
  }

  var music = CategoryService.instance.findById(CategoryIds.music);
  if (music != null) {
    yield Automation(
      name: 'Spotify',
      category: music,
      rules: [
        Rule(remittanceInfo: RegExp('Muzikinės paslaugos')),
        Rule(creditorName: RegExp('SPOTIFY')),
      ],
    );
  }

  var fuel = CategoryService.instance.findById(CategoryIds.fuel);
  if (fuel != null) {
    yield Automation(
      name: 'Fuel',
      category: fuel,
      rules: [
        Rule(creditorName: RegExp('CIRCLE K')),
        Rule(creditorName: RegExp('VIADA')),
      ],
    );
  }

  var gym = CategoryService.instance.findById(CategoryIds.gym);
  if (gym != null) {
    yield Automation(
      name: 'Gym',
      category: gym,
      rules: [
        Rule(creditorName: RegExp('GYM|gym')),
      ],
    );
  }

  var supplements = CategoryService.instance.findById(CategoryIds.supplements);
  if (supplements != null) {
    yield Automation(
      name: 'Protein',
      category: supplements,
      rules: [
        Rule(creditorName: RegExp('MY PROTEIN')),
      ],
    );
  }

  var pottery = CategoryService.instance.findById(CategoryIds.hobbies);
  if (pottery != null) {
    yield Automation(
      name: 'Pottery',
      category: pottery,
      rules: [
        Rule(
          remittanceInfo: RegExp('Keramika'),
          creditorName: RegExp('JUSTINA VAITKIENĖ'),
        ),
      ],
    );
  }

  var utilities = CategoryService.instance.findById(CategoryIds.utilities);
  if (utilities != null) {
    yield Automation(
      name: 'Utilities',
      category: utilities,
      rules: [
        Rule(
          creditorName: RegExp('UAB Viena sąskaita'),
        ),
      ],
    );
  }

  var electricity = CategoryService.instance.findById(CategoryIds.electricity);
  if (electricity != null) {
    yield Automation(
      name: 'Electricity',
      category: electricity,
      rules: [
        Rule(
          creditorName: RegExp('ENEFIT UAB'),
        ),
      ],
    );
  }

  var salary = CategoryService.instance.findById(CategoryIds.salary);
  if (salary != null) {
    yield Automation(
      name: 'Salary',
      category: salary,
      rules: [
        Rule(
          remittanceInfo: RegExp('SALARY'),
        ),
      ],
    );
  }
}

class AutomationService with ChangeNotifier {
  static final instance = AutomationService._ctor();

  List<Automation> automations = _seedData().toList();

  AutomationService._ctor();

  void delete(Automation automation) {
    automations.remove(automation);
    notifyListeners();
  }

  CategoryModel? getCategory({
    String? remittanceInfo,
    String? creditorName,
    String? creditorIban,
  }) {
    for (final automation in automations) {
      for (final rule in automation.rules) {
        if (_ruleMatches(rule.remittanceInfo, remittanceInfo)) {
          return automation.category;
        }

        if (_ruleMatches(rule.creditorName, creditorName)) {
          return automation.category;
        }

        if (_ruleMatches(rule.creditorIban, creditorIban)) {
          return automation.category;
        }
      }
    }

    return null;
  }

  bool _ruleMatches(RegExp? regex, String? target) {
    return regex != null && target != null && target.contains(regex);
  }

  void save(Automation model) {
    automations.add(model);
    notifyListeners();
  }

  void update(Automation model, Automation newValues) {
    model.name = newValues.name;
    model.category = newValues.category;
    model.rules = newValues.rules;
    notifyListeners();
  }
}

final lidlRegex = RegExp(
  r'^(.*[\d€]{4,8}.*)(?:\n{1,2}.*(?:X|ri).*|).(\d+[\.,]\d\d)\D.*$(?:\nTaikoma nuolaida\nNuolaida.*(-\d+[\.,]\d\d))?',
  multiLine: true,
);

final lidlNameVariants = [
  'Lidl',
  'Lid1',
  '111791015',
];

Future<String> extractTextMlKit(Attachment attachment) async {
  var scaledImagePath = p.join(Directory.systemTemp.path, 'scaled');

  // This is >3 times faster than using the `image` lib
  await FcNativeImageResize().resizeFile(
    srcFile: attachment.file.path,
    srcFileUri: true,
    destFile: scaledImagePath,
    width: 550,
    height: 10000,
    keepAspectRatio: true,
    format: 'png',
  );

  var inputImage = InputImage.fromFilePath(scaledImagePath);
  var textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  var text = await textRecognizer.processImage(inputImage);
  await textRecognizer.close();

  var lines = text.blocks.expand((element) => element.lines).sorted(_lineComparer);
  boundingBoxes = lines.map((e) => e.boundingBox).toList();

  if (lines.isEmpty) {
    logger.w('Did not extract any text from the image');
    return '';
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
  return extractedText;
}

List<Rect> boundingBoxes = [];

int _lineComparer(TextLine t1, TextLine t2) {
  var diffOfTops = t1.boundingBox.top - t2.boundingBox.top;
  var diffOfLefts = t1.boundingBox.left - t2.boundingBox.left;
  var avgHeight = (t1.boundingBox.height + t2.boundingBox.height) / 2;

  if (diffOfTops.abs() > avgHeight * 0.35) {
    return diffOfTops.toInt();
  }

  return diffOfLefts.toInt();
}

String _getLineSeparator(TextLine t1, TextLine t2) {
  var diffOfTops = t1.boundingBox.top - t2.boundingBox.top;
  var height = t1.boundingBox.height + t2.boundingBox.height;

  if (diffOfTops.abs() > height * 0.23) {
    return '\n';
  }

  return ' ';
}

Stream<({String text, Money money})> extractLineItems(String? text) async* {
  if (text == null) {
    return;
  }

  var fromLidl = lidlNameVariants.any((lidlString) => text.contains(lidlString));

  if (fromLidl) {
    for (var match in lidlRegex.allMatches(text)) {
      var lineItem = _parseLineItem(match);
      if (lineItem != null) {
        yield lineItem;
      }
    }
  } else {
    throw UnimplementedError();
  }
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
