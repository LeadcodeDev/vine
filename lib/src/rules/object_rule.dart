import 'package:vine/vine.dart';

final class VineObjectRule implements VineRule {
  final Map<String, VineSchema> payload;
  final String? message;

  const VineObjectRule(this.payload, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final fieldValue = field.value;
    if (fieldValue is! Map) {
      final error = ctx.errorReporter.format('object', field, message, {});
      ctx.errorReporter.report('object', field.customKeys, error);

      return;
    }

    final Map<String, dynamic> resultMap = {};
    bool shouldBreak = false;
    final currentField = VineField('', null);
    final parentKeysLength = field.customKeys.length;

    for (final entry in payload.entries) {
      if (shouldBreak) break;

      final key = entry.key;
      final schema = entry.value;

      currentField.reset(
          key, fieldValue.containsKey(key) ? fieldValue[key] : MissingValue());
      currentField.customKeys.addAll(field.customKeys);

      switch (schema) {
        case VineArray():
          field.customKeys.add(key);
        case VineObject():
          if (!fieldValue.containsKey(key)) {
            final error =
                ctx.errorReporter.format('object', field, message, {});
            ctx.errorReporter.report('object', field.customKeys, error);
          }
          currentField.customKeys.add(key);
          field.customKeys.add(key);
      }

      schema.parse(ctx, currentField);
      resultMap[key] = currentField.value;

      shouldBreak = !currentField.canBeContinue || ctx.errorReporter.hasError;
    }

    field.customKeys.length = parentKeysLength;

    field.mutate(resultMap);
  }
}
