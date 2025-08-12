import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

void main() {
  test('is support string validation on top level', () {
    final validator = vine.compile(vine.string());
    expect(() => validator.validate('foo'), returnsNormally);
  });

  group('String validation', () {
    test('valid minLength', () {
      final payload = {'username': 'john'};
      final validator = vine.compile(vine.object({
        'username': vine.string().minLength(3),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid minLength', () {
      final payload = {'username': 'john'};
      final validator = vine.compile(vine.object({
        'username': vine.string().minLength(5),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid maxLength', () {
      final payload = {'username': 'john'};
      final validator = vine.compile(vine.object({
        'username': vine.string().maxLength(10),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid maxLength', () {
      final payload = {'username': 'john'};
      final validator = vine.compile(vine.object({
        'username': vine.string().maxLength(3),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid fixedLength', () {
      final payload = {'username': 'john'};
      final validator = vine.compile(vine.object({
        'username': vine.string().fixedLength(4),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid fixedLength', () {
      final payload = {'username': 'john'};
      final validator = vine.compile(vine.object({
        'username': vine.string().fixedLength(5),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid email', () {
      final payload = {'email': 'john.doe@example.com'};
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid email', () {
      final payload = {'email': 'john.doe'};
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid phone', () {
      final payload = {'phone': '1234567890'};
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid phone', () {
      final payload = {'phone': '123'};
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid custom phone regexp', () {
      final payload = {'phone': '1230025900'};
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(match: RegExp(r'^\d{10}$')),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('valid ipAddress IPv4', () {
      final payload = {'ip': '192.168.1.1'};
      final validator = vine.compile(vine.object({
        'ip': vine.string().ipAddress(version: IpAddressVersion.v4),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid ipAddress IPv4', () {
      final payload = {'ip': '192.168.1.256'};
      final validator = vine.compile(vine.object({
        'ip': vine.string().ipAddress(version: IpAddressVersion.v4),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid url', () {
      final payload = {'url': 'https://example.com'};
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid url', () {
      final payload = {'url': 'example'};
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid alpha', () {
      final payload = {'name': 'JohnDoe'};
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid alpha', () {
      final payload = {'name': 'John123'};
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid alphaNumeric', () {
      final payload = {'username': 'John123'};
      final validator = vine.compile(vine.object({
        'username': vine.string().alphaNumeric(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid alphaNumeric', () {
      final payload = {'username': 'John@123'};
      final validator = vine.compile(vine.object({
        'username': vine.string().alphaNumeric(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid startsWith', () {
      final payload = {'code': 'ABC123'};
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('ABC'),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid startsWith', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('ABC'),
      }));

      final payload = {
        'code': '123ABC',
      };

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('valid endsWith', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().endsWith('XYZ'),
      }));

      final payload = {
        'code': '123XYZ',
      };

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('invalid endsWith', () {
      final payload = {'code': 'XYZ123'};
      final validator = vine.compile(vine.object({
        'code': vine.string().endsWith('XYZ'),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    group('confirmed', () {
      test('is valid when confirmation is the same as original property', () {
        final payload = {
          'password': 'password123',
          'password_confirmation': 'password123',
        };

        final validator = vine.compile(vine.object({
          'password':
              vine.string().confirmed(property: 'password_confirmation'),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test(
          'cannot be valid when confirmation is not the same as original property',
          () {
        final payload = {
          'password': 'password123',
          'password_confirmation': 'password456',
        };

        final validator = vine.compile(vine.object({
          'password':
              vine.string().confirmed(property: 'password_confirmation'),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    test('mutate value with trim', () {
      final payload = {'name': '  John Doe  '};
      final validator = vine.compile(vine.object({
        'name': vine.string().trim(),
      }));

      final data = validator.validate(payload);
      expect(data['name'], 'John Doe');
    });

    test('mutate value with normalizeEmail', () {
      final payload = {'email': 'John.Doe@Example.COM'};
      final validator = vine.compile(vine.object({
        'email': vine.string().normalizeEmail(lowercase: true),
      }));

      final data = validator.validate(payload);
      expect(data['email'], 'john.doe@example.com');
    });

    test('mutate value to upperCase', () {
      final payload = {'name': 'John Doe'};
      final validator = vine.compile(vine.object({
        'name': vine.string().toUpperCase(),
      }));

      final data = validator.validate(payload);
      expect(data['name'], 'JOHN DOE');
    });

    test('mutate value to lowerCase', () {
      final payload = {'name': 'John Doe'};
      final validator = vine.compile(vine.object({
        'name': vine.string().toLowerCase(),
      }));

      final data = validator.validate(payload);
      expect(data['name'], 'john doe');
    });

    test('mutate value to camelCase', () {
      final payload = {'name': 'john doe'};
      final validator = vine.compile(vine.object({
        'name': vine.string().toCamelCase(),
      }));

      final data = validator.validate(payload);
      expect(data['name'], 'johnDoe');
    });

    group('uuid', () {
      test('is valid in v3 version', () {
        final payload = {'uuid': '123e4567-e89b-12d3-a456-426614174000'};
        final validator = vine.compile(vine.object({
          'uuid': vine.string().uuid(version: UuidVersion.v3),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('is valid in v4 version', () {
        final payload = {'uuid': '123e4567-e89b-12d3-a456-426614174000'};
        final validator = vine.compile(vine.object({
          'uuid': vine.string().uuid(version: UuidVersion.v4),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('is valid in v5 version', () {
        final payload = {'uuid': '123e4567-e89b-12d3-a456-426614174000'};
        final validator = vine.compile(vine.object({
          'uuid': vine.string().uuid(version: UuidVersion.v5),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be invalid with a bad format', () {
        final payload = {'uuid': '123e4567-e89b-12d3-a456-42661417400'};
        final validator = vine.compile(vine.object({
          'uuid': vine.string().uuid(version: UuidVersion.v4),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('credit card', () {
      test('is valid when using good format', () {
        final payload = {'card': '4111111111111111'};
        final validator = vine.compile(vine.object({
          'card': vine.string().isCreditCard(),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be invalid with a bad format', () {
        final payload = {'card': '1234567890123456'};
        final validator = vine.compile(vine.object({
          'card': vine.string().isCreditCard(),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    test('can be nullable', () {
      final payload = {'name': null};
      final validator = vine.compile(vine.object({
        'name': vine.string().nullable(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be nullable', () {
      final payload = {'name': null};
      final validator = vine.compile(vine.object({
        'name': vine.string(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('can be optional', () {
      final payload = <String, dynamic>{};
      final validator = vine.compile(vine.object({
        'name': vine.string().optional(),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be optional', () {
      final payload = <String, dynamic>{};
      final validator = vine.compile(vine.object({
        'name': vine.string(),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('VineString Validator with Chained Rules', () {
    test('can be valid with [email, minLength, maxLength] rules', () {
      final payload = {'email': 'john.doe@example.com'};
      final validator = vine.compile(vine.object({
        'email': vine.string().email().minLength(10).maxLength(50),
      }));

      expect(() => validator.validate(payload), returnsNormally);
    });

    test('cannot be too short with [email, minLength, maxLength] rules', () {
      final payload = {'email': 'john@doe.com'};
      final validator = vine.compile(vine.object({
        'email': vine.string().email().minLength(20).maxLength(50),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    test('cannot be too long with [email, minLength, maxLength] rules', () {
      final payload = {'email': 'john.doe.very.long.email@example.com'};
      final validator = vine.compile(vine.object({
        'email': vine.string().email().minLength(10).maxLength(20),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    group('alphaNumeric', () {
      test('can be valid with [alphaNumeric, startsWith, endsWith] rules', () {
        final payload = {'code': 'ABC123XYZ'};
        final validator = vine.compile(vine.object({
          'code':
              vine.string().alphaNumeric().startsWith('ABC').endsWith('XYZ'),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test(
          'cannot have a wrong start with [alphaNumeric, startsWith, endsWith] rules',
          () {
        final payload = {'code': '123ABCXYZ'};
        final validator = vine.compile(vine.object({
          'code':
              vine.string().alphaNumeric().startsWith('ABC').endsWith('XYZ'),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });

      test(
          'cannot have a wrong end with [alphaNumeric, startsWith, endsWith] rules',
          () {
        final payload = {'code': 'ABC123123'};
        final validator = vine.compile(vine.object({
          'code':
              vine.string().alphaNumeric().startsWith('ABC').endsWith('XYZ'),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('url', () {
      test('can be present [url, optional, nullable] rules', () {
        final payload = {'website': 'https://example.com'};
        final validator = vine.compile(vine.object({
          'website': vine.string().url().optional().nullable(),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('can be null with [url, optional, nullable] rules', () {
        final payload = {'website': null};
        final validator = vine.compile(vine.object({
          'website': vine.string().url().optional().nullable(),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('can be absent with [url, optional, nullable] rules', () {
        final validator = vine.compile(vine.object({
          'website': vine.string().url().optional().nullable(),
        }));

        final payload = <String, dynamic>{};

        expect(() => validator.validate(payload), returnsNormally);
      });
    });

    test('can be valid with [trim, toLowerCase, minLength] rules', () {
      final payload = {'username': '  JohnDoe  '};
      final validator = vine.compile(vine.object({
        'username': vine.string().trim().toLowerCase().minLength(5),
      }));

      final data = validator.validate(payload);
      expect(data['username'], 'johndoe');
    });

    test('is too short after trim with [trim, toLowerCase, minlength] rules',
        () {
      final payload = {'username': '  John  '};
      final validator = vine.compile(vine.object({
        'username': vine.string().trim().toLowerCase().minLength(10),
      }));

      expect(() => validator.validate(payload),
          throwsA(isA<VineValidationException>()));
    });

    group('uuid', () {
      test('can be valid with [uuid, fixedLength, nullable] rules', () {
        final payload = {'uuid': '123e4567-e89b-12d3-a456-426614174000'};
        final validator = vine.compile(vine.object({
          'uuid': vine
              .string()
              .uuid(version: UuidVersion.v4)
              .fixedLength(36)
              .nullable(),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test(
          'cannot have a wrong length with [uuid, fixedLength, nullable] rules',
          () {
        final payload = {'uuid': '123e4567-e89b-12d3-a456-42661417400'};
        final validator = vine.compile(vine.object({
          'uuid': vine
              .string()
              .uuid(version: UuidVersion.v4)
              .fixedLength(36)
              .nullable(),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('credit card', () {
      test('can be valid with [isCreditCard, optional, trim] rules', () {
        final payload = {'card': ' 4111111111111111 '};
        final validator = vine.compile(vine.object({
          'card': vine.string().isCreditCard().optional().trim(),
        }));

        final data = validator.validate(payload);
        expect(data['card'], '4111111111111111');
      });

      test('cannot be invalid card with [trim, isCreditCard, optional] rules',
          () {
        final payload = {'card': ' 1234567890123456 '};
        final validator = vine.compile(vine.object({
          'card': vine.string().trim().isCreditCard().optional(),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('confirmed', () {
      test('can be valid with [trim, toLowerCase, confirmed] rules', () {
        final payload = {
          'password': '  Password123  ',
          'password_confirmation': 'password123',
        };

        final validator = vine.compile(vine.object({
          'password': vine
              .string()
              .trim()
              .toLowerCase()
              .confirmed(property: 'password_confirmation'),
        }));

        final data = validator.validate(payload);
        expect(data['password'], 'password123');
      });
    });

    group('sameAs', () {
      test('can be valid', () {
        final payload = {
          'first_field': 'foo',
          'second_field': 'foo',
        };

        final validator = vine.compile(vine.object({
          'first_field': vine.string(),
          'second_field': vine.string().sameAs('first_field'),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('should be valid in nested object when values are identiques', () {
        final payload = {
          'obj': {
            'first_field': 'foo',
            'second_field': 'foo',
          },
        };

        final validator = vine.compile(vine.object({
          'obj': vine.object({
            'first_field': vine.string(),
            'second_field': vine.string().sameAs('first_field'),
          }),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be valid in nested object when values are different', () {
        final payload = {
          'obj': {
            'first_field': 'foo',
            'second_field': 'bar',
          },
        };

        final validator = vine.compile(vine.object({
          'obj': vine.object({
            'first_field': vine.string(),
            'second_field': vine.string().sameAs('first_field'),
          }),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('inList', () {
      test('should be valid when value is include in values', () {
        final payload = {
          'field': 'foo',
        };

        final validator = vine.compile(vine.object({
          'field': vine.string().inList(['foo', 'bar', 'baz']),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be valid when values are different', () {
        final payload = {'field': 'hello'};

        final validator = vine.compile(vine.object({
          'field': vine.string().inList(['foo', 'bar', 'baz']),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('required if exists', () {
      test('should be valid when field exists', () {
        final payload = {
          'field': 'foo',
          'other_field': 'bar',
        };

        final validator = vine.compile(vine.object({
          'field': vine.string(),
          'other_field': vine.string().requiredIfExist(['field']),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be valid when field does not exist', () {
        final payload = {
          'field': 'foo',
        };

        final validator = vine.compile(vine.object({
          'field': vine.string().optional(),
          'other_field': vine.string().requiredIfExist(['field']),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });

      test('should be valid when field does not exist but value is provided',
          () {
        final payload = <String, dynamic>{
          'other_field': 'bar',
        };

        final validator = vine.compile(vine.object({
          'other_field': vine.string().minLength(1).requiredIfExist(['field']),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be valid when field does not exist', () {
        final payload = <String, dynamic>{
          'field': 'foo',
        };

        final validator = vine.compile(vine.object({
          'other_field': vine.string().minLength(1).requiredIfExist(['field']),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });

      test('can be optional when required fields has one or many missing', () {
        final payload = <String, dynamic>{};

        final validator = vine.compile(vine.object({
          'field': vine
              .string()
              .optional()
              .requiredIfExist(['firstField', 'secondField']),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be optional when required fields exists', () {
        final payload = <String, dynamic>{
          'firstField': 'foo',
          'secondField': 'bar',
        };

        final validator = vine.compile(vine.object({
          'field': vine.string().requiredIfExist(['firstField', 'secondField']),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });

      //
      test('should be valid when field is missing', () {
        final payload = {
          'other_field': 'bar',
        };

        final validator = vine.compile(vine.object({
          'field': vine.string().optional(),
          'other_field': vine.string().requiredIfMissing(['field']),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be valid when field exists exist', () {
        final payload = {
          'field': 'foo',
        };

        final validator = vine.compile(vine.object({
          'field': vine.string(),
          'other_field': vine.string().requiredIfMissing(['field']),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });

      test('can be optional when required fields has one or many exists', () {
        final payload = <String, dynamic>{};

        final validator = vine.compile(vine.object({
          'field': vine
              .string()
              .optional()
              .requiredIfAnyMissing(['firstField', 'secondField']),
        }));

        expect(() => validator.validate(payload), returnsNormally);
      });

      test('cannot be optional when required fields are missing', () {
        final payload = <String, dynamic>{};

        final validator = vine.compile(vine.object({
          'field': vine.string().requiredIfExist(['firstField', 'secondField']),
        }));

        expect(() => validator.validate(payload),
            throwsA(isA<VineValidationException>()));
      });
    });
  });
}
