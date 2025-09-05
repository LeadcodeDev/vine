import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/basic_rule.dart';
import 'package:vine/src/rules/date_rule.dart';

final class VineDateSchema extends RuleParser implements VineDate {
  dynamic _example;

  VineDateSchema(super._rules);

  @override
  VineDate before(DateTime value, {String? message}) {
    super.rules.add(VineDateBeforeRule(value, message));
    return this;
  }

  @override
  VineDate after(DateTime value, {String? message}) {
    super.rules.add(VineDateAfterRule(value, message));
    return this;
  }

  @override
  VineDate between(DateTime min, DateTime max, {String? message}) {
    super.rules.add(VineDateBetweenRule(min, max, message));
    return this;
  }

  @override
  VineDate beforeField(String target, {String? message}) {
    super.rules.add(VineDateBeforeFieldRule(target, message));
    return this;
  }

  @override
  VineDate afterField(String target, {String? message}) {
    super.rules.add(VineDateAfterFieldRule(target, message));
    return this;
  }

  @override
  VineDate betweenFields(String start, String end, {String? message}) {
    super.rules.add(VineDateBetweenFieldRule(start, end, message));
    return this;
  }

  @override
  VineDate transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineDate requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineDate requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineDate requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineDate requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineDate nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineDate optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineDate example(String value) {
    _example = value;
    return this;
  }

  @override
  VineDate clone() {
    return VineDateSchema([...rules]);
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {
      'type': 'string',
      'format': 'date-time',
      'required': !isOptional,
      if (_example != null) 'example': _example,
    };
  }
}
