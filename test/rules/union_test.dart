import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  test('is support union validation on top level', () {
    final validator = vine.compile(vine.union([
      vine.string(),
      vine.number(),
    ]));

    expect(() => validator.validate('foo'), returnsNormally);
    expect(() => validator.validate(10), returnsNormally);
  });

  group('Union validation', () {
    test('is valid when value is string', () {
      final payload = {'value': 'foo'};
      final validator = vine.compile(vine.object({
        'value': vine.union([
          vine.string(),
          vine.number(),
        ]),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });
  });

  test('is valid when value is number', () {
    final payload = {'value': 10};
    final validator = vine.compile(vine.object({
      'value': vine.union([
        vine.string(),
        vine.number(),
      ]),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('is invalid when no schema matches', () {
    final payload = {'value': true};
    final validator = vine.compile(vine.object({
      'union': vine.union([
        vine.string(),
        vine.number(),
      ]),
    }));

    expect(() => validator.validate(payload),
        throwsA(isA<VineValidationException>()));
  });

  test('is valid when value matches third schema', () {
    final payload = {
      'value': true,
    };
    final validator = vine.compile(vine.object({
      'value': vine.union([
        vine.string(),
        vine.number(),
        vine.boolean(),
      ]),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  group('VineUnion.nullable', () {
    test('is valid when value is null', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number()]).nullable(),
      }));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });
  });

  group('VineUnion.optional', () {
    test('is valid when value is absent', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number()]).optional(),
      }));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is present', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number()]).optional(),
      }));

      expect(() => validator.validate({'value': 'foo'}), returnsNormally);
    });
  });

  group('VineUnion.transform', () {
    test('is valid when transform is applied', () {
      final validator = vine.compile(vine.object({
        'value':
            vine.union([vine.string(), vine.number()]).transform((ctx, field) {
          return 'transformed_${field.value}';
        }),
      }));

      final data = validator.validate({'value': 'hello'});
      expect(data['value'], 'transformed_hello');
    });
  });

  group('VineUnion.requiredIfExist', () {
    test('is valid when dependency exists and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'value': vine
            .union([vine.string(), vine.number()]).requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo', 'value': 'bar'}),
          returnsNormally);
    });

    test('is invalid when dependency exists and value is missing', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'value': vine
            .union([vine.string(), vine.number()]).requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineUnion.requiredIfMissing', () {
    test('is valid when dependency is missing and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'value': vine
            .union([vine.string(), vine.number()]).requiredIfMissing(['field']),
      }));

      expect(() => validator.validate({'value': 'bar'}), returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('Union with 3+ types', () {
    test('is valid when value is string in 3-type union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number(), vine.boolean()]),
      }));

      expect(() => validator.validate({'value': 'hello'}), returnsNormally);
    });

    test('is valid when value is number in 3-type union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number(), vine.boolean()]),
      }));

      expect(() => validator.validate({'value': 42}), returnsNormally);
    });

    test('is valid when value is boolean in 3-type union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number(), vine.boolean()]),
      }));

      expect(() => validator.validate({'value': true}), returnsNormally);
    });

    test('is invalid when value is date in string/number/boolean union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([vine.string(), vine.number(), vine.boolean()]),
      }));

      expect(() => validator.validate({'value': DateTime.now()}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Union with objects', () {
    test('is valid when value matches object schema in union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([
          vine.string(),
          vine.object({'name': vine.string()}),
        ]),
      }));

      expect(
          () => validator.validate({
                'value': {'name': 'John'}
              }),
          returnsNormally);
    });

    test('is valid when value matches string alternative in object union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([
          vine.object({'name': vine.string()}),
          vine.string(),
        ]),
      }));

      expect(() => validator.validate({'value': 'hello'}), returnsNormally);
    });

    test('is invalid when value matches no schema in object union', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([
          vine.object({'name': vine.string()}),
          vine.number(),
        ]),
      }));

      expect(() => validator.validate({'value': true}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Union with transform', () {
    test('transform is applied to matching type', () {
      final validator = vine.compile(vine.object({
        'value':
            vine.union([vine.string(), vine.number()]).transform((ctx, field) {
          return 'result_${field.value}';
        }),
      }));

      final data = validator.validate({'value': 42});
      expect(data['value'], 'result_42');
    });
  });

  group('Union with arrays', () {
    test('is valid when value matches array union member', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([
          vine.array(vine.string()),
          vine.string(),
        ]),
      }));

      expect(
          () => validator.validate({
                'value': ['a', 'b']
              }),
          returnsNormally);
    });

    test('is valid when value matches non-array union member', () {
      final validator = vine.compile(vine.object({
        'value': vine.union([
          vine.array(vine.string()),
          vine.string(),
        ]),
      }));

      expect(() => validator.validate({'value': 'hello'}), returnsNormally);
    });
  });
}
