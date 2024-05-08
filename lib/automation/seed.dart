import 'package:finances/automation/models/automation.dart';
import 'package:finances/category/seed.dart';
import 'package:finances/category/service.dart';

Iterable<Automation> seedData() sync* {
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
