# 🌿 Vine

**Vine** is a robust, typed validation library for Dart/Flutter, designed to simplify and secure data management in
applications inspired by [Vine.js](https://vinejs.dev/docs/introduction)..

Its main objective is to solve the recurring problem of validating user input, external APIs or internal configurations,
a critical step that is often a source of errors and complexity in development.

Unlike manual methods or ad hoc checks, Vine offers a structured, declarative approach to defining validation schemes,
ensuring that data complies with an expected format before it is used, which reduces bugs and improves reliability.

![icons technologies](https://skillicons.dev/icons?i=dart,flutter)

## 🛠 Key features

| Feature                   | Description                                                  |
| ------------------------- | ------------------------------------------------------------ |
| ✅ Type-Safe Validation   | Define schemas with a fluent API and ensure data integrity   |
| 🧱 Rich Set of Validators | Strings, numbers, booleans, arrays, enums, objects, and more |
| 🔄 Data Transformation    | Trim, normalize, and transform values during validation      |
| 🚧 Null Safety            | Full support for nullable and optional fields                |
| ⚙️ Composable             | Compiled and reusable schemas                                |
| ⚡ Fast Performance       | ~ 3 000 000 ops/s                                            |
| 📦 Extremely small size   | Package size `< 21kb`                                        |
| 🚀 OpenApi reporter       | Export your schemas as OpenApi spec                          |

## 🚀 Usage

Vine is a data structure validation library for Dart. You may use it to validate the HTTP request body or any data in
your backend applications.

> See related [article](https://dev.to/baptiste_parmantier/validate-your-data-structures-with-vine-in-your-dart-projects-111p) in `Dev.to` to discover how to use Vine in your Dart projects.

### Built for validating form data and JSON payloads

Serializing an HTML form to FormData or a JSON object comes with its own set of quirks.

For example:

- Numbers and booleans are serialized as strings
- Checkboxes are not booleans
- And empty fields are represented as empty strings

Vine handles all these quirks natively, and you never have to perform manual normalization in your codebase.

### Maintainability and reusability

This library meets the typical need for maintainability and security in dynamic ecosystems such as Flutter, where
uncontrolled data can lead to crashes or vulnerabilities.

It offers an elegant solution via a fluid, chainable API, enabling complex validation rules (text length, numeric
ranges, email formats, UUID, etc.) to be described in just a few lines.

For example, a user form can be validated with precise constraints (e.g. `vine.string().email().minLength(5)`) while
transforming the data (trim, case conversion, normalisation), thus avoiding redundant code and repeated checks.

```dart
import 'package:vine/vine.dart';

void main() {
  final validator = vine.compile(
    vine.object({
      'username': vine.string().minLength(3).maxLength(20),
      'email': vine.string().email(),
      'age': vine.number().min(18).optional(),
      'isAdmin': vine.boolean(),
      'features': vine.array(vine.string()),
    }));

  try {
    final payload = {
      'username': 'john Doe',
      'email': 'john@example.com',
      'age': 25,
      'isAdmin': true,
      'features': ['MANAGE'],
    };

    final data = validator.validate(payload);
    print('Valid data: $data');
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  }
}
```

### OpenAPI reporter

Vine can generate an OpenAPI schema from your validation schemas.
This feature is useful when you want to document your API

```dart
final schema = vine.object({
  'stringField': vine.string().minLength(3).maxLength(20),
  'emailField': vine.string().email(),
  'numberField': vine.number().min(18).max(100),
  'booleanField': vine.boolean(),
  'enumField': vine.enumerate(MyEnum.values),
  'arrayField': vine.array(vine.string().minLength(3).maxLength(20)).minLength(1),
  'unionField': vine.union([
    vine.string().minLength(3).maxLength(20),
    vine.number().min(10).max(20),
  ]),
});

final reporter = vine.openApi.report(schemas: {'MySchema': schema});
print(reporter);
```

## ❤️ Credit

I would like to thank [Harminder Virk](https://github.com/thetutlage) for all his open-source work on Adonis.js and for
his permission to
reuse the name `Vine` for this package.
