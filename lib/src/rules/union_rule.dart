import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/vine.dart';

final class VineUnionRule implements VineRule {
  final List<VineSchema> schemas;

  const VineUnionRule(this.schemas);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    field.customKeys.add(field.name);
    final currentField = VineField(field.name, field.value);
    currentField.isUnion = true;

    int failCount = 0;

    for (final schema in schemas) {
      final errorsBeforeAttempt = ctx.errorReporter.errors.length;
      schema.parse(ctx, currentField);

      if (ctx.errorReporter.errors.length > errorsBeforeAttempt) {
        ctx.errorReporter.rollbackTo(errorsBeforeAttempt);
        failCount++;
      } else {
        break;
      }
    }

    currentField.isUnion = false;

    if (failCount == schemas.length) {
      final error = ctx.errorReporter.format('union', field, null, {
        'types': schemas
            .map((schema) =>
                schema.runtimeType.toString().replaceFirst('Schema', ''))
            .join(', ')
      });

      ctx.errorReporter.report('union', field.customKeys, error);
    }
  }
}
