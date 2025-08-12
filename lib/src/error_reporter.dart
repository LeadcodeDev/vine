import 'dart:convert';

import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/exceptions/validation_exception.dart';
import 'package:vine/src/mapped_errors.dart';

class SimpleErrorReporter implements VineErrorReporter {
  final Map<String, String> _errorMessages;

  @override
  final List<Map<String, Object>> errors = [];

  SimpleErrorReporter(this._errorMessages);

  @override
  bool hasError = false;

  @override
  bool hasErrorForField(String fieldName) =>
      errors.any((element) => element['field'] == fieldName);

  @override
  String format(String rule, VineFieldContext field, String? message,
      Map<String, dynamic> options) {
    String content =
        message ?? _errorMessages[field.name] ?? mappedErrors[rule]!;

    for (final element in options.entries) {
      content =
          content.replaceAll('{${element.key}}', element.value.toString());
    }

    return content
        .replaceAll('{name}', field.name)
        .replaceAll('{value}', field.value.toString());
  }

  @override
  void report(String rule, List<String> keys, String message) {
    hasError = true;
    errors.add({'message': message, 'rule': rule, 'field': keys.join('.')});
  }

  @override
  Exception createError(Object message) {
    return ValidationException(json.encode(message));
  }

  @override
  void clear() {
    if (hasError) {
      errors.clear();
      hasError = false;
    }
  }
}
