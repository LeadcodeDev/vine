import 'package:vine/vine.dart';

final class VineEnumSchema<T extends VineEnumerable> extends RuleParser
    implements VineEnum<T> {
  final List<T> _source;
  T? _example;

  VineEnumSchema(super._rules, this._source);

  @override
  VineEnum<T> transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineTransformRule(fn));
    return this;
  }

  @override
  VineEnum<T> requiredIfExist(List<String> values) {
    super.rules = [VineRequiredIfExistRule(values), ...super.rules];
    return this;
  }

  @override
  VineEnum<T> requiredIfAnyExist(List<String> values) {
    super.rules = [VineRequiredIfAnyExistRule(values), ...rules];
    return this;
  }

  @override
  VineEnum<T> requiredIfMissing(List<String> values) {
    super.rules = [VineRequiredIfMissingRule(values), ...rules];
    return this;
  }

  @override
  VineEnum<T> requiredIfAnyMissing(List<String> values) {
    super.rules = [VineRequiredIfAnyMissingRule(values), ...rules];
    return this;
  }

  @override
  VineEnum<T> nullable() {
    super.rules = [VineNullableRule(), ...rules];
    return this;
  }

  @override
  VineEnum<T> optional() {
    super.rules = [VineOptionalRule(), ...rules];
    return this;
  }

  @override
  VineEnum<T> example(T value) {
    _example = value;
    return this;
  }

  @override
  VineEnum<T> clone() {
    return VineEnumSchema([...rules], _source.toList());
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
