import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/src/exceptions/validation_exception.dart';
import 'package:vine/src/vine.dart';

void main() {
  test('is support number validation on top level', () {
    final validator = vine.compile(vine.number());
    expect(() => validator.validate(10), returnsNormally);
  });

  group('VineNumber - range', () {
    test('valid: value within range [10, 20, 30]', () {
      final validator = vine.compile(vine.object({
        'age': vine.number().range([10, 20, 30])
      }));
      expect(() => validator.validate({'age': 20}), returnsNormally);
    });

    test('valid: value equals min range [5, 10, 15]', () {
      final validator = vine.compile(vine.object({
        'age': vine.number().range([5, 10, 15])
      }));
      expect(() => validator.validate({'age': 5}), returnsNormally);
    });

    test('invalid: value below range [10, 20, 30]', () {
      final validator = vine.compile(vine.object({
        'age': vine.number().range([10, 20, 30])
      }));
      expect(() => validator.validate({'age': 5}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: value above range [10, 20, 30]', () {
      final validator = vine.compile(vine.object({
        'age': vine.number().range([10, 20, 30])
      }));
      expect(() => validator.validate({'age': 35}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: value not in range [10, 20, 30]', () {
      final validator = vine.compile(vine.object({
        'age': vine.number().range([10, 20, 30])
      }));
      expect(() => validator.validate({'age': 25}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - min', () {
    test('valid: value equals min (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().min(10)}));
      expect(() => validator.validate({'age': 10}), returnsNormally);
    });

    test('valid: value above min (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().min(10)}));
      expect(() => validator.validate({'age': 15}), returnsNormally);
    });

    test('invalid: value below min (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().min(10)}));
      expect(() => validator.validate({'age': 5}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: negative value with min (0)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().min(0)}));
      expect(() => validator.validate({'age': -5}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: null value with min (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().min(10)}));
      expect(() => validator.validate({'age': null}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - max', () {
    test('valid: value equals max (100)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().max(100)}));
      expect(() => validator.validate({'age': 100}), returnsNormally);
    });

    test('valid: value below max (100)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().max(100)}));
      expect(() => validator.validate({'age': 50}), returnsNormally);
    });

    test('invalid: value above max (100)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().max(100)}));
      expect(() => validator.validate({'age': 150}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: null value with max (100)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().max(100)}));
      expect(() => validator.validate({'age': null}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: negative value with max (0)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().max(0)}));
      expect(() => validator.validate({'age': -5}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - negative', () {
    test('valid: negative value (-10)', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().negative()}));
      expect(() => validator.validate({'balance': -10}), returnsNormally);
    });

    test('invalid: zero value (0)', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().negative()}));
      expect(() => validator.validate({'balance': 0}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: positive value (10)', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().negative()}));
      expect(() => validator.validate({'balance': 10}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: null value', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().negative()}));
      expect(() => validator.validate({'balance': null}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: non-numeric value', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().negative()}));
      expect(() => validator.validate({'balance': 'not a number'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - positive', () {
    test('valid: positive value (10)', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().positive()}));
      expect(() => validator.validate({'balance': 10}), returnsNormally);
    });

    test('valid: zero value (0)', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().positive()}));
      expect(() => validator.validate({'balance': 0}), returnsNormally);
    });

    test('invalid: negative value (-10)', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().positive()}));
      expect(() => validator.validate({'balance': -10}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: null value', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().positive()}));
      expect(() => validator.validate({'balance': null}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: non-numeric value', () {
      final validator =
          vine.compile(vine.object({'balance': vine.number().positive()}));
      expect(() => validator.validate({'balance': 'not a number'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - double', () {
    test('valid: double value (10.5)', () {
      final validator =
          vine.compile(vine.object({'price': vine.number().double()}));
      expect(() => validator.validate({'price': 10.5}), returnsNormally);
    });

    test('invalid: integer value (10)', () {
      final validator =
          vine.compile(vine.object({'price': vine.number().double()}));
      expect(() => validator.validate({'price': 10}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: null value', () {
      final validator =
          vine.compile(vine.object({'price': vine.number().double()}));
      expect(() => validator.validate({'price': null}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: non-numeric value', () {
      final validator =
          vine.compile(vine.object({'price': vine.number().double()}));
      expect(() => validator.validate({'price': 'not a number'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: invalid double format', () {
      final validator =
          vine.compile(vine.object({'price': vine.number().double()}));
      expect(() => validator.validate({'price': '10.5.5'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - integer', () {
    test('valid: integer value (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().integer()}));
      expect(() => validator.validate({'age': 10}), returnsNormally);
    });

    test('valid: zero value (0)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().integer()}));
      expect(() => validator.validate({'age': 0}), returnsNormally);
    });

    test('invalid: double value (10.5)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().integer()}));
      expect(() => validator.validate({'age': 10.5}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: null value', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().integer()}));
      expect(() => validator.validate({'age': null}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: non-numeric value', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().integer()}));
      expect(() => validator.validate({'age': 'not a number'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - nullable', () {
    test('valid: null value', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().nullable()}));
      expect(() => validator.validate({'age': null}), returnsNormally);
    });

    test('valid: non-null value (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().nullable()}));
      expect(() => validator.validate({'age': 10}), returnsNormally);
    });

    test('invalid: non-numeric value', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().nullable()}));
      expect(() => validator.validate({'age': 'not a number'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - optional', () {
    test('valid: absent value', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().optional()}));
      expect(() => validator.validate({}), returnsNormally);
    });

    test('valid: present value (10)', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().optional()}));
      expect(() => validator.validate({'age': 10}), returnsNormally);
    });

    test('invalid: non-numeric value', () {
      final validator =
          vine.compile(vine.object({'age': vine.number().optional()}));
      expect(() => validator.validate({'age': 'not a number'}),
          throwsA(isA<VineValidationException>()));
    });
  });
}
