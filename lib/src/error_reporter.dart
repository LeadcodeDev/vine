import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/exceptions/validation_exception.dart';
import 'package:vine/src/mapped_errors.dart';

final _placeholderRegex = RegExp(r'\{(\w+)\}');

class SimpleErrorReporter implements VineErrorReporter {
  final Map<String, String> _errorMessages;

  @override
  final List<Map<String, Object>> errors = [];

  final Set<String> _errorFieldNames = {};

  SimpleErrorReporter(this._errorMessages);

  @override
  bool hasError = false;

  @override
  bool hasErrorForField(String fieldName) =>
      _errorFieldNames.contains(fieldName);

  @override
  String format(String rule, VineFieldContext field, String? message,
      Map<String, dynamic> options) {
    final String template =
        message ?? _errorMessages[field.name] ?? mappedErrors[rule]!;

    return template.replaceAllMapped(_placeholderRegex, (match) {
      final key = match.group(1)!;
      if (options.containsKey(key)) return options[key].toString();
      if (key == 'name') return field.name;
      if (key == 'value') return field.value.toString();
      return match.group(0)!;
    });
  }

  @override
  void report(String rule, List<String> keys, String message) {
    hasError = true;
    final fieldPath = keys.isNotEmpty ? keys.join('.') : null;
    if (fieldPath != null) _errorFieldNames.add(fieldPath);
    errors.add({
      'message': message,
      'rule': rule,
      if (fieldPath != null) 'field': fieldPath,
    });
  }

  @override
  void reportField(String rule, VineFieldContext field, String message) {
    hasError = true;
    final keys = field.customKeys;
    final name = field.name;

    String fieldPath;
    if (keys.isEmpty) {
      fieldPath = name;
    } else {
      final buffer = StringBuffer();
      for (int i = 0; i < keys.length; i++) {
        buffer.write(keys[i]);
        buffer.write('.');
      }
      buffer.write(name);
      fieldPath = buffer.toString();
    }

    _errorFieldNames.add(fieldPath);
    errors.add({
      'message': message,
      'rule': rule,
      'field': fieldPath,
    });
  }

  @override
  Exception createError(Map<String, dynamic> message) {
    return VineValidationException(message);
  }

  @override
  void rollbackTo(int errorCount) {
    while (errors.length > errorCount) {
      final removed = errors.removeLast();
      final field = removed['field'];
      if (field is String) {
        _errorFieldNames.remove(field);
      }
    }
    if (errors.isEmpty) {
      hasError = false;
    }
  }

  @override
  void clear() {
    if (hasError) {
      errors.clear();
      _errorFieldNames.clear();
      hasError = false;
    }
  }
}
