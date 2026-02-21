import 'package:vine/src/contracts/vine.dart';

final class VineValidatorContext<T extends VineErrorReporter>
    implements VineValidationContext<T> {
  @override
  final T errorReporter;

  @override
  dynamic data;

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

  VineValidatorContext(this.errorReporter, this.data);
}

final class VineField implements VineFieldContext {
  @override
  List<String> customKeys = [];

  @override
  String name;

  @override
  dynamic value;

  @override
  bool canBeContinue = true;

  @override
  bool isUnion = false;

  VineField(this.name, this.value);

  void reset(String name, dynamic value) {
    this.name = name;
    this.value = value;
    canBeContinue = true;
    isUnion = false;
    customKeys.clear();
  }

  @override
  void mutate(dynamic value) {
    this.value = value;
  }
}
