import 'package:vine/vine.dart';

final class VineUnionSchema extends RuleParser implements VineUnion {
  final List<VineSchema> _schemas;
  dynamic _example;

  VineUnionSchema(super._rules, this._schemas);

  @override
  VineUnion requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineUnion requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineUnion requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineUnion requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineUnion transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineUnion nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineUnion optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineUnion example(dynamic value) {
    _example = value;
    return this;
  }

  @override
  VineUnion clone() {
    return VineUnionSchema([...rules], _schemas.toList());
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {
      'oneOf': _schemas.map((element) {
        final schema = element.introspect();

        schema.remove('required');
        schema['title'] = switch (element) {
          VineString() => 'StringRule',
          VineNumber() => 'NumberRule',
          VineBoolean() => 'BooleanRule',
          VineArray() => 'ArrayRule',
          VineObject() => 'ObjectRule',
          VineUnion() => 'UnionRule',
          _ => 'AnyRule',
        };

        return schema;
      }).toList(),
      'examples':
          _example ?? _schemas.map((e) => e.introspect()['example']).toList(),
    };
  }
}
