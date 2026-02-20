import 'package:vine/vine.dart';

abstract interface class RuleParserContract {
  List<VineRule> get rules;
}

class RuleParser implements RuleParserContract {
  @override
  List<VineRule> rules;

  bool isNullable = false;
  bool isOptional = false;

  RuleParser(this.rules);

  VineFieldContext parse(VineValidationContext ctx, VineFieldContext field) {
    for (int i = 0; i < rules.length; i++) {
      final rule = rules[i];
      final errorsBefore = ctx.errorReporter.errors.length;
      rule.handle(ctx, field);

      if (!field.canBeContinue) break;
      if (ctx.errorReporter.errors.length > errorsBefore) break;
    }

    return field;
  }
}
