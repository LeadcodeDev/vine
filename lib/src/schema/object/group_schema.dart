import 'package:vine/src/rules/group_object_rule.dart';
import 'package:vine/vine.dart';

final class VineGroupSchema extends RuleParser implements VineGroup {
  VineGroupSchema(super._rules);

  @override
  VineGroup when(bool Function(Map<String, dynamic> data) fn,
      Map<String, VineSchema> object) {
    super.rules.add(VineObjectGroupRule(fn, object));
    return this;
  }

  @override
  VineGroup otherwise(Function(VineValidationContext, VineFieldContext) fn) {
    super.rules.add(VineObjectOtherwiseRule(fn));
    return this;
  }

  @override
  VineGroup clone() {
    return VineGroupSchema([...rules]);
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {};
  }
}
