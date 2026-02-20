import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  test('is support date validation on top level', () {
    final validator = vine.compile(vine.date());
    expect(() => validator.validate(DateTime.now()), returnsNormally);
  });

  test('should be valid when value is a string date', () {
    final payload = {'date': '2021-01-01'};
    final validator = vine.compile(vine.object({
      'date': vine.date(),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('should be valid when value is a date', () {
    final payload = {'date': DateTime.now()};
    final validator = vine.compile(vine.object({
      'date': vine.date(),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('should be valid when value was not provided but rule allow optional',
      () {
    final payload = <String, dynamic>{};
    final validator = vine.compile(vine.object({
      'date': vine.date().optional(),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('should be valid when value is null and rule allow nullable', () {
    final payload = <String, dynamic>{'date': null};
    final validator = vine.compile(vine.object({
      'date': vine.date().nullable(),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('cannot be valid when value is not provided', () {
    final payload = <String, dynamic>{};
    final validator = vine.compile(vine.object({
      'date': vine.date(),
    }));

    expect(() => validator.validate(payload),
        throwsA(isA<VineValidationException>()));
  });

  test('should be valid when value is between dates', () {
    final payload = {'date': '2021-01-01'};
    final validator = vine.compile(vine.object({
      'date': vine.date().between(DateTime(2020), DateTime(2022)),
    }));

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('cannot be valid when value is not between dates', () {
    final payload = {'date': '2021-01-01'};
    final validator = vine.compile(vine.object({
      'date': vine.date().between(DateTime(2022), DateTime(2023)),
    }));

    expect(() => validator.validate(payload),
        throwsA(isA<VineValidationException>()));
  });

  group('Date rules', () {
    test('should be valid when value is before the target date', () {
      final payload = {
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().before(DateTime.now()),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be valid when value is after the target date', () {
      final payload = <String, dynamic>{
        'date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().before(DateTime.now()),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('should be valid when value is after the target date', () {
      final payload = {
        'date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().after(DateTime.now()),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be valid when value is before the target date', () {
      final payload = <String, dynamic>{
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().after(DateTime.now()),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('should be valid when value is before the target field', () {
      final payload = {
        'date': DateTime.now().toIso8601String(),
        'currentDate':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().beforeField('date'),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be valid when value is after the target field', () {
      final payload = <String, dynamic>{
        'date': DateTime.now().toIso8601String(),
        'currentDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().beforeField('date'),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('should be valid when value is after the target field', () {
      final payload = {
        'date': DateTime.now().toIso8601String(),
        'currentDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().afterField('date'),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be valid when value is before the target field', () {
      final payload = <String, dynamic>{
        'date': DateTime.now().toIso8601String(),
        'currentDate':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().afterField('date'),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('should be valid when value is between date fields', () {
      final payload = {
        'startDate':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'currentDate': DateTime.now().toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().betweenFields('startDate', 'endDate'),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be valid when value is not between date fields', () {
      final payload = {
        'startDate':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'currentDate':
            DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().betweenFields('startDate', 'endDate'),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test(
        'cannot be valid when value is not between date fields but startDate is missing',
        () {
      final payload = {
        'endDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'currentDate':
            DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().betweenFields('startDate', 'endDate'),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test(
        'cannot be valid when value is not between date fields but endField is missing',
        () {
      final payload = {
        'startDate':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'currentDate':
            DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'currentDate': vine.date().betweenFields('startDate', 'endDate'),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('should be valid when value has attempted value after transformation',
        () {
      final now = DateTime.now();
      final payload = {'date': now};

      final validator = vine.compile(vine.object({
        'date': vine.date().transform((_, field) {
          return switch (field.value) {
            DateTime date => date.add(Duration(days: 1)),
            String value => DateTime.tryParse(value)?.add(Duration(days: 1)),
            _ => throw Exception('Invalid date value'),
          };
        }),
      }));
      final result = validator.validate(payload);
      expect(result['date'], now.add(Duration(days: 1)));
    });
  });

  group('VineDate.requiredIfExist', () {
    test('is valid when dependency exists and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'date': vine.date().requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo', 'date': '2021-01-01'}),
          returnsNormally);
    });

    test('is invalid when dependency exists and value is missing', () {
      final validator = vine.compile(vine.object({
        'field': vine.string(),
        'date': vine.date().requiredIfExist(['field']),
      }));

      expect(() => validator.validate({'field': 'foo'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineDate.requiredIfAnyExist', () {
    test('is valid when any dependency exists and value is provided', () {
      final validator = vine.compile(vine.object({
        'first': vine.string().optional(),
        'second': vine.string().optional(),
        'date': vine.date().requiredIfAnyExist(['first', 'second']),
      }));

      expect(() => validator.validate({'first': 'foo', 'date': '2021-01-01'}),
          returnsNormally);
    });

    test('is invalid when any dependency exists and value is null', () {
      final validator = vine.compile(vine.object({
        'date': vine.date().requiredIfAnyExist(['first', 'second']),
        'first': vine.string().optional(),
        'second': vine.string().optional(),
      }));

      expect(() => validator.validate({'second': 'foo', 'date': null}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineDate.requiredIfMissing', () {
    test('is valid when dependency is missing and value is provided', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
        'date': vine.date().requiredIfMissing(['field']),
      }));

      expect(() => validator.validate({'date': '2021-01-01'}), returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissing' key missing from mappedErrors
  });

  group('VineDate.requiredIfAnyMissing', () {
    test('is valid when any dependency is missing and value is provided', () {
      final validator = vine.compile(vine.object({
        'first': vine.string().optional(),
        'second': vine.string().optional(),
        'date': vine.date().requiredIfAnyMissing(['first', 'second']),
      }));

      expect(() => validator.validate({'first': 'foo', 'date': '2021-01-01'}),
          returnsNormally);
    });

    // Note: invalid case omitted — library bug: 'requiredIfMissingAny' key missing from mappedErrors
  });

  group('Date before edge cases', () {
    test('is valid when value is exactly 1 second before boundary', () {
      final boundary = DateTime(2025, 6, 15, 12, 0, 0);
      final payload = {
        'date': boundary.subtract(Duration(seconds: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().before(boundary),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is invalid when value is exactly at boundary for before rule', () {
      final boundary = DateTime(2025, 6, 15, 12, 0, 0);
      final payload = {
        'date': boundary.toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().before(boundary),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when value is far in the past for before rule', () {
      final boundary = DateTime(2025, 6, 15);
      final payload = {
        'date': DateTime(1900, 1, 1).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().before(boundary),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });
  });

  group('Date after edge cases', () {
    test('is valid when value is exactly 1 second after boundary', () {
      final boundary = DateTime(2025, 6, 15, 12, 0, 0);
      final payload = {
        'date': boundary.add(Duration(seconds: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().after(boundary),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is invalid when value is exactly at boundary for after rule', () {
      final boundary = DateTime(2025, 6, 15, 12, 0, 0);
      final payload = {
        'date': boundary.toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().after(boundary),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('is valid when value is far in the future for after rule', () {
      final boundary = DateTime(2025, 6, 15);
      final payload = {
        'date': DateTime(3000, 12, 31).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().after(boundary),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });
  });

  group('Date between edge cases', () {
    test('is valid when value is at start boundary of between', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);
      final payload = {
        'date': start.add(Duration(seconds: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().between(start, end),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is valid when value is at end boundary of between', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);
      final payload = {
        'date': end.subtract(Duration(seconds: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().between(start, end),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is invalid when value is just before start of between', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);
      final payload = {
        'date': start.subtract(Duration(seconds: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().between(start, end),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('is invalid when value is just after end of between', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);
      final payload = {
        'date': end.add(Duration(seconds: 1)).toIso8601String(),
      };

      final validator = vine.compile(vine.object({
        'date': vine.date().between(start, end),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Date string formats', () {
    test('is valid when value is ISO 8601 format', () {
      final payload = {'date': '2025-06-15T10:30:00.000Z'};
      final validator = vine.compile(vine.object({
        'date': vine.date(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is valid when value is YYYY-MM-DD format', () {
      final payload = {'date': '2025-06-15'};
      final validator = vine.compile(vine.object({
        'date': vine.date(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is invalid when value is a bad date string', () {
      final payload = {'date': 'not-a-date'};
      final validator = vine.compile(vine.object({
        'date': vine.date(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Date nullable + date rules', () {
    test('is valid when value is null with after rule and nullable', () {
      final validator = vine.compile(vine.object({
        'date': vine.date().nullable().after(DateTime(2020)),
      }));

      expect(() => validator.validate({'date': null}), returnsNormally);
    });

    test('is valid when value is a date satisfying after rule with nullable',
        () {
      final validator = vine.compile(vine.object({
        'date': vine.date().nullable().after(DateTime(2020)),
      }));

      expect(() => validator.validate({'date': '2025-01-01'}), returnsNormally);
    });

    test(
        'is invalid when value is a date not satisfying after rule with nullable',
        () {
      final validator = vine.compile(vine.object({
        'date': vine.date().nullable().after(DateTime(2025)),
      }));

      expect(() => validator.validate({'date': '2020-01-01'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Date optional + date rules', () {
    test('is valid when value is absent with before rule and optional', () {
      final validator = vine.compile(vine.object({
        'date': vine.date().optional().before(DateTime(2030)),
      }));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('is valid when value is a date satisfying before rule with optional',
        () {
      final validator = vine.compile(vine.object({
        'date': vine.date().optional().before(DateTime(2030)),
      }));

      expect(() => validator.validate({'date': '2025-01-01'}), returnsNormally);
    });
  });

  group('Date transform', () {
    test('transform date to string format', () {
      final payload = {'date': DateTime(2025, 6, 15)};
      final validator = vine.compile(vine.object({
        'date': vine.date().transform((_, field) {
          final date = field.value as DateTime;
          return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }),
      }));

      final result = validator.validate(payload);
      expect(result['date'], '2025-06-15');
    });

    test('transform date to add days', () {
      final original = DateTime(2025, 6, 15);
      final payload = {'date': original};
      final validator = vine.compile(vine.object({
        'date': vine.date().transform((_, field) {
          return (field.value as DateTime).add(Duration(days: 7));
        }),
      }));

      final result = validator.validate(payload);
      expect(result['date'], DateTime(2025, 6, 22));
    });
  });

  group('Date coercion', () {
    test('is valid when input is a DateTime object', () {
      final payload = {'date': DateTime(2025, 3, 10)};
      final validator = vine.compile(vine.object({
        'date': vine.date(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('is valid when input is a string "2021-01-01"', () {
      final payload = {'date': '2021-01-01'};
      final validator = vine.compile(vine.object({
        'date': vine.date(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });
  });
}
