import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/field.dart';

const _maxCachedIndex = 256;
final _indexStrings = List.generate(_maxCachedIndex, (i) => i.toString());

String _indexToString(int i) =>
    i < _maxCachedIndex ? _indexStrings[i] : i.toString();

final class VineArrayRule implements VineRule {
  final VineSchema schema;

  const VineArrayRule(this.schema);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case List values) {
      final List result = List.filled(values.length, null);
      for (int i = 0; i < values.length; i++) {
        final currentField = VineField(field.name, values[i]);
        currentField.customKeys.addAll(field.customKeys);
        currentField.customKeys.add(_indexToString(i));

        schema.parse(ctx, currentField);
        result[i] = currentField.value;
      }
      field.mutate(result);
      return;
    }

    final error = ctx.errorReporter.format('array', field, null, {});
    ctx.errorReporter.reportField('array', field, error);
  }
}

final class VineArrayUniqueRule implements VineRule {
  final String? message;

  const VineArrayUniqueRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value is! List) {
      final error =
          ctx.errorReporter.format('array.unique', field, message, {});
      ctx.errorReporter.reportField('array.unique', field, error);
      return;
    }

    final values = field.value as List;
    final unique = values.toSet().toList();

    if (values.length != unique.length) {
      final error =
          ctx.errorReporter.format('array.unique', field, message, {});
      ctx.errorReporter.reportField('array.unique', field, error);
    }
  }
}

final class VineArrayMinLengthRule implements VineRule {
  final int minValue;
  final String? message;

  const VineArrayMinLengthRule(this.minValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if ((field.value as List).length < minValue) {
      final error =
          ctx.errorReporter.format('array.minLength', field, message, {
        'min': minValue,
      });

      ctx.errorReporter.reportField('array.minLength', field, error);
    }
  }
}

final class VineArrayMaxLengthRule implements VineRule {
  final int maxValue;
  final String? message;

  const VineArrayMaxLengthRule(this.maxValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if ((field.value as List).length > maxValue) {
      final error =
          ctx.errorReporter.format('array.maxLength', field, message, {
        'max': maxValue,
      });

      ctx.errorReporter.reportField('array.maxLength', field, error);
    }
  }
}

final class VineArrayFixedLengthRule implements VineRule {
  final int count;
  final String? message;

  const VineArrayFixedLengthRule(this.count, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if ((field.value as List).length != count) {
      final error =
          ctx.errorReporter.format('array.fixedLength', field, message, {
        'length': count,
      });
      ctx.errorReporter.reportField('array.fixedLength', field, error);
    }
  }
}
