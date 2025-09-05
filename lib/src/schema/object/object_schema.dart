import 'dart:collection';

import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rule_parser.dart';
import 'package:vine/src/rules/basic_rule.dart';
import 'package:vine/vine.dart';

final class VineObjectSchema extends RuleParser implements VineObject {
  final Map<String, VineSchema> _properties;

  VineObjectSchema(this._properties, super._rules);

  @override
  Map<String, VineSchema> get properties => {..._properties};

  @override
  VineObject merge(VineObjectSchema schema) {
    _properties.addAll(schema.properties);
    return this;
  }

  @override
  VineObject transform(Function(VineValidationContext, VineFieldContext) fn) {
    super.addRule(VineTransformRule(fn));
    return this;
  }

  @override
  VineObject requiredIfExist(List<String> values) {
    super.addRule(VineRequiredIfExistRule(values), positioned: true);
    return this;
  }

  @override
  VineObject requiredIfAnyExist(List<String> values) {
    super.addRule(VineRequiredIfAnyExistRule(values), positioned: true);
    return this;
  }

  @override
  VineObject requiredIfMissing(List<String> values) {
    super.addRule(VineRequiredIfMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineObject requiredIfAnyMissing(List<String> values) {
    super.addRule(VineRequiredIfAnyMissingRule(values), positioned: true);
    return this;
  }

  @override
  VineObject nullable() {
    super.isNullable = true;
    return this;
  }

  @override
  VineObject optional() {
    super.isOptional = true;
    return this;
  }

  @override
  VineObject clone() {
    final Map<String, VineSchema> props = {};
    for (final entry in _properties.entries) {
      props[entry.key] = entry.value.clone();
    }

    return VineObjectSchema(props, Queue.of(rules));
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    final Map<String, dynamic> properties = {};
    final List<String> requiredFields = [];
    final Map<String, dynamic> example = {};

    for (final entry in _properties.entries) {
      final schema = entry.value.introspect();
      properties[entry.key] = schema;

      if (schema['required'] ?? false) {
        requiredFields.add(entry.key);
        schema.remove('required');
      }

      example[entry.key] = schema['example'] ??
          (schema['examples'] is List
              ? (schema['examples'] as List).firstOrNull
              : null);
    }

    return {
      if (name != null) 'title': name,
      'type': 'object',
      'properties': properties,
      if (requiredFields.isNotEmpty) 'required': requiredFields,
      'additionalProperties': false,
      'example': example,
    };
  }
}
