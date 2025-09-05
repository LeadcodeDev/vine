import 'package:vine/src/vine.dart';

void main() {
  final validator = vine.compile(vine.array(
    vine.object({
      'type': vine.string(),
      'value': vine.string().optional(),
    }),
  ));

  final payload = [
    {'type': 'email', 'value': 'foo@bar.com'},
  ];

  final duration = Duration(seconds: 1);
  int iterationCount = 0;
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < duration) {
    validator.validate(payload);
    iterationCount++;
  }

  print(
      'Array Object : Processed $iterationCount iterations in ${duration.inSeconds} seconds');
}
