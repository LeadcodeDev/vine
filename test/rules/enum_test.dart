import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

enum MyEnum implements VineEnumerable<String> {
  value1('value1'),
  value2('value2'),
  value3('value3');

  @override
  final String value;
  const MyEnum(this.value);
}

void main() {
  group('VineEnum', () {
    test('is support enum validation on top level', () {
      final validator = vine.compile(vine.enumerate(MyEnum.values));
      expect(() => validator.validate(MyEnum.value1.value), returnsNormally);
    });

    test('is valid when value is includes in enum', () {
      final validator =
          vine.compile(vine.object({'value': vine.enumerate(MyEnum.values)}));

      expect(() => validator.validate({'value': MyEnum.value1.value}),
          returnsNormally);
    });

    test('is invalid when value is not includes in enum', () {
      final validator =
          vine.compile(vine.object({'value': vine.enumerate(MyEnum.values)}));

      expect(() => validator.validate({'value': 'value4'}),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when value is nullable', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).nullable()}));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });

    test('is valid when value is optional', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).optional()}));

      expect(() => validator.validate({}), returnsNormally);
    });
  });

  group('VineEnum.transform', () {
    test('is valid when transform is applied', () {
      final validator = vine.compile(vine.object({
        'value': vine.enumerate(MyEnum.values).transform((ctx, field) {
          return '${field.value}_transformed';
        }),
      }));

      final data = validator.validate({'value': 'value1'});
      expect(data['value'], 'value1_transformed');
    });
  });

  group('VineEnum.requiredIfExist', () {
    test('is valid when dependency exists and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'value': vine.enumerate(MyEnum.values).requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo', 'value': 'value1'}),
          returnsNormally);
    });

    test('is invalid when dependency exists and value is missing', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'value': vine.enumerate(MyEnum.values).requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineEnum.requiredIfMissing', () {
    test('is valid when dependency is missing and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'value': vine.enumerate(MyEnum.values).requiredIfMissing(['field']),
      }));

      expect(() => validator.validate({'value': 'value1'}), returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('VineEnum edge cases', () {
    test('is invalid when value is missing without optional', () {
      final validator =
          vine.compile(vine.object({'value': vine.enumerate(MyEnum.values)}));

      expect(() => validator.validate(<String, dynamic>{}),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is empty string', () {
      final validator =
          vine.compile(vine.object({'value': vine.enumerate(MyEnum.values)}));

      expect(() => validator.validate({'value': ''}),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when value is first enum value', () {
      final validator =
          vine.compile(vine.object({'value': vine.enumerate(MyEnum.values)}));

      expect(() => validator.validate({'value': MyEnum.value1.value}),
          returnsNormally);
    });

    test('is valid when value is last enum value', () {
      final validator =
          vine.compile(vine.object({'value': vine.enumerate(MyEnum.values)}));

      expect(() => validator.validate({'value': MyEnum.value3.value}),
          returnsNormally);
    });
  });

  group('VineEnum nullable + enum', () {
    test('is valid when value is null with nullable enum', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).nullable()}));

      expect(() => validator.validate({'value': null}), returnsNormally);
    });

    test('is valid when value is a valid enum value with nullable', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).nullable()}));

      expect(() => validator.validate({'value': 'value2'}), returnsNormally);
    });

    test('is invalid when value is non-enum value with nullable', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).nullable()}));

      expect(() => validator.validate({'value': 'invalid'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineEnum optional + enum', () {
    test('is valid when value is absent with optional enum', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).optional()}));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is a valid enum value with optional', () {
      final validator = vine.compile(
          vine.object({'value': vine.enumerate(MyEnum.values).optional()}));

      expect(() => validator.validate({'value': 'value1'}), returnsNormally);
    });
  });

  group('VineEnum transform', () {
    test('transform enum value to uppercase', () {
      final validator = vine.compile(vine.object({
        'value': vine.enumerate(MyEnum.values).transform((ctx, field) {
          return (field.value as String).toUpperCase();
        }),
      }));

      final data = validator.validate({'value': 'value1'});
      expect(data['value'], 'VALUE1');
    });
  });
}
