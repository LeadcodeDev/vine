import 'dart:collection';

import 'package:vine/src/rules/group_object_rule.dart';
import 'package:vine/vine.dart';

final class VineGroupSchema extends RuleParser implements VineGroup {
  VineGroupSchema(super._rules);

  @override
  VineGroup when(bool Function(Map<String, dynamic> data) fn, Map<String, VineSchema> object) {
    super.addRule((ctx, field) => groupObjectRuleHandler(ctx, field, fn, object));
    return this;
  }

  @override
  VineGroup otherwise(Function(VineValidationContext, FieldContext) fn) {
    super.addRule(fn);
    return this;
  }

  @override
  VineGroup clone() {
    return VineGroupSchema(Queue.of(rules));
  }
}
