import 'dart:collection';

import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/basic_rule.dart';
import 'package:vine/src/rules/number_rule.dart';

final class VineNumberSchema extends RuleParser implements VineNumber {
  dynamic _example;

  VineNumberSchema(super._rules);

  @override
  VineNumber range(List<num> values, {String? message}) {
    super.addRule(VineRangeRule(values, message));
    return this;
  }

  @override
  VineNumber min(num value, {String? message}) {
    super.addRule(VineMinRule(value, message));
    return this;
  }

  @override
  VineNumber max(num value, {String? message}) {
    super.addRule(VineMaxRule(value, message));
    return this;
  }

  @override
  VineNumber negative({String? message}) {
    super.addRule(VineNegativeRule(message));
    return this;
  }

  @override
  VineNumber positive({String? message}) {
    super.addRule(VinePositiveRule(message));
    return this;
  }

  @override
  VineNumber double({String? message}) {
    super.addRule(VineDoubleRule(message));
    return this;
  }

  @override
  VineNumber integer({String? message}) {
    super.addRule(VineIntegerRule(message));
    return this;
  }

  @override
  VineNumber requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineNumber requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineNumber requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineNumber requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineNumber transform(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineNumber nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineNumber optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineNumber example(num value) {
    _example = value;
    return this;
  }

  @override
  VineNumber clone() {
    return VineNumberSchema(Queue.of(rules));
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    final validations = <String, dynamic>{};
    bool isInteger = false;
    bool isDouble = false;
    List<num>? enums;
    num example = 0;

    // Analyse des règles
    for (final rule in rules) {
      switch (rule) {
        case VineIntegerRule():
          isInteger = true;
          example = 42;
        case VineDoubleRule():
          isDouble = true;
          example = 3.14;
        case VineMinRule(:final minValue):
          validations['minimum'] = minValue;
          example = minValue + (isInteger ? 1 : 0.5);
        case VineMaxRule(:final maxValue):
          validations['maximum'] = maxValue;
          example = maxValue - (isInteger ? 1 : 0.5);
        case VineRangeRule(:final values):
          enums = values;
          example = values.firstOrNull ?? example;
        case VinePositiveRule():
          validations['exclusiveMinimum'] = 0;
          example = 1;
        case VineNegativeRule():
          validations['exclusiveMaximum'] = 0;
          example = -1;
      }
    }

    // Détermination du type
    final type = isInteger
        ? 'integer'
        : isDouble
            ? 'number'
            : 'number';

    // Validation de l'exemple
    if (validations.containsKey('minimum') ||
        validations.containsKey('maximum')) {
      example = example.clamp(
        validations['minimum'] ?? '-Infinity',
        validations['maximum'] ?? 'Infinity',
      );
    }

    // Construction du schéma
    return {
      if (name != null) 'title': name,
      'type': type,
      'required': !isOptional,
      if (enums != null) 'enum': enums,
      'example': _example ?? example,
      ...validations,
    }..removeWhere((_, v) => v == null);
  }
}
