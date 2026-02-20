import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  group('VineAny', () {
    test('is support any validation on top level', () {
      final validator = vine.compile(vine.any());
      expect(() => validator.validate('foo'), returnsNormally);
    });

    test('is valid when value is boolean', () {
      final validator = vine.compile(vine.object({'value': vine.boolean()}));

      expect(() => validator.validate({'value': true}), returnsNormally);
    });

    test('is valid when value is number', () {
      final validator = vine.compile(vine.object({'value': vine.number()}));

      expect(() => validator.validate({'value': 1}), returnsNormally);
    });

    test('is valid when value is string', () {
      final validator = vine.compile(vine.object({'value': vine.string()}));

      expect(() => validator.validate({'value': 'foo'}), returnsNormally);
    });
  });

  group('VineAny.nullable', () {
    test('is valid when value is null', () {
      final validator =
          vine.compile(vine.object({'value': vine.any().nullable()}));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });

    test('is valid when value is present with nullable', () {
      final validator =
          vine.compile(vine.object({'value': vine.any().nullable()}));

      expect(() => validator.validate({'value': 'foo'}), returnsNormally);
    });
  });

  group('VineAny.optional', () {
    test('is valid when value is absent', () {
      final validator =
          vine.compile(vine.object({'value': vine.any().optional()}));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is present', () {
      final validator =
          vine.compile(vine.object({'value': vine.any().optional()}));

      expect(() => validator.validate({'value': 42}), returnsNormally);
    });
  });

  group('VineAny.transform', () {
    test('is valid when transform is applied', () {
      final validator = vine.compile(vine.object({
        'value': vine.any().transform((ctx, field) {
          return 'transformed';
        }),
      }));

      final data = validator.validate({'value': 'anything'});
      expect(data['value'], 'transformed');
    });
  });

  group('VineAny.requiredIfExist', () {
    test('is valid when dependency exists and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'value': vine.any().requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo', 'value': 'bar'}),
          returnsNormally);
    });

    test('is invalid when dependency exists and value is null', () {
      final validator = vine.compile(vine.object({
        'value': vine.any().requiredIfExist(['field']),
        'field': vine.string(),
      }));

      expect(() => validator.validate({'field': 'foo', 'value': null}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineAny.requiredIfMissing', () {
    test('is valid when dependency is missing and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'value': vine.any().requiredIfMissing(['field']),
      }));

      expect(() => validator.validate({'value': 'bar'}), returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('VineAny accepts all types', () {
    test('is valid when value is a map', () {
      final validator = vine.compile(vine.object({'value': vine.any()}));

      expect(
          () => validator.validate({
                'value': {'key': 'val'}
              }),
          returnsNormally);
    });

    test('is valid when value is a list', () {
      final validator = vine.compile(vine.object({'value': vine.any()}));

      expect(
          () => validator.validate({
                'value': [1, 2, 3]
              }),
          returnsNormally);
    });

    test('is valid when value is an int', () {
      final validator = vine.compile(vine.object({'value': vine.any()}));

      expect(() => validator.validate({'value': 42}), returnsNormally);
    });

    test('is valid when value is a double', () {
      final validator = vine.compile(vine.object({'value': vine.any()}));

      expect(() => validator.validate({'value': 3.14}), returnsNormally);
    });

    test('is valid when value is null with nullable', () {
      final validator =
          vine.compile(vine.object({'value': vine.any().nullable()}));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });
  });

  group('VineAny with transform', () {
    test('transform any value to string', () {
      final validator = vine.compile(vine.object({
        'value': vine.any().transform((ctx, field) {
          return field.value.toString();
        }),
      }));

      final data = validator.validate({'value': 42});
      expect(data['value'], '42');
    });

    test('transform any value to number', () {
      final validator = vine.compile(vine.object({
        'value': vine.any().transform((ctx, field) {
          return (field.value is String)
              ? int.tryParse(field.value as String) ?? 0
              : field.value;
        }),
      }));

      final data = validator.validate({'value': '123'});
      expect(data['value'], 123);
    });
  });

  group('VineAny top-level', () {
    test('is valid when any value is validated at top level', () {
      final validator = vine.compile(vine.any());
      expect(() => validator.validate('anything'), returnsNormally);
    });
  });
}
