import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/basic_rule.dart';

final class VineBooleanSchema extends RuleParser implements VineBoolean {
  dynamic _example;

  VineBooleanSchema(super._rules);

  @override
  VineBoolean transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineBoolean requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineBoolean requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineBoolean requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineBoolean requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineBoolean optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineBoolean nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineBoolean example(bool value) {
    _example = value;
    return this;
  }

  @override
  VineBoolean clone() {
    return VineBooleanSchema([...rules]);
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
