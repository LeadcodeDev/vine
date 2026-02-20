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

    group('regex', () {
      test('is valid when value matches pattern', () {
        final validator = vine.compile(vine.object({
          'code': vine.string().regex(RegExp(r'^[A-Z]{3}-\d{3}$')),
        }));

        expect(() => validator.validate({'code': 'ABC-123'}), returnsNormally);
      });

      test('is invalid when value does not match pattern', () {
        final validator = vine.compile(vine.object({
          'code': vine.string().regex(RegExp(r'^[A-Z]{3}-\d{3}$')),
        }));

        expect(() => validator.validate({'code': 'abc-123'}),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('notSameAs', () {
      test('is valid when values are different', () {
        final validator = vine.compile(vine.object({
          'password': vine.string(),
          'username': vine.string().notSameAs('password'),
        }));

        expect(
            () => validator.validate({
                  'password': 'secret123',
                  'username': 'john',
                }),
            returnsNormally);
      });

      test('is invalid when values are identical', () {
        final validator = vine.compile(vine.object({
          'password': vine.string(),
          'username': vine.string().notSameAs('password'),
        }));

        expect(
            () => validator.validate({
                  'password': 'same',
                  'username': 'same',
                }),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('notInList', () {
      test('is valid when value is not in list', () {
        final validator = vine.compile(vine.object({
          'role': vine.string().notInList(['admin', 'superadmin']),
        }));

        expect(() => validator.validate({'role': 'user'}), returnsNormally);
      });

      test('is invalid when value is in list', () {
        final validator = vine.compile(vine.object({
          'role': vine.string().notInList(['admin', 'superadmin']),
        }));

        expect(() => validator.validate({'role': 'admin'}),
            throwsA(isA<VineValidationException>()));
      });
    });

    group('requiredIfAnyExist', () {
      test('is valid when any dependency exists and value is provided', () {
        final validator = vine.compile(vine.object({
          'first': vine.string().optional(),
          'second': vine.string().optional(),
          'field': vine.string().requiredIfAnyExist(['first', 'second']),
        }));

        expect(
            () => validator.validate({
                  'first': 'foo',
                  'field': 'bar',
                }),
            returnsNormally);
      });

      test('is invalid when any dependency exists and value is null', () {
        final validator = vine.compile(vine.object({
          'field': vine.string().requiredIfAnyExist(['first', 'second']),
          'first': vine.string().optional(),
          'second': vine.string().optional(),
        }));

        expect(() => validator.validate({'second': 'foo', 'field': null}),
            throwsA(isA<VineValidationException>()));
      });

      test('is valid when no dependency exists', () {
        final validator = vine.compile(vine.object({
          'first': vine.string().optional(),
          'second': vine.string().optional(),
          'field':
              vine.string().optional().requiredIfAnyExist(['first', 'second']),
        }));

        expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
      });
    });

    group('transform', () {
      test('is valid when custom transform is applied', () {
        final validator = vine.compile(vine.object({
          'name': vine.string().transform((ctx, field) {
            return '${field.value}_transformed';
          }),
        }));

        final data = validator.validate({'name': 'hello'});
        expect(data['name'], 'hello_transformed');
      });
    });

    group('toCamelCase edge cases', () {
      test('mutate value with hyphen separator', () {
        final validator = vine.compile(vine.object({
          'name': vine.string().toCamelCase(),
        }));

        final data = validator.validate({'name': 'hello-world'});
        expect(data['name'], 'helloWorld');
      });

      test('mutate value with underscore separator', () {
        final validator = vine.compile(vine.object({
          'name': vine.string().toCamelCase(),
        }));

        final data = validator.validate({'name': 'hello_world'});
        expect(data['name'], 'helloWorld');
      });
    });
  });

  group('Email edge cases', () {
    test('valid email with subdomain', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate({'email': 'user@mail.example.com'}),
          returnsNormally);
    });

    test('valid email with plus tag', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate({'email': 'user+tag@example.com'}),
          returnsNormally);
    });

    test('invalid email missing @ symbol', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate({'email': 'userexample.com'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid email missing domain', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate({'email': 'user@'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid email with spaces', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate({'email': 'user @example.com'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid email with no TLD', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email(),
      }));

      expect(() => validator.validate({'email': 'user@localhost'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Phone edge cases', () {
    test('valid phone with international format', () {
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(
          () => validator.validate({'phone': '+33612345678'}), returnsNormally);
    });

    test('valid phone with country code and dash separator', () {
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(() => validator.validate({'phone': '+1-555-1234567'}),
          returnsNormally);
    });

    test('valid phone with dot separator', () {
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(() => validator.validate({'phone': '+33.6.12345678'}),
          returnsNormally);
    });

    test('invalid phone too short', () {
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(() => validator.validate({'phone': '12'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid phone with letters', () {
      final validator = vine.compile(vine.object({
        'phone': vine.string().phone(),
      }));

      expect(() => validator.validate({'phone': 'abcdefghij'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('IP Address IPv6', () {
    test('valid IPv6 address', () {
      final validator = vine.compile(vine.object({
        'ip': vine.string().ipAddress(version: IpAddressVersion.v6),
      }));

      expect(
          () => validator
              .validate({'ip': '2001:0db8:85a3:0000:0000:8a2e:0370:7334'}),
          returnsNormally);
    });

    test('valid IPv6 loopback address', () {
      final validator = vine.compile(vine.object({
        'ip': vine.string().ipAddress(version: IpAddressVersion.v6),
      }));

      expect(() => validator.validate({'ip': '::1'}), returnsNormally);
    });

    test('invalid IPv6 address', () {
      final validator = vine.compile(vine.object({
        'ip': vine.string().ipAddress(version: IpAddressVersion.v6),
      }));

      expect(() => validator.validate({'ip': '192.168.1.1'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid IPv6 with random string', () {
      final validator = vine.compile(vine.object({
        'ip': vine.string().ipAddress(version: IpAddressVersion.v6),
      }));

      expect(() => validator.validate({'ip': 'not-an-ip'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('URL edge cases', () {
    test('valid url with port', () {
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(() => validator.validate({'url': 'https://example.com:8080'}),
          returnsNormally);
    });

    test('valid url with path', () {
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(
          () => validator.validate({'url': 'https://example.com/path/to/page'}),
          returnsNormally);
    });

    test('valid url with query parameters', () {
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(
          () => validator
              .validate({'url': 'https://example.com/search?q=test&page=1'}),
          returnsNormally);
    });

    test('invalid url with spaces', () {
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(() => validator.validate({'url': 'https://exam ple.com'}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid ftp url with default protocol list', () {
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(() => validator.validate({'url': 'ftp://files.example.com/pub'}),
          returnsNormally);
    });

    test('valid url with fragment', () {
      final validator = vine.compile(vine.object({
        'url': vine.string().url(),
      }));

      expect(
          () => validator.validate({'url': 'https://example.com/page#section'}),
          returnsNormally);
    });
  });

  group('Alpha edge cases', () {
    test('valid alpha lowercase only', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate({'name': 'abcdefghij'}), returnsNormally);
    });

    test('valid alpha uppercase only', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate({'name': 'ABCDEFGHIJ'}), returnsNormally);
    });

    test('invalid alpha with spaces', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate({'name': 'John Doe'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid alpha with numbers', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate({'name': 'abc123'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid alpha with special characters', () {
      final validator = vine.compile(vine.object({
        'name': vine.string().alpha(),
      }));

      expect(() => validator.validate({'name': 'hello!'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('AlphaNumeric edge cases', () {
    test('valid alphaNumeric mixed letters and numbers', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().alphaNumeric(),
      }));

      expect(
          () => validator.validate({'code': 'abc123DEF456'}), returnsNormally);
    });

    test('valid alphaNumeric numbers only', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().alphaNumeric(),
      }));

      expect(() => validator.validate({'code': '1234567890'}), returnsNormally);
    });

    test('invalid alphaNumeric with special characters', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().alphaNumeric(),
      }));

      expect(() => validator.validate({'code': 'abc!@#'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid alphaNumeric with spaces', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().alphaNumeric(),
      }));

      expect(() => validator.validate({'code': 'abc 123'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('startsWith and endsWith combined', () {
    test('valid when both startsWith and endsWith match', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('PRE').endsWith('SUF'),
      }));

      expect(() => validator.validate({'code': 'PRE-middle-SUF'}),
          returnsNormally);
    });

    test('invalid when startsWith is wrong', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('PRE').endsWith('SUF'),
      }));

      expect(() => validator.validate({'code': 'XXX-middle-SUF'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid when endsWith is wrong', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('PRE').endsWith('SUF'),
      }));

      expect(() => validator.validate({'code': 'PRE-middle-XXX'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid when both startsWith and endsWith are wrong', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('PRE').endsWith('SUF'),
      }));

      expect(() => validator.validate({'code': 'XXX-middle-XXX'}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid when value equals exactly prefix and suffix combined', () {
      final validator = vine.compile(vine.object({
        'code': vine.string().startsWith('AB').endsWith('CD'),
      }));

      expect(() => validator.validate({'code': 'ABCD'}), returnsNormally);
    });
  });

  group('minLength and maxLength edge cases', () {
    test('valid string exactly at minLength boundary', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().minLength(5),
      }));

      expect(() => validator.validate({'field': 'abcde'}), returnsNormally);
    });

    test('valid string exactly at maxLength boundary', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().maxLength(5),
      }));

      expect(() => validator.validate({'field': 'abcde'}), returnsNormally);
    });

    test('invalid string one character below minLength', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().minLength(5),
      }));

      expect(() => validator.validate({'field': 'abcd'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid string one character above maxLength', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().maxLength(5),
      }));

      expect(() => validator.validate({'field': 'abcdef'}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid string within minLength and maxLength range', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().minLength(3).maxLength(7),
      }));

      expect(() => validator.validate({'field': 'abcde'}), returnsNormally);
    });

    test('valid empty string with minLength of zero', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().minLength(0),
      }));

      expect(() => validator.validate({'field': ''}), returnsNormally);
    });
  });

  group('UUID edge cases', () {
    test('valid UUID v3 format', () {
      final validator = vine.compile(vine.object({
        'uuid': vine.string().uuid(version: UuidVersion.v3),
      }));

      expect(
          () => validator
              .validate({'uuid': '6fa459ea-ee8a-3ca4-894e-db77e160355e'}),
          returnsNormally);
    });

    test('valid UUID v5 format', () {
      final validator = vine.compile(vine.object({
        'uuid': vine.string().uuid(version: UuidVersion.v5),
      }));

      expect(
          () => validator
              .validate({'uuid': '886313e1-3b8a-5372-9b90-0c9aee199e5d'}),
          returnsNormally);
    });

    test('invalid UUID too short', () {
      final validator = vine.compile(vine.object({
        'uuid': vine.string().uuid(version: UuidVersion.v4),
      }));

      expect(() => validator.validate({'uuid': '123e4567-e89b-12d3'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid UUID wrong format with no dashes', () {
      final validator = vine.compile(vine.object({
        'uuid': vine.string().uuid(version: UuidVersion.v4),
      }));

      expect(
          () =>
              validator.validate({'uuid': '123e4567e89b12d3a456426614174000'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid UUID with random string', () {
      final validator = vine.compile(vine.object({
        'uuid': vine.string().uuid(),
      }));

      expect(() => validator.validate({'uuid': 'not-a-valid-uuid-at-all'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('Credit card edge cases', () {
    test('valid MasterCard number', () {
      final validator = vine.compile(vine.object({
        'card': vine.string().isCreditCard(),
      }));

      expect(() => validator.validate({'card': '5500000000000004'}),
          returnsNormally);
    });

    test('valid American Express number', () {
      final validator = vine.compile(vine.object({
        'card': vine.string().isCreditCard(),
      }));

      expect(() => validator.validate({'card': '378282246310005'}),
          returnsNormally);
    });

    test('valid Discover card number', () {
      final validator = vine.compile(vine.object({
        'card': vine.string().isCreditCard(),
      }));

      expect(() => validator.validate({'card': '6011111111111117'}),
          returnsNormally);
    });

    test('invalid credit card too short', () {
      final validator = vine.compile(vine.object({
        'card': vine.string().isCreditCard(),
      }));

      expect(() => validator.validate({'card': '411111'}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid credit card with letters', () {
      final validator = vine.compile(vine.object({
        'card': vine.string().isCreditCard(),
      }));

      expect(() => validator.validate({'card': 'abcd1234efgh5678'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('normalizeEmail edge cases', () {
    test('normalizeEmail with mixed case domain', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().normalizeEmail(lowercase: true),
      }));

      final data = validator.validate({'email': 'User@EXAMPLE.COM'});
      expect(data['email'], 'user@example.com');
    });

    test('normalizeEmail already lowercase', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().normalizeEmail(lowercase: true),
      }));

      final data = validator.validate({'email': 'user@example.com'});
      expect(data['email'], 'user@example.com');
    });

    test('normalizeEmail with lowercase disabled keeps local part case', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().normalizeEmail(lowercase: false),
      }));

      final data = validator.validate({'email': 'User@Example.COM'});
      expect(data['email'], 'User@example.com');
    });

    test('normalizeEmail combined with email validation', () {
      final validator = vine.compile(vine.object({
        'email': vine.string().email().normalizeEmail(lowercase: true),
      }));

      final data = validator.validate({'email': 'John.Doe@Example.COM'});
      expect(data['email'], 'john.doe@example.com');
    });
  });

  group('toUpperCase and toLowerCase combined with validation', () {
    test('trim then toUpperCase then minLength', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().trim().toUpperCase().minLength(3),
      }));

      final data = validator.validate({'field': '  hello  '});
      expect(data['field'], 'HELLO');
    });

    test('trim then toLowerCase then maxLength', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().trim().toLowerCase().maxLength(10),
      }));

      final data = validator.validate({'field': '  HELLO  '});
      expect(data['field'], 'hello');
    });

    test('trim then toUpperCase fails minLength after trimming', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().trim().toUpperCase().minLength(10),
      }));

      expect(() => validator.validate({'field': '  hi  '}),
          throwsA(isA<VineValidationException>()));
    });

    test('trim then toLowerCase fails maxLength', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().trim().toLowerCase().maxLength(3),
      }));

      expect(() => validator.validate({'field': '  hello  '}),
          throwsA(isA<VineValidationException>()));
    });

    test('toUpperCase combined with startsWith check', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().toUpperCase().startsWith('HELLO'),
      }));

      final data = validator.validate({'field': 'hello world'});
      expect(data['field'], 'HELLO WORLD');
    });
  });

  group('sameAs in nested objects', () {
    test('valid nested sameAs match', () {
      final validator = vine.compile(vine.object({
        'profile': vine.object({
          'email': vine.string(),
          'confirm_email': vine.string().sameAs('email'),
        }),
      }));

      expect(
          () => validator.validate({
                'profile': {
                  'email': 'test@example.com',
                  'confirm_email': 'test@example.com',
                },
              }),
          returnsNormally);
    });

    test('invalid nested sameAs mismatch', () {
      final validator = vine.compile(vine.object({
        'profile': vine.object({
          'email': vine.string(),
          'confirm_email': vine.string().sameAs('email'),
        }),
      }));

      expect(
          () => validator.validate({
                'profile': {
                  'email': 'test@example.com',
                  'confirm_email': 'different@example.com',
                },
              }),
          throwsA(isA<VineValidationException>()));
    });

    test('valid deeply nested sameAs', () {
      final validator = vine.compile(vine.object({
        'settings': vine.object({
          'security': vine.object({
            'password': vine.string(),
            'password_repeat': vine.string().sameAs('password'),
          }),
        }),
      }));

      expect(
          () => validator.validate({
                'settings': {
                  'security': {
                    'password': 'secret123',
                    'password_repeat': 'secret123',
                  },
                },
              }),
          returnsNormally);
    });

    test('invalid deeply nested sameAs mismatch', () {
      final validator = vine.compile(vine.object({
        'settings': vine.object({
          'security': vine.object({
            'password': vine.string(),
            'password_repeat': vine.string().sameAs('password'),
          }),
        }),
      }));

      expect(
          () => validator.validate({
                'settings': {
                  'security': {
                    'password': 'secret123',
                    'password_repeat': 'wrong456',
                  },
                },
              }),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('inList edge cases', () {
    test('valid when value is the first item in the list', () {
      final validator = vine.compile(vine.object({
        'role': vine.string().inList(['admin', 'editor', 'viewer']),
      }));

      expect(() => validator.validate({'role': 'admin'}), returnsNormally);
    });

    test('valid when value is the last item in the list', () {
      final validator = vine.compile(vine.object({
        'role': vine.string().inList(['admin', 'editor', 'viewer']),
      }));

      expect(() => validator.validate({'role': 'viewer'}), returnsNormally);
    });

    test('invalid when value is an empty string not in list', () {
      final validator = vine.compile(vine.object({
        'role': vine.string().inList(['admin', 'editor', 'viewer']),
      }));

      expect(() => validator.validate({'role': ''}),
          throwsA(isA<VineValidationException>()));
    });

    test('invalid when value has different casing', () {
      final validator = vine.compile(vine.object({
        'role': vine.string().inList(['admin', 'editor', 'viewer']),
      }));

      expect(() => validator.validate({'role': 'Admin'}),
          throwsA(isA<VineValidationException>()));
    });
  });

  group('optional and nullable combined', () {
    test('valid when value is null with optional and nullable', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional().nullable(),
      }));

      expect(() => validator.validate({'field': null}), returnsNormally);
    });

    test('valid when field is absent with optional and nullable', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional().nullable(),
      }));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });

    test('valid when value is present with optional and nullable', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional().nullable(),
      }));

      expect(() => validator.validate({'field': 'hello'}), returnsNormally);
    });

    test('valid null with nullable only (field present)', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().nullable(),
      }));

      expect(() => validator.validate({'field': null}), returnsNormally);
    });

    test('invalid absent with nullable only (not optional)', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().nullable(),
      }));

      expect(() => validator.validate(<String, dynamic>{}),
          throwsA(isA<VineValidationException>()));
    });

    test('valid absent with optional only', () {
      final validator = vine.compile(vine.object({
        'field': vine.string().optional(),
      }));

      expect(() => validator.validate(<String, dynamic>{}), returnsNormally);
    });
  });
}
