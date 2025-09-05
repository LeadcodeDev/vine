import 'package:vine/vine.dart';

final class VineStringSchema extends RuleParser implements VineString {
  dynamic _example;

  VineStringSchema(super._rules);

  @override
  VineString minLength(int value, {String? message}) {
    super.rules.add(VineMinLengthRule(value, message));
    return this;
  }

  @override
  VineString maxLength(int value, {String? message}) {
    super.rules.add(VineMaxLengthRule(value, message));
    return this;
  }

  @override
  VineString fixedLength(int value, {String? message}) {
    super.rules.add(VineFixedLengthRule(value, message));
    return this;
  }

  @override
  VineString email({String? message}) {
    super.rules.add(VineEmailRule(message));
    return this;
  }

  @override
  VineString phone({RegExp? match, String? message}) {
    super.rules.add(VinePhoneRule(match, message));
    return this;
  }

  @override
  VineString ipAddress({IpAddressVersion? version, String? message}) {
    super.rules.add(VineIpAddressRule(version, message));
    return this;
  }

  @override
  VineString url(
      {List<String> protocols = const ['http', 'https', 'ftp'],
      bool requireTld = true,
      bool requireProtocol = false,
      bool allowUnderscores = false,
      String? message}) {
    super.rules.add(VineUrlRule(
        protocols, requireTld, requireProtocol, allowUnderscores, message));
    return this;
  }

  @override
  VineString alpha({String? message}) {
    super.rules.add(VineAlphaRule(message));
    return this;
  }

  @override
  VineString alphaNumeric({String? message}) {
    super.rules.add(VineAlphaNumericRule(message));
    return this;
  }

  @override
  VineString startsWith(String value, {String? message}) {
    super.rules.add(VineStartWithRule(value, message));
    return this;
  }

  @override
  VineString endsWith(String value, {String? message}) {
    super.rules.add(VineEndWithRule(value, message));
    return this;
  }

  @override
  VineString confirmed(
      {String? property, bool include = false, String? message}) {
    super.rules.add(VineConfirmedRule(property, include, message));
    return this;
  }

  @override
  VineString regex(RegExp expression, {String? message}) {
    super.rules.add(VineRegexRule(expression, message));
    return this;
  }

  @override
  VineString trim() {
    super.rules.add(VineTrimRule());
    return this;
  }

  @override
  VineString normalizeEmail({bool lowercase = true}) {
    super.rules.add(VineNormalizeEmailRule(lowercase));
    return this;
  }

  @override
  VineString toUpperCase() {
    super.rules.add(VineUpperCaseRule());
    return this;
  }

  @override
  VineString toLowerCase() {
    super.rules.add(VineLowerCaseRule());
    return this;
  }

  @override
  VineString toCamelCase() {
    super.rules.add(VineToCamelCaseRule());
    return this;
  }

  @override
  VineString uuid({UuidVersion? version, String? message}) {
    super.rules.add(VineUuidRule(version, message));
    return this;
  }

  @override
  VineString isCreditCard({String? message}) {
    super.rules.add(VineCreditCardRule(message));
    return this;
  }

  @override
  VineString sameAs(String value, {String? message}) {
    super.rules.add(VineSameAsRule(value, message));
    return this;
  }

  @override
  VineString notSameAs(String value, {String? message}) {
    super.rules.add(VineNotSameAsRule(value, message));
    return this;
  }

  @override
  VineString inList(List<String> values, {String? message}) {
    super.rules.add(VineInListRule(values, message));
    return this;
  }

  @override
  VineString notInList(List<String> values, {String? message}) {
    super.rules.add(VineNotInListRule(values, message));
    return this;
  }

  @override
  VineString requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineString requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineString requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineString requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineString transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineString nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineString optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineString example(String value) {
    _example = value;
    return this;
  }

  @override
  VineString clone() {
    return VineStringSchema([...rules]);
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
