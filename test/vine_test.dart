import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  group('Vine.validate', () {
    test('is valid with direct validation without compile', () {
      final schema = vine.object({
        'name': vine.string(),
        'age': vine.number(),
      });

      final data = vine.validate({'name': 'John', 'age': 25}, schema);
      expect(data['name'], 'John');
      expect(data['age'], 25);
    });

    test('throws on invalid data with direct validation', () {
      final schema = vine.object({
        'name': vine.string(),
      });

      expect(() => vine.validate({'name': 123}, schema),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Validator.tryValidate', () {
    test('returns (null, data) on valid input', () {
      final validator = vine.compile(vine.object({
        'name': vine.string(),
      }));

      final (error, data) = validator.tryValidate({'name': 'John'});
      expect(error, isNull);
      expect(data, isNotNull);
      expect((data as Map)['name'], 'John');
    });

    test('returns (exception, null) on invalid input', () {
      final validator = vine.compile(vine.object({
        'name': vine.string(),
      }));

      final (error, data) = validator.tryValidate({'name': 123});
      expect(error, isA<VineValidationException>());
      expect(data, isNull);
    });
  });

  group('Validator.validate multiple times', () {
    test('reporter is cleared between calls', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().minLength(3),
      }));

      expect(() => validator.validate({'name': 'John'}), returnsNormally);
      expect(() => validator.validate({'name': 'Jane'}), returnsNormally);
    });
  });

  group('Validator.schema', () {
    test('returns the compiled schema', () {
      final validator = vine.compile(vine.object({
        'name': vine.string(),
      }));

      expect(validator.schema, isNotNull);
    });
  });

  group('Vine.validate complex', () {
    test('is valid with complex nested schema', () {
      final schema = vine.object({
        'user': vine.object({
          'name': vine.string().minLength(2),
          'age': vine.number().min(0),
        }),
        'tags': vine.array(vine.string()),
      });

      final data = vine.validate({
        'user': {'name': 'John', 'age': 25},
        'tags': ['admin', 'user'],
      }, schema);

      expect((data['user'] as Map)['name'], 'John');
      expect((data['tags'] as List).length, 2);
    });

    test('throws on invalid nested field', () {
      final schema = vine.object({
        'user': vine.object({
          'name': vine.string(),
          'email': vine.string().email(),
        }),
      });

      expect(
          () => vine.validate({
                'user': {'name': 'John', 'email': 'not-an-email'}
              }, schema),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Validator.tryValidate detailed', () {
    test('returns data map on valid input', () {
      final validator = vine.compile(vine.object({
        'name': vine.string(),
        'age': vine.number(),
      }));

      final (error, data) = validator.tryValidate({'name': 'Jane', 'age': 30});
      expect(error, isNull);
      expect(data, isNotNull);
      expect((data as Map)['name'], 'Jane');
      expect(data['age'], 30);
    });

    test('returns error with details on invalid input', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().minLength(5),
        'age': vine.number(),
      }));

      final (error, data) = validator.tryValidate({'name': 'Jo', 'age': 30});
      expect(error, isA<VineValidationException>());
      expect(data, isNull);
      expect(error!.message['errors'], isNotEmpty);
    });
  });

  group('Validator reuse', () {
    test('compile once validate many valid payloads', () {
      final validator = vine.compile(vine.object({
        'name': vine.string(),
      }));

      expect(() => validator.validate({'name': 'Alice'}), returnsNormally);
      expect(() => validator.validate({'name': 'Bob'}), returnsNormally);
      expect(() => validator.validate({'name': 'Charlie'}), returnsNormally);
    });

    test('compile once validate returns correct data each time', () {
      final validator = vine.compile(vine.object({
        'name': vine.string(),
        'age': vine.number(),
      }));

      final data1 = validator.validate({'name': 'Alice', 'age': 25});
      expect(data1['name'], 'Alice');
      expect(data1['age'], 25);

      final data2 = validator.validate({'name': 'Bob', 'age': 30});
      expect(data2['name'], 'Bob');
      expect(data2['age'], 30);
    });
  });

  group('Top-level schemas', () {
    test('validate top-level string', () {
      final validator = vine.compile(vine.string());
      expect(() => validator.validate('hello'), returnsNormally);
    });

    test('validate top-level number', () {
      final validator = vine.compile(vine.number());
      expect(() => validator.validate(42), returnsNormally);
    });
  });
}
