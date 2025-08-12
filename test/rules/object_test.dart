import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  group('Object validation', () {
    test('is valid when value is object', () {
      final validator = vine.compile(vine.object({
        'obj': vine.object({}),
      }));

      expect(
          () => validator.validate({
                'obj': {'foo': 'bar'}
              }),
          returnsNormally);
    });

    test('is valid when value is object and non validated values are deletes',
        () {
      final payload = {
        'firstname': 'John',
        'lastname': 'Doe',
        'age': 25,
      };

      final validator = vine.compile(vine.object({
        'firstname': vine.string().minLength(2).maxLength(255),
        'lastname': vine.string().minLength(2).maxLength(255),
      }));

      expect(() => validator.validate(payload), returnsNormally);

      final data = validator.validate(payload);
      payload.remove('age');

      expect(data, payload);
    });

    test('is valid when value is object and non validated values are deletes',
        () {
      final payload = {
        'obj': {
          'firstname': 'John',
          'lastname': 'Doe',
          'age': 25,
        }
      };

      final validator = vine.compile(vine.object({
        'obj': vine.object({
          'firstname': vine.string().minLength(2).maxLength(255),
          'lastname': vine.string().minLength(2).maxLength(255),
        }),
      }));

      final data = validator.validate(payload);

      (payload['obj'] as Map<String, dynamic>).remove('age');
      expect(data, payload);
    });

    test('can be composable', () {
      final payload = {
        'user': {
          'firstname': 'John',
          'lastname': 'Doe',
          'email': 'john.doe@foo.bar',
          'age': 25,
        },
        'roles': [
          {'name': 'admin role', 'description': 'Administrator'},
          {'name': 'user role', 'description': 'User'},
        ],
      };

      final identitySchema = vine.object({
        'firstname': vine.string().minLength(2).maxLength(255),
        'lastname': vine.string().minLength(2).maxLength(255),
      });

      final userSchema = vine.object({
        ...identitySchema.properties,
        'email': vine.string().email(),
        'age': vine.number().integer().min(18).max(100),
      });

      final roleSchema = vine.object({
        'name': vine.string().minLength(2).maxLength(255),
        'description': vine.string().minLength(2).maxLength(255),
      });

      final validator = vine.compile(vine.object({
        'user': userSchema,
        'roles': vine.array(roleSchema),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be composable with bad data structure', () {
      final payload = {
        'firstname': 'John',
        'lastname': 'Doe',
        'email': 'john.doe@foo.bar',
        'age': 25,
        'roles': [
          {'name': 'admin role', 'description': 'Administrator'},
          {'name': 'user role', 'description': 'User'},
        ],
      };

      final identitySchema = vine.object({
        'firstname': vine.string().minLength(2).maxLength(255),
        'lastname': vine.string().minLength(2).maxLength(255),
      });

      final userSchema = vine.object({
        ...identitySchema.properties,
        'email': vine.string().email(),
        'age': vine.number().integer().min(18).max(100),
      });

      final roleSchema = vine.object({
        'name': vine.string().minLength(2).maxLength(255),
        'description': vine.string().minLength(2).maxLength(255),
      });

      final validator = vine.compile(vine.object({
        'user': userSchema.optional(),
        'roles': vine.array(roleSchema),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Group object validation', () {
    test(
        'cannot be valid when object schema is called and email field is missing',
        () {
      final payload = {
        'hasField': true,
        'user': {
          'firstname': 'John',
          'lastname': 'Doe',
        }
      };

      final validator = vine.compile(vine.object({
        'user': vine.group((group) {
          group.when((data) => data.containsKey('hasField'), {
            'firstname': vine.string(),
            'lastname': vine.string(),
            'emaila': vine.string().email(),
          });
        }),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test(
        'should be valid when object schema is called and email field is present',
        () {
      final payload = {
        'user': {
          'firstname': 'John',
          'lastname': 'Doe',
        }
      };

      final validator = vine.compile(vine.object({
        'user': vine.group((group) {
          group.when((data) => data.containsKey('hasField'), {
            'firstname': vine.string(),
            'lastname': vine.string(),
            'email': vine.string().email(),
          });
        }),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test(
        'cannot be valid when object schema is called and email field is missing',
        () {
      final payload = {
        'hasField': true,
        'user': {
          'firstname': 'John',
          'lastname': 'Doe',
        }
      };

      final validator = vine.compile(vine.object({
        'user': vine.group((group) {
          group.when((data) => data.containsKey('hasField'), {
            'firstname': vine.string(),
            'lastname': vine.string(),
          });
        }).otherwise((ctx, field) {
          ctx.errorReporter.report('foo', field.customKeys, 'Unknown error');
        })
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });
  });
}
