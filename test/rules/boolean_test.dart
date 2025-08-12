import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  group('VineBoolean', () {
    test('is support boolean validation on top level', () {
      final validator = vine.compile(vine.boolean());
      expect(() => validator.validate(true), returnsNormally);
    });

    test('is valid when value is "true"', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'true'}), returnsNormally);
    });

    test('is valid when value is "false"', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'false'}), returnsNormally);
    });

    test('is valid when value is true', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': true}), returnsNormally);
    });

    test('is valid when value is false', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': false}), returnsNormally);
    });

    test('is valid when value is "0"', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      expect(() => validator.validate({'value': '0'}), returnsNormally);
    });

    test('is valid when value is "1"', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      expect(() => validator.validate({'value': '1'}), returnsNormally);
    });

    test('is invalid when value is not a boolean', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });
}
