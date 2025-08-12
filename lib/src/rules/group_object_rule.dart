import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/rules/object_rule.dart';

final class VineObjectGroupRule implements VineRule {
  final bool Function(Map<String, dynamic> data) fn;
  final Map<String, VineSchema> object;

  const VineObjectGroupRule(this.fn, this.object);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (fn(ctx.data as Map<String, dynamic>)) {
      field.customKeys.add(field.name);
      VineObjectRule(object, null).handle(ctx, field);
    }
  }
}

final class VineObjectOtherwiseRule implements VineRule {
  final Function(VineValidationContext, VineFieldContext) fn;
  const VineObjectOtherwiseRule(this.fn);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    fn(ctx, field);
  }
}
