import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/vine.dart';

final class VineUnionRule implements VineRule {
  final List<VineSchema> schemas;

  const VineUnionRule(this.schemas);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final List errors = [];
    field.customKeys.add(field.name);
    final currentField = VineField(field.name, field.value);

    currentField.isUnion = true;
    for (final schema in schemas) {
      try {
        schema.parse(ctx, currentField);
      } catch (e) {
        errors.add(e);
      }
    }
    currentField.isUnion = false;

    if (errors.length == schemas.length) {
      final error = ctx.errorReporter.format('union', field, null, {
        'types': schemas
            .map((schema) =>
                schema.runtimeType.toString().replaceFirst('Schema', ''))
            .join(', ')
      });

      ctx.errorReporter.report('union', field.customKeys, error);
      throw ctx.errorReporter.createError({'errors': ctx.errorReporter.errors});
    }
  }
}
