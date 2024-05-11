import 'package:finances/automation/models/automation.dart';
import 'package:finances/category/seed.dart';
import 'package:finances/category/service.dart';

Iterable<Automation> seedData() sync* {
  var id = 0;

  var groceries = CategoryService.instance.findById(CategoryIds.groceries);
  if (groceries != null) {
    yield Automation(
      id: id--,
      name: 'Groceries',
      category: groceries,
    )..addRules([
        Rule(creditorName: RegExp('MAXIMA')),
        Rule(creditorName: RegExp('RIMI')),
        Rule(creditorName: RegExp('LIDL')),
      ]);
  }

  var music = CategoryService.instance.findById(CategoryIds.music);
  if (music != null) {
    yield Automation(
      id: id--,
      name: 'Spotify',
      category: music,
    )..addRules([
        Rule(remittanceInfo: RegExp('Muzikinės paslaugos')),
        Rule(creditorName: RegExp('SPOTIFY')),
      ]);
  }

  var fuel = CategoryService.instance.findById(CategoryIds.fuel);
  if (fuel != null) {
    yield Automation(
      id: id--,
      name: 'Fuel',
      category: fuel,
    )..addRules([
        Rule(creditorName: RegExp('CIRCLE K')),
        Rule(creditorName: RegExp('VIADA')),
      ]);
  }

  var gym = CategoryService.instance.findById(CategoryIds.gym);
  if (gym != null) {
    yield Automation(
      id: id--,
      name: 'Gym',
      category: gym,
    )..addRules([
        Rule(creditorName: RegExp('GYM|gym')),
      ]);
  }

  var supplements = CategoryService.instance.findById(CategoryIds.supplements);
  if (supplements != null) {
    yield Automation(
      name: 'Protein',
      category: supplements,
    )..addRules([
        Rule(creditorName: RegExp('MY PROTEIN')),
      ]);
  }

  var pottery = CategoryService.instance.findById(CategoryIds.hobbies);
  if (pottery != null) {
    yield Automation(
      id: id--,
      name: 'Pottery',
      category: pottery,
    )..addRules([
        Rule(
          remittanceInfo: RegExp('Keramika'),
          creditorName: RegExp('JUSTINA VAITKIENĖ'),
        ),
      ]);
  }

  var utilities = CategoryService.instance.findById(CategoryIds.utilities);
  if (utilities != null) {
    yield Automation(
      id: id--,
      name: 'Utilities',
      category: utilities,
    )..addRules([
        Rule(creditorName: RegExp('UAB Viena sąskaita')),
      ]);
  }

  var electricity = CategoryService.instance.findById(CategoryIds.electricity);
  if (electricity != null) {
    yield Automation(
      id: id--,
      name: 'Electricity',
      category: electricity,
    )..addRules([
        Rule(creditorName: RegExp('ENEFIT UAB')),
      ]);
  }

  var salary = CategoryService.instance.findById(CategoryIds.salary);
  if (salary != null) {
    yield Automation(
      id: id--,
      name: 'Salary',
      category: salary,
    )..addRules([
        Rule(remittanceInfo: RegExp('SALARY')),
      ]);
  }
}
