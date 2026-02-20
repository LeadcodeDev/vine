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

    final allOptions = {
      ...options,
      'name': field.name,
      'value': field.value,
    };

    return template.replaceAllMapped(_placeholderRegex, (match) {
      final key = match.group(1)!;
      return allOptions.containsKey(key)
          ? allOptions[key].toString()
          : match.group(0)!;
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
