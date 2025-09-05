import 'package:vine/src/vine.dart';

void main() {
  final validator = vine.compile(vine.object({
    'firstname': vine.string(),
    'lastname': vine.string(),
  }));

  final payload = {
    'firstname': 'John',
    'lastname': 'Doe',
  };

  final duration = Duration(seconds: 1);
  int iterationCount = 0;
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < duration) {
    validator.validate(payload);
    iterationCount++;
  }

  print(
      'Flat Object : Processed $iterationCount iterations in ${duration.inSeconds} seconds');
}
