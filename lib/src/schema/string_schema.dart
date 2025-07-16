import 'dart:collection';

import 'package:vine/vine.dart';

final class VineStringSchema extends RuleParser implements VineString {
  dynamic _example;

  VineStringSchema(super._rules);

  @override
  VineString minLength(int value, {String? message}) {
    super.addRule(VineMinLengthRule(value, message));
    return this;
  }

  @override
  VineString maxLength(int value, {String? message}) {
    super.addRule(VineMaxLengthRule(value, message));
    return this;
  }

  @override
  VineString fixedLength(int value, {String? message}) {
    super.addRule(VineFixedLengthRule(value, message));
    return this;
  }

  @override
  VineString email({String? message}) {
    super.addRule(VineEmailRule(message));
    return this;
  }

  @override
  VineString phone({RegExp? match, String? message}) {
    super.addRule(VinePhoneRule(match, message));
    return this;
  }

  @override
  VineString ipAddress({IpAddressVersion? version, String? message}) {
    super.addRule(VineIpAddressRule(version, message));
    return this;
  }

  @override
  VineString url(
      {List<String> protocols = const ['http', 'https', 'ftp'],
      bool requireTld = true,
      bool requireProtocol = false,
      bool allowUnderscores = false,
      String? message}) {
    super.addRule(VineUrlRule(
        protocols, requireTld, requireProtocol, allowUnderscores, message));
    return this;
  }

  @override
  VineString alpha({String? message}) {
    super.addRule(VineAlphaRule(message));
    return this;
  }

  @override
  VineString alphaNumeric({String? message}) {
    super.addRule(VineAlphaNumericRule(message));
    return this;
  }

  @override
  VineString startsWith(String value, {String? message}) {
    super.addRule(VineStartWithRule(value, message));
    return this;
  }

  @override
  VineString endsWith(String value, {String? message}) {
    super.addRule(VineEndWithRule(value, message));
    return this;
  }

  @override
  VineString confirmed(
      {String? property, bool include = false, String? message}) {
    super.addRule(VineConfirmedRule(property, include, message));
    return this;
  }

  @override
  VineString regex(RegExp expression, {String? message}) {
    super.addRule(VineRegexRule(expression, message));
    return this;
  }

  @override
  VineString trim() {
    super.addRule(VineTrimRule());
    return this;
  }

  @override
  VineString normalizeEmail({bool lowercase = true}) {
    super.addRule(VineNormalizeEmailRule(lowercase));
    return this;
  }

  @override
  VineString toUpperCase() {
    super.addRule(VineUpperCaseRule());
    return this;
  }

  @override
  VineString toLowerCase() {
    super.addRule(VineLowerCaseRule());
    return this;
  }

  @override
  VineString toCamelCase() {
    super.addRule(VineToCamelCaseRule());
    return this;
  }

  @override
  VineString uuid({UuidVersion? version, String? message}) {
    super.addRule(VineUuidRule(version, message));
    return this;
  }

  @override
  VineString isCreditCard({String? message}) {
    super.addRule(VineCreditCardRule(message));
    return this;
  }

  @override
  VineString sameAs(String value, {String? message}) {
    super.addRule(VineSameAsRule(value, message));
    return this;
  }

  @override
  VineString notSameAs(String value, {String? message}) {
    super.addRule(VineNotSameAsRule(value, message));
    return this;
  }

  @override
  VineString inList(List<String> values, {String? message}) {
    super.addRule(VineInListRule(values, message));
    return this;
  }

  @override
  VineString notInList(List<String> values, {String? message}) {
    super.addRule(VineNotInListRule(values, message));
    return this;
  }

  @override
  VineString requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineString requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineString requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineString requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineString transform(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineString nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineString optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineString example(String value) {
    _example = value;
    return this;
  }

  @override
  VineString clone() {
    return VineStringSchema(Queue.of(rules));
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    final validations = <String, dynamic>{};
    String? format;
    String example = 'foo';
    List<String>? enums;

    for (final rule in rules) {
      if (rule is VineEmailRule) {
        format = 'email';
        example = 'user@example.com';
        continue;
      }

      if (rule is VineUuidRule) {
        format = 'uuid';
        example = '550e8400-e29b-41d4-a716-446655440000';
        continue;
      }

      if (rule is VineMinLengthRule) {
        validations['minLength'] = rule.minValue;
        continue;
      }

      if (rule is VineEnumRule) {
        enums = rule.source.map((e) => e.value.toString()).toList();
      }
    }

    return {
      'type': 'string',
      'format': format,
      'required': !isOptional,
      'example': _example ?? example,
      'enum': enums,
      ...validations,
    }..removeWhere((_, v) => v == null);
  }
}
