import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/field_pool.dart';
import 'package:vine/src/rule_parser.dart';

final class VineArrayRule implements VineRule {
  final VineSchema schema;

  const VineArrayRule(this.schema);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final copy = field.customKeys;

    if (field.value case List values) {
      final currentSchema = schema as RuleParser;
      final copyRules = currentSchema.rules.toList();

      for (int i = 0; i < values.length; i++) {
        final currentField = VineFieldPool.acquire(field.name, values[i]);

        currentSchema.rules.clear();
        currentSchema.rules.addAll(copyRules);

        currentField.customKeys.add(i.toString());
        schema.parse(ctx, currentField);

        currentField.customKeys
          ..clear()
          ..addAll(copy);

        currentField.mutate([...field.value, currentField.value]);
        VineFieldPool.release(currentField);
      }

      return;
    }

    final error = ctx.errorReporter.format('array', field, null, {});
    ctx.errorReporter.report('array', [...field.customKeys, field.name], error);
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
      ctx.errorReporter
          .report('array.unique', [...field.customKeys, field.name], error);
      return;
    }

    final values = field.value as List;
    final unique = values.toSet().toList();

    if (values.length != unique.length) {
      final error =
          ctx.errorReporter.format('array.unique', field, message, {});
      ctx.errorReporter
          .report('array.unique', [...field.customKeys, field.name], error);
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

      ctx.errorReporter
          .report('array.minLength', [...field.customKeys, field.name], error);
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

      ctx.errorReporter
          .report('array.maxLength', [...field.customKeys, field.name], error);
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
      ctx.errorReporter.report(
          'array.fixedLength', [...field.customKeys, field.name], error);
    }
  }
}
