import 'dart:collection';

import 'package:vine/vine.dart';

final class VineEnumSchema<T extends VineEnumerable> extends RuleParser
    implements VineEnum<T> {
  final List<T> _source;
  T? _example;

  VineEnumSchema(super._rules, this._source);

  @override
  VineEnum<T> requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum<T> requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum<T> requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum<T> requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineEnum<T> transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineEnum<T> nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineEnum<T> optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineEnum<T> example(T value) {
    _example = value;
    return this;
  }

  @override
  VineEnum<T> clone() {
    return VineEnumSchema(Queue.of(rules), _source.toList());
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {
      'type': 'string',
      'enum': _source.map((e) => e.value).toList(),
      'required': !isOptional,
      'example': _example?.value ?? _source.first.value,
    };
  }
}
