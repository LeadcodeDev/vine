import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/vine.dart';

void handleNumberConversionError(
    VineValidationContext ctx, VineFieldContext field, String? message) {
  final error = ctx.errorReporter.format('number', field, message, {});
  ctx.errorReporter.reportField('number', field, error);
}

final class VineNumberRule implements VineRule {
  final String? message;
  const VineNumberRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final value = field.value;
    if (value is num) return;
    if (value is! String) {
      handleNumberConversionError(ctx, field, message);
      return;
    }

    final parsed = num.tryParse(value);
    if (parsed == null) {
      handleNumberConversionError(ctx, field, message);
      return;
    }

    field.mutate(parsed);
  }
}

final class VineMinRule implements VineRule {
  final num minValue;
  final String? message;

  const VineMinRule(this.minValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case num value when value.isNegative || value < minValue) {
      final error = ctx.errorReporter.format('min', field, message, {
        'min': minValue,
      });

      ctx.errorReporter.reportField('min', field, error);
    }
  }
}

final class VineMaxRule implements VineRule {
  final num maxValue;
  final String? message;

  const VineMaxRule(this.maxValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case num value when value.isNegative || value > maxValue) {
      final error = ctx.errorReporter.format('max', field, message, {
        'max': maxValue,
      });

      ctx.errorReporter.reportField('max', field, error);
    }
  }
}

final class VineRangeRule implements VineRule {
  final List<num> values;
  final String? message;

  const VineRangeRule(this.values, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (!values.contains((field.value as num))) {
      final error = ctx.errorReporter.format('range', field, message, {
        'values': values,
      });

      ctx.errorReporter
          .reportField('range', field, error);
    }
  }
}

final class VineNegativeRule implements VineRule {
  final String? message;

  const VineNegativeRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case num value when !value.isNegative) {
      final error = ctx.errorReporter.format('negative', field, message, {});
      ctx.errorReporter
          .reportField('negative', field, error);
    }
  }
}

final class VinePositiveRule implements VineRule {
  final String? message;

  const VinePositiveRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case num value when value.isNegative) {
      final error = ctx.errorReporter.format('positive', field, message, {});
      ctx.errorReporter
          .reportField('positive', field, error);
    }
  }
}

final class VineDoubleRule implements VineRule {
  final String? message;

  const VineDoubleRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case num value when value is! double) {
      final error = ctx.errorReporter.format('double', field, message, {});
      ctx.errorReporter
          .reportField('double', field, error);
    }
  }
}

final class VineIntegerRule implements VineRule {
  final String? message;

  const VineIntegerRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case num value when value is! int) {
      final error = ctx.errorReporter.format('integer', field, message, {});
      ctx.errorReporter
          .reportField('integer', field, error);
    }
  }
}
