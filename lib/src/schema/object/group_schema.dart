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
    final clonedRules = rules.map((rule) {
      if (rule is VineObjectGroupRule) {
        final clonedObject = <String, VineSchema>{};
        for (final entry in rule.object.entries) {
          clonedObject[entry.key] = entry.value.clone();
        }
        return VineObjectGroupRule(rule.fn, clonedObject);
      }
      return rule;
    }).toList();

    return VineGroupSchema(clonedRules);
  }

  @override
  Map<String, dynamic> introspect({String? name}) {
    return {};
  }
}
