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
}
