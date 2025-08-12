import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/vine.dart';

final class VineNullableRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value == null) {
      field.canBeContinue = false;
    }
  }
}

final class VineOptionalRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value is MissingValue) {
      field.canBeContinue = false;
      ctx.data.remove(field.name);
    }
  }
}

final class VineRequiredIfExistRule implements VineRule {
  final List<String> values;

  const VineRequiredIfExistRule(this.values);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    List<bool> matchs = [];

    for (final value in values) {
      matchs.add(currentContext.containsKey(value));
    }

    if (!matchs.contains(false) && field.value == null) {
      final error =
          ctx.errorReporter.format('requiredIfExists', field, null, {});
      ctx.errorReporter.report('requiredIfExists', field.customKeys, error);

      field.canBeContinue = false;
    }
  }
}

final class VineRequiredIfAnyExistRule implements VineRule {
  final List<String> values;

  const VineRequiredIfAnyExistRule(this.values);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    bool hasMatch = false;

    for (final value in values) {
      if (currentContext.containsKey(value)) {
        hasMatch = true;
        break;
      }
    }

    if (hasMatch && field.value == null) {
      final error =
          ctx.errorReporter.format('requiredIfExistsAny', field, null, {});
      ctx.errorReporter.report('requiredIfExistsAny', field.customKeys, error);

      field.canBeContinue = false;
    }
  }
}

final class VineRequiredIfMissingRule implements VineRule {
  final List<String> values;

  const VineRequiredIfMissingRule(this.values);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    List<bool> matchs = [];

    for (final value in values) {
      matchs.add(currentContext.containsKey(value));
    }

    if (!matchs.contains(true) && field.value == null) {
      final error =
          ctx.errorReporter.format('requiredIfMissing', field, null, {});
      ctx.errorReporter.report('requiredIfMissing', field.customKeys, error);

      field.canBeContinue = false;
    }
  }
}

final class VineRequiredIfAnyMissingRule implements VineRule {
  final List<String> values;

  const VineRequiredIfAnyMissingRule(this.values);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);
    bool hasMatch = false;

    for (final value in values) {
      if (currentContext.containsKey(value)) {
        hasMatch = true;
        break;
      }
    }

    if (!hasMatch && field.value == null) {
      final error =
          ctx.errorReporter.format('requiredIfMissingAny', field, null, {});
      ctx.errorReporter.report('requiredIfMissingAny', field.customKeys, error);

      field.canBeContinue = false;
    }
  }
}

final class VineTransformRule implements VineRule {
  final Function(VineValidationContext, VineFieldContext) fn;

  const VineTransformRule(this.fn);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final result = fn(ctx, field);
    field.mutate(result);
  }
}
