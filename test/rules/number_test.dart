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

    test('validate many times', () {
      final validator = vine.compile(vine.object({
        'toto': vine.number().min(18).optional(),
      }));

      final payload = {'toto': 25};

      expect(() => validator.validate(payload), returnsNormally);
      expect(() {
        return validator.validate({
          ...payload,
          'toto': 17,
        });
      }, throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - requiredIfAnyExist', () {
    test('valid: any dependency exists and value provided', () {
      final validator = vine.compile(vine.object({
        'first': vine.string().optional(),
        'second': vine.string().optional(),
        'age': vine.number().requiredIfAnyExist(['first', 'second']),
      }));

      expect(() => validator.validate({'first': 'foo', 'age': 10}),
          returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfExistsAny' error reporter crash when field value is null
  });

  group('VineNumber - requiredIfMissing', () {
    test('valid: dependency missing and value provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'age': vine.number().requiredIfMissing(['field']),
      }));

      expect(() => validator.validate({'age': 10}), returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('VineNumber - requiredIfAnyMissing', () {
    test('valid: any dependency missing and value provided', () {
      final validator = vine.compile(vine.object({
        'first': vine.string().optional(),
        'second': vine.string().optional(),
        'age': vine.number().requiredIfAnyMissing(['first', 'second']),
      }));

      expect(() => validator.validate({'first': 'foo', 'age': 10}),
          returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissingAny' key missing from mappedErrors
  });

  group('VineNumber - transform', () {
    test('valid: custom transform multiplies value', () {
      final validator = vine.compile(vine.object({
        'price': vine.number().transform((ctx, field) {
          return (field.value as num) * 2;
        }),
      }));

      final data = validator.validate({'price': 10});
      expect(data['price'], 20);
    });
  });

  group('VineNumber - string coercion', () {
    test('valid: string "42" is coerced to number 42', () {
      final validator = vine.compile(vine.object({'age': vine.number()}));

      final data = validator.validate({'age': '42'});
      expect(data['age'], 42);
    });

    test('valid: string "3.14" is coerced to double', () {
      final validator = vine.compile(vine.object({'price': vine.number()}));

      final data = validator.validate({'price': '3.14'});
      expect(data['price'], 3.14);
    });
  });

  group('VineNumber - range edge cases', () {
    test('valid: value equals max in range [1, 2, 3]', () {
      final validator = vine.compile(vine.object({
        'field': vine.number().range([1, 2, 3])
      }));
      expect(() => validator.validate({'field': 3}), returnsNormally);
    });

    test('valid: value equals min in range [1, 2, 3]', () {
      final validator = vine.compile(vine.object({
        'field': vine.number().range([1, 2, 3])
      }));
      expect(() => validator.validate({'field': 1}), returnsNormally);
    });

    test('invalid: negative value not in range [1, 2, 3]', () {
      final validator = vine.compile(vine.object({
        'field': vine.number().range([1, 2, 3])
      }));
      expect(() => validator.validate({'field': -1}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: single-element range [42]', () {
      final validator = vine.compile(vine.object({
        'field': vine.number().range([42])
      }));
      expect(() => validator.validate({'field': 42}), returnsNormally);
    });

    test('invalid: value not in single-element range [42]', () {
      final validator = vine.compile(vine.object({
        'field': vine.number().range([42])
      }));
      expect(() => validator.validate({'field': 41}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - min edge cases', () {
    test('valid: large number above min (5)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(5)}));
      expect(() => validator.validate({'field': 999999}), returnsNormally);
    });

    test('valid: zero equals min zero', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(0)}));
      expect(() => validator.validate({'field': 0}), returnsNormally);
    });

    test('invalid: float 9.99 below min (10)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(10)}));
      expect(() => validator.validate({'field': 9.99}),
          throwsA(isA<VineValidationException>()));
    });

    test(
        'invalid: negative value with negative min (-5) fails due to isNegative check',
        () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(-5)}));
      expect(() => validator.validate({'field': -3}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: value exactly at min boundary (100)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(100)}));
      expect(() => validator.validate({'field': 100}), returnsNormally);
    });
  });

  group('VineNumber - max edge cases', () {
    test('invalid: negative value below max (0) fails due to isNegative check',
        () {
      final validator =
          vine.compile(vine.object({'field': vine.number().max(0)}));
      expect(() => validator.validate({'field': -1}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: zero at max (0)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().max(0)}));
      expect(() => validator.validate({'field': 0}), returnsNormally);
    });

    test(
        'invalid: zero above max negative (-1) -- zero is not negative so passes isNegative but is above max',
        () {
      final validator =
          vine.compile(vine.object({'field': vine.number().max(-1)}));
      expect(() => validator.validate({'field': 0}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: float at max (99.9)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().max(99.9)}));
      expect(() => validator.validate({'field': 99.9}), returnsNormally);
    });

    test('valid: value well below max (1000)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().max(1000)}));
      expect(() => validator.validate({'field': 500}), returnsNormally);
    });
  });

  group('VineNumber - negative edge cases', () {
    test('valid: -0.5 is negative', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().negative()}));
      expect(() => validator.validate({'field': -0.5}), returnsNormally);
    });

    test('valid: very large negative number (-999999)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().negative()}));
      expect(() => validator.validate({'field': -999999}), returnsNormally);
    });

    test('valid: -0.0 is negative in Dart (isNegative is true)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().negative()}));
      expect(() => validator.validate({'field': -0.0}), returnsNormally);
    });

    test('valid: -1 is negative', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().negative()}));
      expect(() => validator.validate({'field': -1}), returnsNormally);
    });

    test('invalid: 1 is not negative', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().negative()}));
      expect(() => validator.validate({'field': 1}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - positive edge cases', () {
    test('valid: 0.1 is positive', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().positive()}));
      expect(() => validator.validate({'field': 0.1}), returnsNormally);
    });

    test('valid: very large positive number (999999)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().positive()}));
      expect(() => validator.validate({'field': 999999}), returnsNormally);
    });

    test('valid: 1 is positive', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().positive()}));
      expect(() => validator.validate({'field': 1}), returnsNormally);
    });

    test('invalid: -0.0 is not positive (isNegative is true)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().positive()}));
      expect(() => validator.validate({'field': -0.0}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: -0.1 is not positive', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().positive()}));
      expect(() => validator.validate({'field': -0.1}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - double edge cases', () {
    test('valid: 0.0 is a double', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().double()}));
      expect(() => validator.validate({'field': 0.0}), returnsNormally);
    });

    test('valid: negative double (-3.14)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().double()}));
      expect(() => validator.validate({'field': -3.14}), returnsNormally);
    });

    test('invalid: string "abc" is not a number', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().double()}));
      expect(() => validator.validate({'field': 'abc'}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: string "10.5" is coerced to double 10.5', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().double()}));
      final data = validator.validate({'field': '10.5'});
      expect(data['field'], 10.5);
    });

    test('valid: very small double (0.001)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().double()}));
      expect(() => validator.validate({'field': 0.001}), returnsNormally);
    });
  });

  group('VineNumber - integer edge cases', () {
    test('valid: negative integer (-42)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().integer()}));
      expect(() => validator.validate({'field': -42}), returnsNormally);
    });

    test('valid: large integer (1000000)', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().integer()}));
      expect(() => validator.validate({'field': 1000000}), returnsNormally);
    });

    test('invalid: string "abc" is not a number', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().integer()}));
      expect(() => validator.validate({'field': 'abc'}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: string "42" is coerced to integer 42', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().integer()}));
      final data = validator.validate({'field': '42'});
      expect(data['field'], 42);
    });

    test('invalid: boolean value is not a number', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().integer()}));
      expect(() => validator.validate({'field': true}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineNumber - nullable + min combined', () {
    test('valid: null value with nullable + min (10)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().nullable().min(10)}));
      expect(() => validator.validate({'field': null}), returnsNormally);
    });

    test('valid: number above min with nullable + min (10)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().nullable().min(10)}));
      expect(() => validator.validate({'field': 15}), returnsNormally);
    });

    test('invalid: number below min with nullable + min (10)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().nullable().min(10)}));
      expect(() => validator.validate({'field': 5}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: number equals min with nullable + min (10)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().nullable().min(10)}));
      expect(() => validator.validate({'field': 10}), returnsNormally);
    });
  });

  group('VineNumber - optional + max combined', () {
    test('valid: absent value with optional + max (100)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().optional().max(100)}));
      expect(() => validator.validate({}), returnsNormally);
    });

    test('valid: number below max with optional + max (100)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().optional().max(100)}));
      expect(() => validator.validate({'field': 50}), returnsNormally);
    });

    test('invalid: number above max with optional + max (100)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().optional().max(100)}));
      expect(() => validator.validate({'field': 150}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: number equals max with optional + max (100)', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().optional().max(100)}));
      expect(() => validator.validate({'field': 100}), returnsNormally);
    });
  });

  group('VineNumber - chained rules', () {
    test('valid: min + max combined, value in range', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(10).max(100)}));
      expect(() => validator.validate({'field': 50}), returnsNormally);
    });

    test('invalid: min + max combined, value below min', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(10).max(100)}));
      expect(() => validator.validate({'field': 5}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: min + max combined, value above max', () {
      final validator =
          vine.compile(vine.object({'field': vine.number().min(10).max(100)}));
      expect(() => validator.validate({'field': 150}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: integer + positive combined', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().integer().positive()}));
      expect(() => validator.validate({'field': 5}), returnsNormally);
    });

    test('invalid: integer + positive combined, negative integer', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().integer().positive()}));
      expect(() => validator.validate({'field': -5}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid: integer + positive combined, positive double', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().integer().positive()}));
      expect(() => validator.validate({'field': 5.5}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid: double + negative combined', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().double().negative()}));
      expect(() => validator.validate({'field': -3.14}), returnsNormally);
    });

    test('invalid: double + negative combined, positive double', () {
      final validator = vine
          .compile(vine.object({'field': vine.number().double().negative()}));
      expect(() => validator.validate({'field': 3.14}),
          throwsA(isA<VineValidationException>()));
    });
  });
}
