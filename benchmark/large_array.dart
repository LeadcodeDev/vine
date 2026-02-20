import 'package:vine/src/vine.dart';

void main() {
  final validator = vine.compile(vine.array(
    vine.object({
      'id': vine.number(),
      'name': vine.string(),
      'email': vine.string().email(),
    }),
  ));

  final payload = List.generate(10000, (i) {
    return {
      'id': i,
      'name': 'User $i',
      'email': 'user$i@example.com',
    };
  });

  final stopwatch = Stopwatch()..start();
  validator.validate(payload);
  stopwatch.stop();

  print('Large Array (10k elements) : ${stopwatch.elapsedMilliseconds}ms');
}
