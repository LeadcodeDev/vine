abstract interface class VineErrorReporter {
  List<Map<String, Object>> get errors;

  abstract bool hasError;

  bool hasErrorForField(String fieldName);

  String format(String rule, VineFieldContext field, String? message,
      Map<String, dynamic> options);

  void report(String rule, List<String> keys, String message);

  Exception createError(Map<String, dynamic> message);

  void clear();
}

abstract interface class VineValidatorContract {}

abstract interface class VineValidationContext<T extends VineErrorReporter> {
  T get errorReporter;

  dynamic get data;

  Map<String, dynamic> getFieldContext(List<String> keys);
}

abstract interface class VineFieldContext {
  List<String> get customKeys;

  abstract String name;
  abstract bool canBeContinue;
  abstract bool isUnion;

  dynamic value;

  void mutate(dynamic value);
}

typedef ParseHandler = void Function(VineValidationContext, VineFieldContext);

final class MissingValue {}
