import 'dart:collection';

import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/array_rule.dart';
import 'package:vine/src/rules/basic_rule.dart';

final class VineArraySchema extends RuleParser implements VineArray {
  VineArraySchema(super._rules);

  @override
  VineArray minLength(int value, {String? message}) {
    super.rules.add(VineArrayMinLengthRule(value, message));
    return this;
  }

  @override
  VineArray maxLength(int value, {String? message}) {
    super.rules.add(VineArrayMaxLengthRule(value, message));
    return this;
  }

  @override
  VineArray fixedLength(int value, {String? message}) {
    super.rules.add(VineArrayFixedLengthRule(value, message));
    return this;
  }

  @override
  VineArray unique({String? message}) {
    super.rules.add(VineArrayUniqueRule(message));
    return this;
  }

  @override
  VineArray transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineArray requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineArray requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineArray requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineArray requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineArray nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineArray optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineArray clone() {
    return VineArraySchema([...rules]);
  }

  int? _getRuleValue<T extends VineRule>() {
    return switch (rules.whereType<T>().firstOrNull) {
      VineArrayMinLengthRule rule => rule.minValue,
      VineArrayFixedLengthRule rule => rule.count,
      _ => null,
    };
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    final itemsSchema =
        rules.whereType<VineArrayRule>().firstOrNull?.schema.introspect();
    itemsSchema?.remove('required');
    final example = itemsSchema?['example'];
    itemsSchema?.remove('example');

    final minValue = _getRuleValue<VineArrayMinLengthRule>();
    final maxValue = _getRuleValue<VineArrayMaxLengthRule>();
    final isUnique = rules.whereType<VineArrayUniqueRule>().isNotEmpty;

    return {
      'type': 'array',
      'items': itemsSchema ?? {'type': 'any'},
      if (minValue != null) 'minItems': minValue,
      if (maxValue != null) 'maxItems': maxValue,
      if (isUnique) 'uniqueItems': isUnique,
      'required': !isOptional,
      'example': [example],
    };
  }
}
