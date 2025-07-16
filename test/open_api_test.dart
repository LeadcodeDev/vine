import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:vine/vine.dart';

enum MyEnum implements VineEnumerable {
  foo('foo'),
  bar('bar');

  @override
  final String value;

  const MyEnum(this.value);
}

void main() async {
  test('generate openapi schema', () {
    final schema = vine.object({
      'stringField': vine.string().minLength(3).maxLength(20),
      'emailField': vine.string().email(),
      'numberField': vine.number().min(18).max(100),
      'booleanField': vine.boolean(),
      'enumField': vine.enumerate(MyEnum.values),
      'arrayField':
          vine.array(vine.string().minLength(3).maxLength(20)).minLength(1),
      'unionField': vine.union([
        vine.string().minLength(3).maxLength(20),
        vine.number().min(10).max(20),
      ]),
    });

    expect(() => vine.openApi.report(schemas: {'MySchema': schema}),
        returnsNormally);
    expect(
        vine.openApi.report(schemas: {'MySchema': schema}),
        allOf({
          "openapi": "3.1.0",
          "components": {
            "schemas": {
              "MySchema": {
                "title": "MySchema",
                "type": "object",
                "properties": {
                  "stringField": {
                    "type": "string",
                    "example": "foo",
                    "minLength": 3
                  },
                  "emailField": {
                    "type": "string",
                    "format": "email",
                    "example": "user@example.com"
                  },
                  "numberField": {
                    "type": "number",
                    "example": 99.5,
                    "minimum": 18,
                    "maximum": 100
                  },
                  "booleanField": {"type": "boolean", "example": true},
                  "enumField": {
                    "type": "string",
                    "enum": ["foo", "bar"],
                    "example": "foo"
                  },
                  "arrayField": {
                    "type": "array",
                    "items": {"type": "string", "minLength": 3},
                    "minItems": 1,
                    "example": ["foo"]
                  },
                  "unionField": {
                    "oneOf": [
                      {
                        "type": "string",
                        "example": "foo",
                        "minLength": 3,
                        "title": "StringRule"
                      },
                      {
                        "type": "number",
                        "example": 19.5,
                        "minimum": 10,
                        "maximum": 20,
                        "title": "NumberRule"
                      }
                    ],
                    "examples": ["foo", 19.5]
                  }
                },
                "required": [
                  "stringField",
                  "emailField",
                  "numberField",
                  "booleanField",
                  "enumField",
                  "arrayField"
                ],
                "additionalProperties": false,
                "example": {
                  "stringField": "foo",
                  "emailField": "user@example.com",
                  "numberField": 99.5,
                  "booleanField": true,
                  "enumField": "foo",
                  "arrayField": ["foo"],
                  "unionField": "foo"
                }
              }
            }
          }
        }));
  });
}
