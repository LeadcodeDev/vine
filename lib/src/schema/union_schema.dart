import 'dart:collection';

import 'package:vine/vine.dart';

final class VineUnionSchema extends RuleParser implements VineUnion {
  final List<VineSchema> _schemas;
  dynamic _example;

  VineUnionSchema(super._rules, this._schemas);

  @override
  VineUnion requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineUnion requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineUnion requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineUnion requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineUnion transform(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineUnion nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineUnion optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineUnion example(dynamic value) {
    _example = value;
    return this;
  }

  @override
  VineUnion clone() {
    return VineUnionSchema(Queue.of(rules), _schemas.toList());
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
