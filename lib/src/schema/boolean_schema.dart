import 'dart:collection';

import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/basic_rule.dart';

final class VineBooleanSchema extends RuleParser implements VineBoolean {
  dynamic _example;

  VineBooleanSchema(super._rules);

  @override
  VineBoolean transform(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineBoolean requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineBoolean requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineBoolean requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineBoolean requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineBoolean nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineBoolean optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineBoolean example(bool value) {
    _example = value;
    return this;
  }

  @override
  VineBoolean clone() {
    return VineBooleanSchema(Queue.of(rules));
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {
      'type': 'boolean',
      'required': !isOptional,
      'example': _example ?? true,
    };
  }
}
