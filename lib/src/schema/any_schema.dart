import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/basic_rule.dart';

final class VineAnySchema extends RuleParser implements VineAny {
  dynamic _example;

  VineAnySchema(super._rules);

  @override
  VineAny transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineAny requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineAny requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineAny requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineAny requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineAny nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineAny optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineAny example(dynamic value) {
    _example = value;
    return this;
  }

  @override
  VineAny clone() {
    return VineAnySchema([...rules]);
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {
      'required': !isOptional,
      if (_example != null) 'example': _example,
    };
  }
}
