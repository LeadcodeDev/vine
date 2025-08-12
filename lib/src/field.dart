import 'package:vine/src/contracts/vine.dart';

final class ValidatorContext<T extends VineErrorReporter>
    implements VineValidationContext<T> {
  @override
  final T errorReporter;

  @override
  final dynamic data;

  @override
  Map<String, dynamic> getFieldContext(List<String> keys) {
    Map<String, dynamic> data = this.data;
    for (final key in keys) {
      if (!data.containsKey(key)) {
        data[key] = {};
      }
      data = data[key];
    }

    return data;
  }

  ValidatorContext(this.errorReporter, this.data);
}

final class Field implements FieldContext {
  @override
  final List<String> customKeys = [];

  @override
  String name;

  @override
  dynamic value;

  @override
  bool canBeContinue = true;

  @override
  bool isUnion = false;

  Field(this.name, this.value);

  @override
  void mutate(dynamic value) {
    this.value = value;
  }
}
