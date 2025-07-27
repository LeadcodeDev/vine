import 'dart:collection';

import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/error_reporter.dart';
import 'package:vine/src/exceptions/validation_exception.dart';
import 'package:vine/src/field.dart';
import 'package:vine/src/introspection.dart';
import 'package:vine/src/rules/any_rule.dart';
import 'package:vine/src/rules/array_rule.dart';
import 'package:vine/src/rules/boolean_rule.dart';
import 'package:vine/src/rules/date_rule.dart';
import 'package:vine/src/rules/enum_rule.dart';
import 'package:vine/src/rules/number_rule.dart';
import 'package:vine/src/rules/object_rule.dart';
import 'package:vine/src/rules/string_rule.dart';
import 'package:vine/src/rules/union_rule.dart';
import 'package:vine/src/schema/any_schema.dart';
import 'package:vine/src/schema/array_schema.dart';
import 'package:vine/src/schema/boolean_schema.dart';
import 'package:vine/src/schema/date_schema.dart';
import 'package:vine/src/schema/enum_schema.dart';
import 'package:vine/src/schema/number_schema.dart';
import 'package:vine/src/schema/object/group_schema.dart';
import 'package:vine/src/schema/object/object_schema.dart';
import 'package:vine/src/schema/string_schema.dart';
import 'package:vine/src/schema/union_schema.dart';

final class Vine {
  ErrorReporter Function(Map<String, String> errors) errorReporter =
      SimpleErrorReporter.new;

  VineObject object(Map<String, VineSchema> payload, {String? message}) {
    final Queue<VineRule> rules = Queue();
    rules.add(VineObjectRule(payload, message));
    return VineObjectSchema(payload, rules);
  }

  VineGroup group(Function(VineGroupSchema) builder) {
    final Queue<VineRule> rules = Queue();
    final group = VineGroupSchema(rules);

    builder(group);
    return group;
  }

  VineString string({String? message}) {
    final Queue<VineRule> rules = Queue();
    rules.add(VineStringRule(message));

    return VineStringSchema(rules);
  }

  VineNumber number({String? message}) {
    final Queue<VineRule> rules = Queue();
    rules.add(VineNumberRule(message));

    return VineNumberSchema(rules);
  }

  VineBoolean boolean({bool includeLiteral = false, String? message}) {
    final Queue<VineRule> rules = Queue();

    rules.add(VineBooleanRule(includeLiteral, message));
    return VineBooleanSchema(rules);
  }

  VineAny any() {
    final Queue<VineRule> rules = Queue();

    rules.add(VineAnyRule());
    return VineAnySchema(rules);
  }

  VineEnum enumerate<T extends VineEnumerable>(List<T> source) {
    final Queue<VineRule> rules = Queue();

    rules.add(VineEnumRule<T>(source));
    return VineEnumSchema<T>(rules, source);
  }

  VineArray array(VineSchema schema) {
    final Queue<VineRule> rules = Queue();

    rules.add(VineArrayRule(schema));
    return VineArraySchema(rules);
  }

  VineUnion union(List<VineSchema> schemas) {
    final Queue<VineRule> rules = Queue();
    rules.add(VineUnionRule(schemas));

    return VineUnionSchema(rules, schemas);
  }

  VineDate date({String? message}) {
    final Queue<VineRule> rules = Queue();

    rules.add(VineDateRule(message));
    return VineDateSchema(rules);
  }

  Validator compile(VineSchema schema,
      {Map<String, String> errors = const {}}) {
    return Validator(schema.clone(), errors);
  }

  Map<String, dynamic> validate(Map<String, dynamic> data, VineSchema schema) {
    final reporter = errorReporter({});

    final validatorContext = ValidatorContext(reporter, data);
    final field = Field('', data);
    schema.parse(validatorContext, field);

    if (reporter.hasError) {
      throw reporter.createError({'errors': reporter.errors});
    }

    return field.value;
  }

  OpenApiReporter get openApi => OpenApiReporter();
}

final class Validator implements ValidatorContract {
  final VineSchema _schema;
  final Map<String, String> errors;
  final reporter = vine.errorReporter({});

  Validator(this._schema, this.errors);

  VineSchema get schema => _schema.clone();

  (ValidationException?, T?) tryValidate<T>(dynamic data) {
    try {
      final result = validate(data);
      return (null, result);
    } on ValidationException catch (exception) {
      return (exception, null);
    }
  }

  T validate<T>(dynamic data) {
    final validatorContext = ValidatorContext(reporter, data);
    final field = Field('', data);
    _schema.parse(validatorContext, field);

    if (reporter.hasError) {
      throw reporter.createError({'errors': reporter.errors});
    }

    reporter.clear();
    return field.value;
  }
}

final vine = Vine();
