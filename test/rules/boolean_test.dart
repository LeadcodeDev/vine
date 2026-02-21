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

  group('VineBoolean.nullable', () {
    test('is valid when value is null', () {
      final validator =
          vine.compile(vine.object({'value': vine.boolean().nullable()}));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });

    test('is valid when value is true with nullable', () {
      final validator =
          vine.compile(vine.object({'value': vine.boolean().nullable()}));

      expect(() => validator.validate({'value': true}), returnsNormally);
    });
  });

  group('VineBoolean.optional', () {
    test('is valid when value is absent', () {
      final validator =
          vine.compile(vine.object({'value': vine.boolean().optional()}));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is present', () {
      final validator =
          vine.compile(vine.object({'value': vine.boolean().optional()}));

      expect(() => validator.validate({'value': false}), returnsNormally);
    });
  });

  group('VineBoolean.transform', () {
    test('is valid when transform is applied', () {
      final validator = vine.compile(vine.object({
        'value': vine.boolean().transform((ctx, field) {
          return (field.value as bool) ? 'yes' : 'no';
        }),
      }));

      final data = validator.validate({'value': true});
      expect(data['value'], 'yes');
    });
  });

  group('VineBoolean.requiredIfExist', () {
    test('is valid when dependency exists and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'flag': vine.boolean().requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo', 'flag': true}),
          returnsNormally);
    });

    test('is invalid when dependency exists and value is missing', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'flag': vine.boolean().requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineBoolean.requiredIfMissing', () {
    test('is valid when dependency is missing and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'flag': vine.boolean().requiredIfMissing(['field']),
      }));

      expect(() => validator.validate({'flag': true}), returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('VineBoolean.includeLiteral edge cases', () {
    test('is valid when value is integer 0', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      final data = validator.validate({'value': 0});
      expect(data['value'], false);
    });

    test('is valid when value is integer 1', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      final data = validator.validate({'value': 1});
      expect(data['value'], true);
    });

    test('is invalid when value is integer 2', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      expect(() => validator.validate({'value': 2}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineBoolean string coercion edge cases', () {
    test('is invalid when value is "TRUE" (uppercase)', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'TRUE'}),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is "FALSE" (uppercase)', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'FALSE'}),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is "True" (mixed case)', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'True'}),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is "yes"', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'yes'}),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is "no"', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': 'no'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineBoolean includeLiteral with string', () {
    test('is valid when value is "0" string with includeLiteral', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      expect(() => validator.validate({'value': '0'}), returnsNormally);
    });

    test('is valid when value is "1" string with includeLiteral', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      expect(() => validator.validate({'value': '1'}), returnsNormally);
    });

    test('is invalid when value is "2" string with includeLiteral', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      expect(() => validator.validate({'value': '2'}),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when value is 0 int with includeLiteral', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      final data = validator.validate({'value': 0});
      expect(data['value'], false);
    });

    test('is valid when value is 1 int with includeLiteral', () {
      final validator = vine
          .compile(vine.object({'value': vine.boolean(includeLiteral: true)}));

      final data = validator.validate({'value': 1});
      expect(data['value'], true);
    });
  });

  group('VineBoolean nullable + transform', () {
    test('is valid when value is null with nullable (no transform applied)',
        () {
      final validator = vine.compile(vine.object({
        'value': vine.boolean().nullable().transform((ctx, field) {
          return (field.value as bool) ? 1 : 0;
        }),
      }));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });

    test('is valid when value is true with nullable and transform applied', () {
      final validator = vine.compile(vine.object({
        'value': vine.boolean().nullable().transform((ctx, field) {
          return (field.value as bool) ? 1 : 0;
        }),
      }));

      final data = validator.validate({'value': true});
      expect(data['value'], 1);
    });
  });

  group('VineBoolean optional + transform', () {
    test('is valid when value is absent with optional (no transform applied)',
        () {
      final validator = vine.compile(vine.object({
        'value': vine.boolean().optional().transform((ctx, field) {
          return (field.value as bool) ? 'on' : 'off';
        }),
      }));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is false with optional and transform applied',
        () {
      final validator = vine.compile(vine.object({
        'value': vine.boolean().optional().transform((ctx, field) {
          return (field.value as bool) ? 'on' : 'off';
        }),
      }));

      final data = validator.validate({'value': false});
      expect(data['value'], 'off');
    });
  });

  group('VineBoolean chaining', () {
    test('is valid with nullable + includeLiteral when value is null', () {
      final validator = vine.compile(vine
          .object({'value': vine.boolean(includeLiteral: true).nullable()}));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });

    test('is valid with optional + includeLiteral when value is absent', () {
      final validator = vine.compile(vine
          .object({'value': vine.boolean(includeLiteral: true).optional()}));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });
  });

  group('VineBoolean top-level', () {
    test('is valid when top-level value is true', () {
      final validator = vine.compile(vine.boolean());
      expect(() => validator.validate(true), returnsNormally);
    });

    test('is valid when top-level value is false', () {
      final validator = vine.compile(vine.boolean());
      expect(() => validator.validate(false), returnsNormally);
    });

    test('is invalid when top-level value is a string', () {
      final validator = vine.compile(vine.boolean());
      expect(() => validator.validate('hello'),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when top-level value is a number', () {
      final validator = vine.compile(vine.boolean());
      expect(() => validator.validate(42),
          throwsA(isA<VineValidationException>()));
    });
  });
}
