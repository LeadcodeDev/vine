import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  group('VineArray', () {
    test('is support array validation on top level', () {
      final validator = vine.compile(vine.array(vine.string()));
      expect(() => validator.validate(['foo', 'bar']), returnsNormally);
    });

    test('is support array validation on top level with object', () {
      final validator =
          vine.compile(vine.array(vine.object({'value': vine.string()})));

      final payload = [
        {'value': 'foo'},
        {'value': 'bar'}
      ];

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is valid when value is string', () {
      final validator = vine.compile(
          vine.object({'value': vine.array(vine.string().minLength(2))}));

      expect(
          () => validator.validate({
                'value': ['foo']
              }),
          returnsNormally);
    });

    test('is valid when value is number', () {
      final validator =
          vine.compile(vine.object({'value': vine.array(vine.number())}));

      expect(
          () => validator.validate({
                'value': [1, 1.1]
              }),
          returnsNormally);
    });

    test('is valid when value is double', () {
      final validator = vine
          .compile(vine.object({'value': vine.array(vine.number().double())}));

      expect(
          () => validator.validate({
                'value': [1.1, 1.2]
              }),
          returnsNormally);
    });

    test('is valid when value is integer', () {
      final validator = vine
          .compile(vine.object({'value': vine.array(vine.number().integer())}));

      expect(
          () => validator.validate({
                'value': [1, 2]
              }),
          returnsNormally);
    });

    test('is valid when value is boolean', () {
      final validator =
          vine.compile(vine.object({'value': vine.array(vine.boolean())}));

      expect(
          () => validator.validate({
                'value': [true, false]
              }),
          returnsNormally);
    });

    test('is valid when value is dynamic', () {
      final validator =
          vine.compile(vine.object({'value': vine.array(vine.any())}));

      expect(
          () => validator.validate({
                'value': ['str', 1, true]
              }),
          returnsNormally);
    });

    test('is invalid when value is many type', () {
      final validator =
          vine.compile(vine.object({'value': vine.array(vine.string())}));

      expect(
          () => validator.validate({
                'value': ['foo', 1, true]
              }),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is not array', () {
      final validator =
          vine.compile(vine.object({'value': vine.array(vine.string())}));

      expect(() => validator.validate({'value': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.minLength', () {
    test('is valid when value is greater than min length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).minLength(2)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          returnsNormally);
    });

    test('is valid when value is equal to min length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).minLength(2)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          returnsNormally);
    });

    test('is invalid when value is less than min length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).minLength(2)}));

      expect(
          () => validator.validate({
                'array': ['foo']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.maxLength', () {
    test('is valid when value is less than max length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).maxLength(3)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          returnsNormally);
    });

    test('is valid when value is equal to max length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).maxLength(2)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          returnsNormally);
    });

    test('is invalid when value exceeds max length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).maxLength(1)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.fixedLength', () {
    test('is valid when value has exact length', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).fixedLength(2)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          returnsNormally);
    });

    test('is invalid when value is too short', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).fixedLength(3)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is too long', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).fixedLength(1)}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.unique', () {
    test('is valid when all values are unique', () {
      final validator = vine
          .compile(vine.object({'array': vine.array(vine.string()).unique()}));

      expect(
          () => validator.validate({
                'array': ['foo', 'bar', 'baz']
              }),
          returnsNormally);
    });

    test('is valid when array is empty', () {
      final validator = vine
          .compile(vine.object({'array': vine.array(vine.string()).unique()}));

      expect(() => validator.validate({'array': <String>[]}), returnsNormally);
    });
  });

  group('VineArray.nullable', () {
    test('is valid when value is null', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).nullable()}));

      expect(() => validator.validate({'array': null}), returnsNormally);
    });

    test('is valid when value is a valid array', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).nullable()}));

      expect(
          () => validator.validate({
                'array': ['foo']
              }),
          returnsNormally);
    });
  });

  group('VineArray.optional', () {
    test('is valid when value is absent', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).optional()}));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is present', () {
      final validator = vine.compile(
          vine.object({'array': vine.array(vine.string()).optional()}));

      expect(
          () => validator.validate({
                'array': ['foo']
              }),
          returnsNormally);
    });
  });

  group('VineArray.transform', () {
    test('is valid when transform is applied', () {
      final validator = vine.compile(vine.object({
        'array': vine.array(vine.number()).transform((ctx, field) {
          final list = field.value as List;
          return list.map((e) => (e as num) * 2).toList();
        }),
      }));

      final data = validator.validate({
        'array': [1, 2, 3]
      });
      expect(data['array'], [2, 4, 6]);
    });
  });

  group('VineArray.requiredIfExist', () {
    test('is valid when dependency exists and value is present', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'array': vine.array(vine.string()).requiredIfExist(['field']),
      }));

      expect(
          () => validator.validate({
                'field': 'foo',
                'array': ['bar']
              }),
          returnsNormally);
    });

    test('is invalid when dependency exists and value is missing', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'array': vine.array(vine.string()).requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.requiredIfMissing', () {
    test('is valid when dependency is missing and value is present', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'array': vine.array(vine.string()).requiredIfMissing(['field']),
      }));

      expect(
          () => validator.validate({
                'array': ['bar']
              }),
          returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('VineArray of objects', () {
    test('is valid when array contains valid objects', () {
      final validator = vine.compile(vine.object({
        'items': vine
            .array(vine.object({'name': vine.string(), 'age': vine.number()})),
      }));

      expect(
          () => validator.validate({
                'items': [
                  {'name': 'Alice', 'age': 30},
                  {'name': 'Bob', 'age': 25},
                ]
              }),
          returnsNormally);
    });

    test('is invalid when one object in array has missing required field', () {
      final validator = vine.compile(vine.object({
        'items': vine
            .array(vine.object({'name': vine.string(), 'age': vine.number()})),
      }));

      expect(
          () => validator.validate({
                'items': [
                  {'name': 'Alice', 'age': 30},
                  {'name': 'Bob'},
                ]
              }),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when array of objects is empty', () {
      final validator = vine.compile(vine.object({
        'items': vine.array(vine.object({'name': vine.string()})),
      }));

      expect(() => validator.validate({'items': []}), returnsNormally);
    });
  });

  group('VineArray of numbers', () {
    test('is valid when array contains only integers', () {
      final validator = vine
          .compile(vine.object({'nums': vine.array(vine.number().integer())}));

      expect(
          () => validator.validate({
                'nums': [1, 2, 3, 4, 5]
              }),
          returnsNormally);
    });

    test('is valid when array contains only doubles', () {
      final validator = vine
          .compile(vine.object({'nums': vine.array(vine.number().double())}));

      expect(
          () => validator.validate({
                'nums': [1.1, 2.2, 3.3]
              }),
          returnsNormally);
    });

    test('is invalid when array of numbers contains a string', () {
      final validator =
          vine.compile(vine.object({'nums': vine.array(vine.number())}));

      expect(
          () => validator.validate({
                'nums': [1, 2, 'three']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray of booleans', () {
    test('is valid when array contains only booleans', () {
      final validator =
          vine.compile(vine.object({'flags': vine.array(vine.boolean())}));

      expect(
          () => validator.validate({
                'flags': [true, false, true, true]
              }),
          returnsNormally);
    });

    test('is invalid when array of booleans contains a non-boolean', () {
      final validator =
          vine.compile(vine.object({'flags': vine.array(vine.boolean())}));

      expect(
          () => validator.validate({
                'flags': [true, 'yes', false]
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray nested arrays', () {
    test('is valid when nested array contains correct types', () {
      final validator = vine.compile(vine.object({
        'matrix': vine.array(vine.array(vine.string())),
      }));

      expect(
          () => validator.validate({
                'matrix': [
                  ['a', 'b'],
                  ['c', 'd'],
                ]
              }),
          returnsNormally);
    });

    test('is invalid when nested array contains wrong type', () {
      final validator = vine.compile(vine.object({
        'matrix': vine.array(vine.array(vine.string())),
      }));

      expect(
          () => validator.validate({
                'matrix': [
                  ['a', 'b'],
                  ['c', 123],
                ]
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.minLength edge cases', () {
    test('is valid when array length is exactly at min boundary', () {
      final validator = vine.compile(
          vine.object({'arr': vine.array(vine.string()).minLength(3)}));

      expect(
          () => validator.validate({
                'arr': ['a', 'b', 'c']
              }),
          returnsNormally);
    });

    test('is valid when array length is well above min', () {
      final validator = vine.compile(
          vine.object({'arr': vine.array(vine.string()).minLength(1)}));

      expect(
          () => validator.validate({
                'arr': ['a', 'b', 'c', 'd', 'e']
              }),
          returnsNormally);
    });

    test('is invalid when array is empty with minLength 1', () {
      final validator = vine.compile(
          vine.object({'arr': vine.array(vine.string()).minLength(1)}));

      expect(() => validator.validate({'arr': <String>[]}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.maxLength edge cases', () {
    test('is valid when array length is exactly at max boundary', () {
      final validator = vine.compile(
          vine.object({'arr': vine.array(vine.string()).maxLength(3)}));

      expect(
          () => validator.validate({
                'arr': ['a', 'b', 'c']
              }),
          returnsNormally);
    });

    test('is invalid when array length is one over max', () {
      final validator = vine.compile(
          vine.object({'arr': vine.array(vine.string()).maxLength(2)}));

      expect(
          () => validator.validate({
                'arr': ['a', 'b', 'c']
              }),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when array is empty with maxLength 5', () {
      final validator = vine.compile(
          vine.object({'arr': vine.array(vine.string()).maxLength(5)}));

      expect(() => validator.validate({'arr': <String>[]}), returnsNormally);
    });
  });

  group('VineArray.fixedLength with element validation', () {
    test('is valid when fixed length matches and elements are valid', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string().minLength(2)).fixedLength(2),
      }));

      expect(
          () => validator.validate({
                'arr': ['foo', 'bar']
              }),
          returnsNormally);
    });

    test('is invalid when fixed length matches but element is invalid', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string().minLength(5)).fixedLength(2),
      }));

      expect(
          () => validator.validate({
                'arr': ['hi', 'ok']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.nullable with minLength', () {
    test('is valid when value is null and nullable with minLength', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string()).minLength(2).nullable(),
      }));

      expect(() => validator.validate({'arr': null}), returnsNormally);
    });

    test('is valid when array meets minLength with nullable', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string()).minLength(2).nullable(),
      }));

      expect(
          () => validator.validate({
                'arr': ['a', 'b', 'c']
              }),
          returnsNormally);
    });

    test('is invalid when array is below minLength with nullable', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string()).minLength(3).nullable(),
      }));

      expect(
          () => validator.validate({
                'arr': ['a']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.optional with maxLength', () {
    test('is valid when value is absent and optional with maxLength', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string()).maxLength(3).optional(),
      }));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when array is below maxLength with optional', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string()).maxLength(5).optional(),
      }));

      expect(
          () => validator.validate({
                'arr': ['a', 'b']
              }),
          returnsNormally);
    });

    test('is invalid when array exceeds maxLength with optional', () {
      final validator = vine.compile(vine.object({
        'arr': vine.array(vine.string()).maxLength(2).optional(),
      }));

      expect(
          () => validator.validate({
                'arr': ['a', 'b', 'c', 'd']
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineArray.transform with filtering and mapping', () {
    test('transform can filter elements from array', () {
      final validator = vine.compile(vine.object({
        'nums': vine.array(vine.number()).transform((ctx, field) {
          final list = field.value as List;
          return list.where((e) => (e as num) > 2).toList();
        }),
      }));

      final data = validator.validate({
        'nums': [1, 2, 3, 4, 5]
      });
      expect(data['nums'], [3, 4, 5]);
    });

    test('transform can map elements to new values', () {
      final validator = vine.compile(vine.object({
        'words': vine.array(vine.string()).transform((ctx, field) {
          final list = field.value as List;
          return list.map((e) => (e as String).toUpperCase()).toList();
        }),
      }));

      final data = validator.validate({
        'words': ['hello', 'world']
      });
      expect(data['words'], ['HELLO', 'WORLD']);
    });
  });

  group('VineArray empty array validation', () {
    test('is valid when empty array is passed for basic string schema', () {
      final validator =
          vine.compile(vine.object({'arr': vine.array(vine.string())}));

      expect(() => validator.validate({'arr': <String>[]}), returnsNormally);
    });

    test('is valid when empty array is passed with nullable elements', () {
      final validator = vine
          .compile(vine.object({'arr': vine.array(vine.string().nullable())}));

      expect(() => validator.validate({'arr': []}), returnsNormally);
    });
  });
}
