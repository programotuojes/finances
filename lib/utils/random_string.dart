import 'dart:math';

String generateRandomString(int len) {
  final random = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => 97 + random.nextInt(25)),
  );
}
