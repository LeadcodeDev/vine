import 'dart:collection';

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
    super.addRule(VineDateBeforeRule(value, message));
    return this;
  }

  @override
  VineDate after(DateTime value, {String? message}) {
    super.addRule(VineDateAfterRule(value, message));
    return this;
  }

  @override
  VineDate between(DateTime min, DateTime max, {String? message}) {
    super.addRule(VineDateBetweenRule(min, max, message));
    return this;
  }

  @override
  VineDate beforeField(String target, {String? message}) {
    super.addRule(VineDateBeforeFieldRule(target, message));
    return this;
  }

  @override
  VineDate afterField(String target, {String? message}) {
    super.addRule(VineDateAfterFieldRule(target, message));
    return this;
  }

  @override
  VineDate betweenFields(String start, String end, {String? message}) {
    super.addRule(VineDateBetweenFieldRule(start, end, message));
    return this;
  }

  @override
  VineDate transform(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineDate requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineDate requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineDate requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineDate requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineDate nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineDate optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineDate example(String value) {
    _example = value;
    return this;
  }

  @override
  VineDate clone() {
    return VineDateSchema(Queue.of(rules));
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
