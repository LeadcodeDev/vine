import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/vine.dart';

final class VineDateRule implements VineRule {
  final String? message;
  const VineDateRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value is MissingValue) {
      final error =
          ctx.errorReporter.format('date.required', field, message, {});
      ctx.errorReporter
          .report('date.required', [...field.customKeys, field.name], error);
      return;
    }

    final date =
        field.value is DateTime ? field.value : DateTime.tryParse(field.value);
    if (date != null) {
      field.mutate(date);
      return;
    }

    final error = ctx.errorReporter.format('date', field, message, {});
    ctx.errorReporter.report('date', [...field.customKeys, field.name], error);
  }
}

final class VineDateBeforeRule implements VineRule {
  final DateTime date;
  final String? message;

  const VineDateBeforeRule(this.date, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case DateTime value when !value.isBefore(date)) {
      final error = ctx.errorReporter.format('date.before', field, message, {
        'date': date,
      });

      ctx.errorReporter
          .report('date.before', [...field.customKeys, field.name], error);
    }
  }
}

final class VineDateAfterRule implements VineRule {
  final DateTime date;
  final String? message;

  const VineDateAfterRule(this.date, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case DateTime value when !value.isAfter(date)) {
      final error = ctx.errorReporter.format('date.after', field, message, {
        'date': date,
      });

      ctx.errorReporter
          .report('date.after', [...field.customKeys, field.name], error);
    }
  }
}

final class VineDateBetweenRule implements VineRule {
  final DateTime start;
  final DateTime end;
  final String? message;

  const VineDateBetweenRule(this.start, this.end, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case DateTime value
        when !(value.isAfter(start) && value.isBefore(end))) {
      final error = ctx.errorReporter.format('date.between', field, message, {
        'start': start,
        'end': end,
      });

      ctx.errorReporter
          .report('date.between', [...field.customKeys, field.name], error);
    }
  }
}

final class VineDateBeforeFieldRule implements VineRule {
  final String targetField;
  final String? message;

  const VineDateBeforeFieldRule(this.targetField, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    final DateTime? targetFieldDate = currentContext[targetField] != null
        ? currentContext[targetField] is DateTime
            ? currentContext[targetField]
            : DateTime.tryParse(currentContext[targetField])
        : null;

    if (field.value case DateTime value
        when targetFieldDate != null && !value.isBefore(targetFieldDate)) {
      final error =
          ctx.errorReporter.format('date.beforeField', field, message, {
        'field': targetField,
      });

      ctx.errorReporter
          .report('date.beforeField', [...field.customKeys, field.name], error);
    }
  }
}

final class VineDateAfterFieldRule implements VineRule {
  final String targetField;
  final String? message;

  const VineDateAfterFieldRule(this.targetField, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    final DateTime? targetFieldDate = currentContext[targetField] != null
        ? currentContext[targetField] is DateTime
            ? currentContext[targetField]
            : DateTime.tryParse(currentContext[targetField])
        : null;

    if (field.value case DateTime value
        when targetFieldDate != null && !value.isAfter(targetFieldDate)) {
      final error =
          ctx.errorReporter.format('date.afterField', field, message, {
        'field': targetField,
      });

      ctx.errorReporter
          .report('date.afterField', [...field.customKeys, field.name], error);
    }
  }
}

final class VineDateBetweenFieldRule implements VineRule {
  final String startField;
  final String endField;
  final String? message;

  const VineDateBetweenFieldRule(this.startField, this.endField, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    final DateTime? startFieldDate = currentContext[startField] != null
        ? currentContext[startField] is DateTime
            ? currentContext[startField]
            : DateTime.tryParse(currentContext[startField])
        : null;

    final DateTime? endFieldDate = currentContext[endField] != null
        ? currentContext[endField] is DateTime
            ? currentContext[endField]
            : DateTime.tryParse(currentContext[endField])
        : null;

    if (startFieldDate == null) {
      final error = ctx.errorReporter
          .format('date.required', field, message, {'field': startField});
      ctx.errorReporter
          .report('date.required', [...field.customKeys, field.name], error);
      return;
    }

    if (endFieldDate == null) {
      final error = ctx.errorReporter
          .format('date.required', field, message, {'field': endField});
      ctx.errorReporter
          .report('date.required', [...field.customKeys, field.name], error);
      return;
    }

    if (field.value case DateTime value
        when !(value.isAfter(startFieldDate) && value.isBefore(endFieldDate))) {
      final error = ctx.errorReporter.format('date.between', field, message, {
        'start': startField,
        'end': endField,
      });

      ctx.errorReporter.report(
          'date.betweenFields', [...field.customKeys, field.name], error);
    }
  }
}
