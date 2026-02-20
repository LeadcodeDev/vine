import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/vine.dart';

final class VineBooleanRule implements VineRule {
  final bool literal;
  final String? message;

  const VineBooleanRule(this.literal, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final bool? content = !literal
        ? switch (field.value) {
            String() => bool.tryParse(field.value.toString()),
            bool() => field.value,
            _ => null
          }
        : switch (field.value) {
            '0' || 0 => false,
            '1' || 1 => true,
            String() => bool.tryParse(field.value),
            bool() => field.value,
            _ => null,
          };

    if (content == null) {
      final error = ctx.errorReporter.format('boolean', field, message, {});
      ctx.errorReporter
          .reportField('boolean', field, error);
    } else {
      field.mutate(content);
    }
  }
}
