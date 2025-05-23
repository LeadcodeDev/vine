import 'dart:collection';

import 'package:vine/vine.dart';

final class VineEnumSchema<T extends VineEnumerable> extends RuleParser
    implements VineEnum {
  final List<T> _source;
  VineEnumSchema(super._rules, this._source);

  @override
  VineEnum requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum transform(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineEnum nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineEnum optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineEnum clone() {
    return VineEnumSchema(Queue.of(rules), _source.toList());
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {
      'type': 'string', // Adapt selon le type des valeurs
      'enum': _source.map((e) => e.value).toList(),
      'required': !isOptional,
      'example': _source.firstOrNull?.value,
    };
  }
}
