import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/field.dart';
import 'package:vine/src/helper.dart';
import 'package:vine/src/mapped_errors.dart';
import 'package:vine/src/rules/any_rule.dart';
import 'package:vine/src/rules/array_rule.dart';
import 'package:vine/src/rules/basic_rule.dart';
import 'package:vine/src/rules/boolean_rule.dart';
import 'package:vine/src/rules/date_rule.dart';
import 'package:vine/src/rules/enum_rule.dart';
import 'package:vine/src/rules/group_object_rule.dart';
import 'package:vine/src/rules/number_rule.dart';
import 'package:vine/src/rules/object_rule.dart';
import 'package:vine/src/rules/string_rule.dart';
import 'package:vine/src/rules/union_rule.dart';
import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/schema/any_schema.dart';
import 'package:vine/src/schema/array_schema.dart';
import 'package:vine/src/schema/boolean_schema.dart';
import 'package:vine/src/schema/date_schema.dart';
import 'package:vine/src/schema/enum_schema.dart';
import 'package:vine/src/schema/number_schema.dart';
import 'package:vine/src/schema/object/group_schema.dart';
import 'package:vine/src/schema/object/object_schema.dart';
import 'package:vine/src/schema/string_schema.dart';
import 'package:vine/src/schema/union_schema.dart';
import 'package:string_validator/string_validator.dart';

typedef CompiledValidatorFn = void Function(
    VineValidationContext ctx, VineFieldContext field);

class SchemaCompiler {
  static CompiledValidatorFn compile(VineSchema schema) {
    return _compileSchema(schema);
  }

  static CompiledValidatorFn _compileSchema(VineSchema schema) {
    return switch (schema) {
      VineObjectSchema() => _compileObject(schema),
      VineArraySchema() => _compileArray(schema),
      VineUnionSchema() => _compileUnion(schema),
      VineGroupSchema() => _compileGroup(schema),
      VineStringSchema() => _compileRules(schema.rules),
      VineNumberSchema() => _compileRules(schema.rules),
      VineBooleanSchema() => _compileRules(schema.rules),
      VineDateSchema() => _compileRules(schema.rules),
      VineEnumSchema() => _compileRules(schema.rules),
      VineAnySchema() => _compileRules(schema.rules),
      _ => (ctx, field) => schema.parse(ctx, field),
    };
  }

  // ---------------------------------------------------------------------------
  // Object compilation
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileObject(VineObjectSchema schema) {
    final properties = schema.properties;
    final int length = properties.length;
    final keys = properties.keys.toList(growable: false);
    final schemas = properties.values.toList(growable: false);
    final compiledChildren = List<CompiledValidatorFn>.generate(
      length,
      (i) => _compileSchema(schemas[i]),
      growable: false,
    );
    // Pre-compute child types for customKeys handling (mirrors VineObjectRule behavior)
    // 0 = normal, 1 = VineArray, 2 = VineObject
    final childTypes = List<int>.generate(length, (i) {
      final s = schemas[i];
      if (s is VineArraySchema) return 1;
      if (s is VineObjectSchema) return 2;
      return 0;
    }, growable: false);

    // Check if any child has a non-zero type (needs customKeys handling)
    final hasComplexChildren = childTypes.any((t) => t != 0);

    // Find object rule for custom message
    final objectRule = schema.rules.whereType<VineObjectRule>().firstOrNull;
    final objectMsg = objectRule?.message ?? mappedErrors['object']!;

    // Compile group rules
    final groupRules = schema.rules.whereType<VineObjectGroupRule>().toList();
    final compiledGroups = groupRules.isNotEmpty
        ? groupRules.map(_compileGroupRule).toList(growable: false)
        : const <_CompiledGroupRule>[];
    final otherwiseRule =
        schema.rules.whereType<VineObjectOtherwiseRule>().firstOrNull;

    // Pre-compile any prepended rules (nullable, optional, requiredIf*)
    final prependedRules = <CompiledValidatorFn>[];
    for (final rule in schema.rules) {
      if (rule is VineNullableRule ||
          rule is VineOptionalRule ||
          rule is VineRequiredIfExistRule ||
          rule is VineRequiredIfAnyExistRule ||
          rule is VineRequiredIfMissingRule ||
          rule is VineRequiredIfAnyMissingRule) {
        prependedRules.add(_compileRule(rule));
      }
    }

    // Compile any transform rules
    final transformRules = schema.rules
        .whereType<VineTransformRule>()
        .map(_compileRule)
        .toList(growable: false);

    final hasPrepended = prependedRules.isNotEmpty;
    final hasGroups = compiledGroups.isNotEmpty;
    final hasTransforms = transformRules.isNotEmpty;

    // Pre-allocate a reusable VineField (captured in closure, reused across calls)
    final currentField = VineField('', null);

    // Fast path: simple flat object with no groups, no transforms, no prepended rules, no complex children
    if (!hasPrepended && !hasGroups && !hasTransforms && !hasComplexChildren) {
      // Pre-allocate a result map template with known keys
      final templateMap = <String, dynamic>{for (final k in keys) k: null};

      // Check if ALL children are simple leaf schemas (string/number/boolean/date/enum/any)
      // that don't need customKeys on the happy path
      final allLeafChildren = !schemas.any((s) =>
          s is VineObjectSchema ||
          s is VineArraySchema ||
          s is VineUnionSchema ||
          s is VineGroupSchema);

      if (allLeafChildren) {
        // Check if any child rule needs field context (sameAs, notSameAs, confirmed, etc.)
        bool needsCustomKeys = false;
        for (final s in schemas) {
          final rules = _getRulesFromLeafSchema(s);
          for (final r in rules) {
            if (r is VineSameAsRule ||
                r is VineNotSameAsRule ||
                r is VineConfirmedRule ||
                r is VineRequiredIfExistRule ||
                r is VineRequiredIfAnyExistRule ||
                r is VineRequiredIfMissingRule ||
                r is VineRequiredIfAnyMissingRule) {
              needsCustomKeys = true;
              break;
            }
          }
          if (needsCustomKeys) break;
        }

        if (!needsCustomKeys) {
          // Check if any child has nullable/optional (need safe null handling)
          bool anyChildNullSensitive = false;
          for (final s in schemas) {
            final rules = _getRulesFromLeafSchema(s);
            if (rules
                .any((r) => r is VineNullableRule || r is VineOptionalRule)) {
              anyChildNullSensitive = true;
              break;
            }
          }

          // Check if all children are pure (no mutations)
          bool childrenArePure = true;
          for (final s in schemas) {
            final rules = _getRulesFromLeafSchema(s);
            if (!rules.every(_isNonMutatingRule)) {
              childrenArePure = false;
              break;
            }
          }

          if (childrenArePure) {
            return _compileMonomorphicFlatPure(keys, compiledChildren, length,
                objectMsg, !anyChildNullSensitive);
          }

          return _compileMonomorphicFlat(keys, compiledChildren, length,
              objectMsg, !anyChildNullSensitive);
        }
      }

      return (VineValidationContext ctx, VineFieldContext field) {
        final fieldValue = field.value;
        if (fieldValue is! Map) {
          ctx.errorReporter.reportField('object', field, objectMsg);
          return;
        }

        final resultMap = Map<String, dynamic>.of(templateMap);
        final parentKeys = field.customKeys;
        final parentKeysEmpty = parentKeys.isEmpty;

        for (int i = 0; i < length; i++) {
          final key = keys[i];
          final raw = fieldValue[key];
          currentField.name = key;
          currentField.value = (raw == null && !fieldValue.containsKey(key))
              ? _missingValue
              : raw;
          currentField.canBeContinue = true;

          if (!parentKeysEmpty) {
            currentField.customKeys.clear();
            currentField.customKeys.addAll(parentKeys);
          } else {
            currentField.customKeys.clear();
          }

          compiledChildren[i](ctx, currentField);
          resultMap[key] = currentField.value;

          if (!currentField.canBeContinue || ctx.errorReporter.hasError) break;
        }

        field.mutate(resultMap);
      };
    }

    // Semi-fast path: no groups, no transforms, no prepended, but has complex children
    if (!hasPrepended && !hasGroups && !hasTransforms) {
      final templateMap = <String, dynamic>{for (final k in keys) k: null};

      return (VineValidationContext ctx, VineFieldContext field) {
        final fieldValue = field.value;
        if (fieldValue is! Map) {
          ctx.errorReporter.reportField('object', field, objectMsg);
          return;
        }

        final resultMap = Map<String, dynamic>.of(templateMap);
        final parentKeysLength = field.customKeys.length;

        for (int i = 0; i < length; i++) {
          final key = keys[i];
          final raw = fieldValue[key];
          currentField.name = key;
          currentField.value = (raw == null && !fieldValue.containsKey(key))
              ? _missingValue
              : raw;
          currentField.canBeContinue = true;
          currentField.customKeys.clear();
          currentField.customKeys.addAll(field.customKeys);

          final childType = childTypes[i];
          if (childType == 1) {
            field.customKeys.add(key);
          } else if (childType == 2) {
            currentField.customKeys.add(key);
            field.customKeys.add(key);
          }

          compiledChildren[i](ctx, currentField);
          resultMap[key] = currentField.value;

          if (!currentField.canBeContinue || ctx.errorReporter.hasError) break;
        }

        field.customKeys.length = parentKeysLength;
        field.mutate(resultMap);
      };
    }

    // Generic path: with prepended rules, groups, or transforms
    final genericTemplateMap = <String, dynamic>{for (final k in keys) k: null};

    return (VineValidationContext ctx, VineFieldContext field) {
      // Run prepended rules (nullable, optional, requiredIf*)
      for (int p = 0; p < prependedRules.length; p++) {
        final errorsBefore = ctx.errorReporter.errorCount;
        prependedRules[p](ctx, field);
        if (!field.canBeContinue) return;
        if (ctx.errorReporter.errorCount > errorsBefore) return;
      }

      final fieldValue = field.value;
      if (fieldValue is! Map) {
        ctx.errorReporter.reportField('object', field, objectMsg);
        return;
      }

      final resultMap = Map<String, dynamic>.of(genericTemplateMap);
      final parentKeysLength = field.customKeys.length;

      for (int i = 0; i < length; i++) {
        final key = keys[i];
        final raw = fieldValue[key];
        currentField.name = key;
        currentField.value =
            (raw == null && !fieldValue.containsKey(key)) ? _missingValue : raw;
        currentField.canBeContinue = true;
        currentField.isUnion = false;
        currentField.customKeys.clear();
        currentField.customKeys.addAll(field.customKeys);

        final childType = childTypes[i];
        if (childType == 1) {
          // VineArray: add key to parent customKeys
          field.customKeys.add(key);
        } else if (childType == 2) {
          // VineObject: add key to both currentField and parent customKeys
          if (!fieldValue.containsKey(key)) {
            ctx.errorReporter.reportField('object', field, objectMsg);
          }
          currentField.customKeys.add(key);
          field.customKeys.add(key);
        }

        compiledChildren[i](ctx, currentField);
        resultMap[key] = currentField.value;

        if (!currentField.canBeContinue || ctx.errorReporter.hasError) break;
      }

      field.customKeys.length = parentKeysLength;

      // Run compiled group rules
      for (int g = 0; g < compiledGroups.length; g++) {
        final group = compiledGroups[g];
        if (group.condition(ctx.data as Map<String, dynamic>)) {
          final groupKeys = group.keys;
          final groupChildren = group.compiledChildren;
          for (int j = 0; j < groupKeys.length; j++) {
            final key = groupKeys[j];
            final raw = fieldValue[key];
            currentField.name = key;
            currentField.value = (raw == null && !fieldValue.containsKey(key))
                ? _missingValue
                : raw;
            currentField.canBeContinue = true;
            currentField.isUnion = false;
            currentField.customKeys.clear();
            currentField.customKeys.addAll(field.customKeys);

            groupChildren[j](ctx, currentField);
            resultMap[key] = currentField.value;

            if (!currentField.canBeContinue || ctx.errorReporter.hasError) {
              break;
            }
          }
        } else if (otherwiseRule != null && g == compiledGroups.length - 1) {
          otherwiseRule.fn(ctx, field);
        }
      }

      field.mutate(resultMap);

      // Run transform rules
      for (int t = 0; t < transformRules.length; t++) {
        transformRules[t](ctx, field);
      }
    };
  }

  static final _missingValue = MissingValue();

  // ---------------------------------------------------------------------------
  // Helper: get rules from a leaf schema
  // ---------------------------------------------------------------------------
  static List<VineRule> _getRulesFromLeafSchema(VineSchema s) {
    return switch (s) {
      VineStringSchema() => s.rules,
      VineNumberSchema() => s.rules,
      VineBooleanSchema() => s.rules,
      VineDateSchema() => s.rules,
      VineEnumSchema() => s.rules,
      VineAnySchema() => s.rules,
      _ => const <VineRule>[],
    };
  }

  // ---------------------------------------------------------------------------
  // Helper: check if a rule never mutates field.value
  // ---------------------------------------------------------------------------
  static bool _isNonMutatingRule(VineRule r) {
    return r is VineStringRule ||
        r is VineMinLengthRule ||
        r is VineMaxLengthRule ||
        r is VineFixedLengthRule ||
        r is VineEmailRule ||
        r is VinePhoneRule ||
        r is VineIpAddressRule ||
        r is VineRegexRule ||
        r is VineHexColorRule ||
        r is VineUrlRule ||
        r is VineAlphaRule ||
        r is VineAlphaNumericRule ||
        r is VineStartWithRule ||
        r is VineEndWithRule ||
        r is VineUuidRule ||
        r is VineCreditCardRule ||
        r is VineSameAsRule ||
        r is VineNotSameAsRule ||
        r is VineInListRule ||
        r is VineNotInListRule ||
        r is VineMinRule ||
        r is VineMaxRule ||
        r is VineRangeRule ||
        r is VineNegativeRule ||
        r is VinePositiveRule ||
        r is VineDoubleRule ||
        r is VineIntegerRule ||
        r is VineAnyRule;
  }

  // ---------------------------------------------------------------------------
  // Monomorphic flat object compilation — zero-copy (pure children)
  // When no child rule mutates values, return the input map directly.
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileMonomorphicFlatPure(
    List<String> keys,
    List<CompiledValidatorFn> compiledChildren,
    int length,
    String objectMsg,
    bool canUseFastNull,
  ) {
    final currentField = VineField('', null);

    if (canUseFastNull) {
      return (VineValidationContext ctx, VineFieldContext field) {
        final fv = field.value;
        if (fv is! Map) {
          ctx.errorReporter.reportField('object', field, objectMsg);
          return;
        }

        for (int i = 0; i < length; i++) {
          final key = keys[i];
          currentField.name = key;
          currentField.value = fv[key] ?? _missingValue;
          currentField.canBeContinue = true;

          compiledChildren[i](ctx, currentField);

          if (!currentField.canBeContinue || ctx.errorReporter.hasError) {
            field.mutate(fv);
            return;
          }
        }

        // Zero-copy: return input map directly (no child mutated any value)
        field.mutate(fv);
      };
    }

    // Safe null path (nullable/optional children)
    return (VineValidationContext ctx, VineFieldContext field) {
      final fv = field.value;
      if (fv is! Map) {
        ctx.errorReporter.reportField('object', field, objectMsg);
        return;
      }

      for (int i = 0; i < length; i++) {
        final key = keys[i];
        final raw = fv[key];
        currentField.name = key;
        currentField.value =
            (raw == null && !fv.containsKey(key)) ? _missingValue : raw;
        currentField.canBeContinue = true;

        compiledChildren[i](ctx, currentField);

        if (!currentField.canBeContinue || ctx.errorReporter.hasError) {
          field.mutate(fv);
          return;
        }
      }

      field.mutate(fv);
    };
  }

  // ---------------------------------------------------------------------------
  // Monomorphic flat object compilation
  // Per-child VineField, single lookup, deferred map construction
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileMonomorphicFlat(
    List<String> keys,
    List<CompiledValidatorFn> compiledChildren,
    int length,
    String objectMsg,
    bool canUseFastNull,
  ) {
    // Shared VineField (reused across calls, better cache locality)
    final currentField = VineField('', null);
    // Pre-allocate template map for fast cloning
    final templateMap = <String, dynamic>{for (final k in keys) k: null};

    if (canUseFastNull) {
      // Fast null path: single lookup with ?? _missingValue
      return (VineValidationContext ctx, VineFieldContext field) {
        final fv = field.value;
        if (fv is! Map) {
          ctx.errorReporter.reportField('object', field, objectMsg);
          return;
        }

        final resultMap = Map<String, dynamic>.of(templateMap);

        for (int i = 0; i < length; i++) {
          final key = keys[i];
          currentField.name = key;
          currentField.value = fv[key] ?? _missingValue;
          currentField.canBeContinue = true;

          compiledChildren[i](ctx, currentField);
          resultMap[key] = currentField.value;

          if (!currentField.canBeContinue || ctx.errorReporter.hasError) {
            break;
          }
        }

        field.mutate(resultMap);
      };
    }

    // Safe null path: distinguish null values from missing keys
    return (VineValidationContext ctx, VineFieldContext field) {
      final fv = field.value;
      if (fv is! Map) {
        ctx.errorReporter.reportField('object', field, objectMsg);
        return;
      }

      final resultMap = Map<String, dynamic>.of(templateMap);

      for (int i = 0; i < length; i++) {
        final key = keys[i];
        final raw = fv[key];
        currentField.name = key;
        currentField.value =
            (raw == null && !fv.containsKey(key)) ? _missingValue : raw;
        currentField.canBeContinue = true;

        compiledChildren[i](ctx, currentField);
        resultMap[key] = currentField.value;

        if (!currentField.canBeContinue || ctx.errorReporter.hasError) {
          break;
        }
      }

      field.mutate(resultMap);
    };
  }

  // ---------------------------------------------------------------------------
  // Array compilation
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileArray(VineArraySchema schema) {
    final arrayRule = schema.rules.whereType<VineArrayRule>().first;
    final compiledElement = _compileSchema(arrayRule.schema);

    // Compile additional rules (minLength, maxLength, unique, etc.)
    final additionalRules = schema.rules
        .where((r) => r is! VineArrayRule)
        .map(_compileRule)
        .toList(growable: false);

    final arrayErrorMsg = mappedErrors['array']!;

    // Pre-allocate reusable VineField
    final currentField = VineField('', null);

    return (VineValidationContext ctx, VineFieldContext field) {
      // Run prepended rules first (nullable, optional)
      for (int a = 0; a < additionalRules.length; a++) {
        final rule = additionalRules[a];
        final errorsBefore = ctx.errorReporter.errorCount;
        rule(ctx, field);
        if (!field.canBeContinue) return;
        if (ctx.errorReporter.errorCount > errorsBefore) return;
      }

      if (field.value case List values) {
        final result = List<dynamic>.filled(values.length, null);
        currentField.customKeys.clear();
        currentField.customKeys.addAll(field.customKeys);
        final baseLength = currentField.customKeys.length;

        for (int i = 0; i < values.length; i++) {
          currentField.name = field.name;
          currentField.value = values[i];
          currentField.canBeContinue = true;
          currentField.isUnion = false;
          currentField.customKeys.length = baseLength;
          currentField.customKeys.add(_indexToString(i));

          compiledElement(ctx, currentField);
          result[i] = currentField.value;
        }
        field.mutate(result);
        return;
      }

      ctx.errorReporter.reportField('array', field, arrayErrorMsg);
    };
  }

  // ---------------------------------------------------------------------------
  // Union compilation
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileUnion(VineUnionSchema schema) {
    // Access the internal schemas through the union rule
    final unionRule = schema.rules.whereType<VineUnionRule>().first;
    final compiledSchemas =
        unionRule.schemas.map(_compileSchema).toList(growable: false);
    final schemaTypes = unionRule.schemas
        .map((s) => s.runtimeType.toString().replaceFirst('Schema', ''))
        .join(', ');

    // Compile prepended rules (nullable, optional, requiredIf*)
    final prependedRules = <CompiledValidatorFn>[];
    for (final rule in schema.rules) {
      if (rule is VineNullableRule ||
          rule is VineOptionalRule ||
          rule is VineRequiredIfExistRule ||
          rule is VineRequiredIfAnyExistRule ||
          rule is VineRequiredIfMissingRule ||
          rule is VineRequiredIfAnyMissingRule) {
        prependedRules.add(_compileRule(rule));
      }
    }

    // Compile post-rules (transform, etc.)
    final postRules = <CompiledValidatorFn>[];
    for (final rule in schema.rules) {
      if (rule is VineTransformRule) {
        postRules.add(_compileRule(rule));
      }
    }

    return (VineValidationContext ctx, VineFieldContext field) {
      // Run prepended rules
      for (int p = 0; p < prependedRules.length; p++) {
        final errorsBefore = ctx.errorReporter.errorCount;
        prependedRules[p](ctx, field);
        if (!field.canBeContinue) return;
        if (ctx.errorReporter.errorCount > errorsBefore) return;
      }

      field.customKeys.add(field.name);
      final currentField = VineField(field.name, field.value);
      currentField.isUnion = true;

      int failCount = 0;

      for (int i = 0; i < compiledSchemas.length; i++) {
        final errorsBeforeAttempt = ctx.errorReporter.errorCount;
        compiledSchemas[i](ctx, currentField);

        if (ctx.errorReporter.errorCount > errorsBeforeAttempt) {
          ctx.errorReporter.rollbackTo(errorsBeforeAttempt);
          failCount++;
        } else {
          break;
        }
      }

      currentField.isUnion = false;

      if (failCount == compiledSchemas.length) {
        final error = ctx.errorReporter.format('union', field, null, {
          'types': schemaTypes,
        });
        ctx.errorReporter.report('union', field.customKeys, error);
      } else {
        field.mutate(currentField.value);

        // Run post-rules (transform, etc.)
        for (int t = 0; t < postRules.length; t++) {
          final errorsBefore = ctx.errorReporter.errorCount;
          postRules[t](ctx, field);
          if (!field.canBeContinue) return;
          if (ctx.errorReporter.errorCount > errorsBefore) return;
        }
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Group compilation
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileGroup(VineGroupSchema schema) {
    final compiledRules =
        schema.rules.map(_compileRule).toList(growable: false);

    return (VineValidationContext ctx, VineFieldContext field) {
      for (int i = 0; i < compiledRules.length; i++) {
        final errorsBefore = ctx.errorReporter.errorCount;
        compiledRules[i](ctx, field);
        if (!field.canBeContinue) return;
        if (ctx.errorReporter.errorCount > errorsBefore) return;
      }
    };
  }

  static _CompiledGroupRule _compileGroupRule(VineObjectGroupRule rule) {
    final entries = rule.object.entries.toList();
    final keys = entries.map((e) => e.key).toList(growable: false);
    final compiledChildren =
        entries.map((e) => _compileSchema(e.value)).toList(growable: false);

    return _CompiledGroupRule(rule.fn, keys, compiledChildren);
  }

  // ---------------------------------------------------------------------------
  // Rules compilation — transforms a list of VineRule into a single closure
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileRules(List<VineRule> rules) {
    if (rules.isEmpty) return _noop;

    final compiled = rules.map(_compileRule).toList(growable: false);
    final int length = compiled.length;

    if (length == 1) return compiled[0];

    if (length == 2) {
      final first = compiled[0];
      final second = compiled[1];
      return (VineValidationContext ctx, VineFieldContext field) {
        final eb0 = ctx.errorReporter.errorCount;
        first(ctx, field);
        if (!field.canBeContinue) return;
        if (ctx.errorReporter.errorCount > eb0) return;
        second(ctx, field);
      };
    }

    return (VineValidationContext ctx, VineFieldContext field) {
      for (int i = 0; i < length; i++) {
        final errorsBefore = ctx.errorReporter.errorCount;
        compiled[i](ctx, field);
        if (!field.canBeContinue) return;
        if (ctx.errorReporter.errorCount > errorsBefore) return;
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Individual rule compilation — each VineRule becomes a specialized closure
  // ---------------------------------------------------------------------------
  static CompiledValidatorFn _compileRule(VineRule rule) {
    return switch (rule) {
      // === String rules ===
      VineStringRule() => _compileStringTypeCheck(rule.message),
      VineMinLengthRule() => _compileMinLength(rule.minValue, rule.message),
      VineMaxLengthRule() => _compileMaxLength(rule.maxValue, rule.message),
      VineFixedLengthRule() => _compileFixedLength(rule.count, rule.message),
      VineEmailRule() => _compileEmail(rule.message),
      VinePhoneRule() => _compilePhone(rule.regex, rule.message),
      VineIpAddressRule() => _compileIpAddress(rule.version, rule.message),
      VineRegexRule() => _compileRegex(rule.regex, rule.message),
      VineHexColorRule() => _compileHexColor(rule.message),
      VineUrlRule() => _compileUrl(rule.protocols, rule.requireTld,
          rule.requireProtocol, rule.allowUnderscores, rule.message),
      VineAlphaRule() => _compileAlpha(rule.message),
      VineAlphaNumericRule() => _compileAlphaNumeric(rule.message),
      VineStartWithRule() =>
        _compileStartWith(rule.attemptedValue, rule.message),
      VineEndWithRule() => _compileEndWith(rule.attemptedValue, rule.message),
      VineConfirmedRule() =>
        _compileConfirmed(rule.targetField, rule.include, rule.message),
      VineTrimRule() => _trim,
      VineUpperCaseRule() => _upperCase,
      VineLowerCaseRule() => _lowerCase,
      VineToCamelCaseRule() => _toCamelCase,
      VineToKebabCaseRule() => _toKebabCase,
      VineToSnakeCaseRule() => _toSnakeCase,
      VineToPascalCaseRule() => _toPascalCase,
      VineToTitleCaseRule() => _toTitleCase,
      VineToSentenceCaseRule() => _toSentenceCase,
      VineToCapitalCaseRule() => _toCapitalCase,
      VineToConstantCaseRule() => _toConstantCase,
      VineToDotCaseRule() => _toDotCase,
      VineUuidRule() => _compileUuid(rule.version, rule.message),
      VineCreditCardRule() => _compileCreditCard(rule.message),
      VineSameAsRule() => _compileSameAs(rule.value, rule.message),
      VineNotSameAsRule() => _compileNotSameAs(rule.value, rule.message),
      VineInListRule() => _compileInList(rule.values, rule.message),
      VineNotInListRule() => _compileNotInList(rule.values, rule.message),
      VineNormalizeEmailRule() => (ctx, field) => rule.handle(ctx, field),

      // === Number rules ===
      VineNumberRule() => _compileNumberTypeCheck(rule.message),
      VineMinRule() => _compileMin(rule.minValue, rule.message),
      VineMaxRule() => _compileMax(rule.maxValue, rule.message),
      VineRangeRule() => _compileRange(rule.values, rule.message),
      VineNegativeRule() => _compileNegative(rule.message),
      VinePositiveRule() => _compilePositive(rule.message),
      VineDoubleRule() => _compileDouble(rule.message),
      VineIntegerRule() => _compileInteger(rule.message),

      // === Boolean rules ===
      VineBooleanRule() => _compileBooleanTypeCheck(rule.literal, rule.message),

      // === Date rules ===
      VineDateRule() => _compileDateTypeCheck(rule.message),
      VineDateBeforeRule() => _compileDateBefore(rule.date, rule.message),
      VineDateAfterRule() => _compileDateAfter(rule.date, rule.message),
      VineDateBetweenRule() =>
        _compileDateBetween(rule.start, rule.end, rule.message),
      VineDateBeforeFieldRule() => (ctx, field) => rule.handle(ctx, field),
      VineDateAfterFieldRule() => (ctx, field) => rule.handle(ctx, field),
      VineDateBetweenFieldRule() => (ctx, field) => rule.handle(ctx, field),

      // === Enum rules ===
      VineEnumRule() => _compileEnum(rule.source),

      // === Any rules ===
      VineAnyRule() => _noop,

      // === Array rules ===
      VineArrayRule() => (ctx, field) => rule.handle(ctx, field),
      VineArrayUniqueRule() => _compileArrayUnique(rule.message),
      VineArrayMinLengthRule() =>
        _compileArrayMinLength(rule.minValue, rule.message),
      VineArrayMaxLengthRule() =>
        _compileArrayMaxLength(rule.maxValue, rule.message),
      VineArrayFixedLengthRule() =>
        _compileArrayFixedLength(rule.count, rule.message),

      // === Basic rules (prepended) ===
      VineNullableRule() => (ctx, field) {
          if (field.value == null) field.canBeContinue = false;
        },
      VineOptionalRule() => (ctx, field) {
          if (field.value is MissingValue) {
            field.canBeContinue = false;
            ctx.data.remove(field.name);
          }
        },
      VineRequiredIfExistRule() => (ctx, field) => rule.handle(ctx, field),
      VineRequiredIfAnyExistRule() => (ctx, field) => rule.handle(ctx, field),
      VineRequiredIfMissingRule() => (ctx, field) => rule.handle(ctx, field),
      VineRequiredIfAnyMissingRule() => (ctx, field) => rule.handle(ctx, field),
      VineTransformRule() => (ctx, field) {
          field.mutate(rule.fn(ctx, field));
        },

      // === Object/Group rules ===
      VineObjectRule() => (ctx, field) => rule.handle(ctx, field),
      VineObjectGroupRule() => (ctx, field) => rule.handle(ctx, field),
      VineObjectOtherwiseRule() => (ctx, field) => rule.handle(ctx, field),
      VineUnionRule() => (ctx, field) => rule.handle(ctx, field),

      // === Fallback ===
      _ => (ctx, field) => rule.handle(ctx, field),
    };
  }

  // ---------------------------------------------------------------------------
  // Pre-compiled closures for string rules
  // ---------------------------------------------------------------------------

  static CompiledValidatorFn _compileStringTypeCheck(String? customMsg) {
    final msg = customMsg ?? mappedErrors['string']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value is! String) {
        ctx.errorReporter.reportField('string', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileMinLength(int min, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['minLength']!.replaceAll('{min}', min.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when value.length < min) {
        ctx.errorReporter.reportField('minLength', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileMaxLength(int max, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['maxLength']!.replaceAll('{max}', max.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when value.length > max) {
        ctx.errorReporter.reportField('maxLength', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileFixedLength(int count, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['fixedLength']!.replaceAll('{length}', count.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when value.length != count) {
        ctx.errorReporter.reportField('fixedLength', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileEmail(String? customMsg) {
    final msg = customMsg ?? mappedErrors['email']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !isEmailSimd(value)) {
        ctx.errorReporter.reportField('email', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compilePhone(RegExp? regex, String? customMsg) {
    final currentRegexp = regex ?? europeanPhoneRegex;
    final msg = customMsg ?? mappedErrors['phone']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !currentRegexp.hasMatch(value)) {
        ctx.errorReporter.reportField('phone', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileIpAddress(
      IpAddressVersion? version, String? customMsg) {
    final msg = customMsg ?? mappedErrors['ipAddress']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isIP(version?.value)) {
        ctx.errorReporter.reportField('ipAddress', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileRegex(RegExp regex, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['regex']!.replaceAll('{pattern}', regex.pattern);
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !regex.hasMatch(value)) {
        ctx.errorReporter.reportField('regex', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileHexColor(String? customMsg) {
    final msg = customMsg ?? mappedErrors['hexColor'] ?? 'Invalid hex color';
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isHexColor) {
        ctx.errorReporter.reportField('hexColor', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileUrl(
      List<String> protocols,
      bool requireTld,
      bool requireProtocol,
      bool allowUnderscores,
      String? customMsg) {
    final msg = customMsg ?? mappedErrors['url']!;
    final options = {
      'protocols': protocols,
      'requireTld': requireTld,
      'requireProtocol': requireProtocol,
      'allowUnderscores': allowUnderscores,
    };
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isURL(options)) {
        ctx.errorReporter.reportField('url', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileAlpha(String? customMsg) {
    final msg = customMsg ?? mappedErrors['alpha']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isAlpha) {
        ctx.errorReporter.reportField('alpha', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileAlphaNumeric(String? customMsg) {
    final msg = customMsg ?? mappedErrors['alphaNumeric']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isAlphanumeric) {
        ctx.errorReporter.reportField('alphaNumeric', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileStartWith(
      String attemptedValue, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['startWith']!.replaceAll('{value}', attemptedValue);
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value
          when !value.startsWith(attemptedValue)) {
        ctx.errorReporter.reportField('startWith', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileEndWith(
      String attemptedValue, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['endWith']!.replaceAll('{value}', attemptedValue);
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.endsWith(attemptedValue)) {
        ctx.errorReporter.reportField('endWith', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileConfirmed(
      String? targetField, bool include, String? customMsg) {
    return (VineValidationContext ctx, VineFieldContext field) {
      final confirmedKey = targetField ?? '${field.name}_confirmation';
      final hasKey = ctx.data.containsKey(confirmedKey);

      if (!hasKey) {
        final msg = customMsg ??
            mappedErrors['missingProperty']!
                .replaceAll('{field}', confirmedKey);
        ctx.errorReporter.reportField('missingProperty', field, msg);
      }

      final currentValue = ctx.data[confirmedKey];
      if ((field.value as String) != currentValue) {
        final msg = customMsg ??
            mappedErrors['confirmed']!
                .replaceAll('{attemptedName}', confirmedKey);
        ctx.errorReporter.reportField('confirmed', field, msg);
      }

      if (!include) {
        ctx.data.remove(confirmedKey);
      }
    };
  }

  static CompiledValidatorFn _compileUuid(
      UuidVersion? version, String? customMsg) {
    final msg = customMsg ?? mappedErrors['uuid']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isUUID()) {
        ctx.errorReporter.reportField('uuid', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileCreditCard(String? customMsg) {
    final msg = customMsg ?? mappedErrors['creditCard']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case String value when !value.isCreditCard) {
        ctx.errorReporter.reportField('creditCard', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileSameAs(String value, String? customMsg) {
    return (VineValidationContext ctx, VineFieldContext field) {
      final currentContext = ctx.getFieldContext(field.customKeys);
      if (currentContext[value] != field.value) {
        final error = ctx.errorReporter
            .format('sameAs', field, customMsg, {'field': value});
        ctx.errorReporter.reportField('sameAs', field, error);
      }
    };
  }

  static CompiledValidatorFn _compileNotSameAs(
      String value, String? customMsg) {
    return (VineValidationContext ctx, VineFieldContext field) {
      final currentContext = ctx.getFieldContext(field.customKeys);
      if (currentContext[value] == field.value) {
        final error = ctx.errorReporter
            .format('notSameAs', field, customMsg, {'field': value});
        ctx.errorReporter.reportField('notSameAs', field, error);
      }
    };
  }

  static CompiledValidatorFn _compileInList(
      List<String> values, String? customMsg) {
    final msg = customMsg ?? mappedErrors['inList']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (!values.contains(field.value)) {
        ctx.errorReporter.reportField('inList', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileNotInList(
      List<String> values, String? customMsg) {
    final msg = customMsg ?? mappedErrors['notInList']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (values.contains(field.value)) {
        ctx.errorReporter.reportField('notInList', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileNormalizeEmail(bool lowerCase) {
    final options = <String, bool>{'lowercase': lowerCase};
    return (VineValidationContext ctx, VineFieldContext field) {
      field.mutate((field.value as String).normalizeEmail(options));
    };
  }

  // ---------------------------------------------------------------------------
  // Pre-compiled closures for number rules
  // ---------------------------------------------------------------------------

  static CompiledValidatorFn _compileNumberTypeCheck(String? customMsg) {
    final msg = customMsg ?? mappedErrors['number']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      final value = field.value;
      if (value is num) return;
      if (value is! String) {
        ctx.errorReporter.reportField('number', field, msg);
        return;
      }
      final parsed = num.tryParse(value);
      if (parsed == null) {
        ctx.errorReporter.reportField('number', field, msg);
        return;
      }
      field.mutate(parsed);
    };
  }

  static CompiledValidatorFn _compileMin(num minValue, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['min']!.replaceAll('{min}', minValue.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case num value
          when value.isNegative || value < minValue) {
        ctx.errorReporter.reportField('min', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileMax(num maxValue, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['max']!.replaceAll('{max}', maxValue.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case num value
          when value.isNegative || value > maxValue) {
        ctx.errorReporter.reportField('max', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileRange(
      List<num> values, String? customMsg) {
    final msg = customMsg ?? mappedErrors['range']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (!values.contains(field.value as num)) {
        ctx.errorReporter.reportField('range', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileNegative(String? customMsg) {
    final msg = customMsg ?? mappedErrors['negative']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case num value when !value.isNegative) {
        ctx.errorReporter.reportField('negative', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compilePositive(String? customMsg) {
    final msg = customMsg ?? mappedErrors['positive']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case num value when value.isNegative) {
        ctx.errorReporter.reportField('positive', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileDouble(String? customMsg) {
    final msg = customMsg ?? mappedErrors['double']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case num value when value is! double) {
        ctx.errorReporter.reportField('double', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileInteger(String? customMsg) {
    final msg = customMsg ?? mappedErrors['integer']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case num value when value is! int) {
        ctx.errorReporter.reportField('integer', field, msg);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Pre-compiled closures for boolean rules
  // ---------------------------------------------------------------------------

  static CompiledValidatorFn _compileBooleanTypeCheck(
      bool literal, String? customMsg) {
    final msg = customMsg ?? mappedErrors['boolean']!;
    return (VineValidationContext ctx, VineFieldContext field) {
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
        ctx.errorReporter.reportField('boolean', field, msg);
      } else {
        field.mutate(content);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Pre-compiled closures for date rules
  // ---------------------------------------------------------------------------

  static CompiledValidatorFn _compileDateTypeCheck(String? customMsg) {
    final msg = customMsg ?? mappedErrors['date']!;
    final requiredMsg = customMsg ?? mappedErrors['date.required']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value is MissingValue) {
        ctx.errorReporter.reportField('date.required', field, requiredMsg);
        return;
      }
      final date = field.value is DateTime
          ? field.value
          : DateTime.tryParse(field.value);
      if (date != null) {
        field.mutate(date);
        return;
      }
      ctx.errorReporter.reportField('date', field, msg);
    };
  }

  static CompiledValidatorFn _compileDateBefore(
      DateTime date, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['date.before']!.replaceAll('{date}', date.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case DateTime value when !value.isBefore(date)) {
        ctx.errorReporter.reportField('date.before', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileDateAfter(
      DateTime date, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['date.after']!.replaceAll('{date}', date.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case DateTime value when !value.isAfter(date)) {
        ctx.errorReporter.reportField('date.after', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileDateBetween(
      DateTime start, DateTime end, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['date.between']!
            .replaceAll('{start}', start.toString())
            .replaceAll('{end}', end.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value case DateTime value
          when !(value.isAfter(start) && value.isBefore(end))) {
        ctx.errorReporter.reportField('date.between', field, msg);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Pre-compiled closures for enum rules
  // ---------------------------------------------------------------------------

  static CompiledValidatorFn _compileEnum(List<VineEnumerable> source) {
    final msg = mappedErrors['enum']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value == null) return;
      final values = source.where((element) => element.value == field.value);
      if (values.firstOrNull == null) {
        ctx.errorReporter.reportField('enum', field, msg);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Pre-compiled closures for array rules
  // ---------------------------------------------------------------------------

  static CompiledValidatorFn _compileArrayUnique(String? customMsg) {
    final msg = customMsg ?? mappedErrors['unique']!;
    return (VineValidationContext ctx, VineFieldContext field) {
      if (field.value is! List) {
        ctx.errorReporter.reportField('array.unique', field, msg);
        return;
      }
      final values = field.value as List;
      final seen = <dynamic>{};
      for (final item in values) {
        if (!seen.add(item)) {
          ctx.errorReporter.reportField('array.unique', field, msg);
          return;
        }
      }
    };
  }

  static CompiledValidatorFn _compileArrayMinLength(
      int minValue, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['array.minLength']!
            .replaceAll('{min}', minValue.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if ((field.value as List).length < minValue) {
        ctx.errorReporter.reportField('array.minLength', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileArrayMaxLength(
      int maxValue, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['array.maxLength']!
            .replaceAll('{max}', maxValue.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if ((field.value as List).length > maxValue) {
        ctx.errorReporter.reportField('array.maxLength', field, msg);
      }
    };
  }

  static CompiledValidatorFn _compileArrayFixedLength(
      int count, String? customMsg) {
    final msg = customMsg ??
        mappedErrors['array.fixedLength']!
            .replaceAll('{length}', count.toString());
    return (VineValidationContext ctx, VineFieldContext field) {
      if ((field.value as List).length != count) {
        ctx.errorReporter.reportField('array.fixedLength', field, msg);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Static transform closures (singleton — no allocation per compile)
  // ---------------------------------------------------------------------------

  static final _wordSeparatorRegex = RegExp(r'[_\s-]');

  static void _noop(VineValidationContext ctx, VineFieldContext field) {}

  static void _trim(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).trim());
  }

  static void _upperCase(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).toUpperCase());
  }

  static void _lowerCase(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).toLowerCase());
  }

  static void _toCamelCase(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value) {
      final buffer = StringBuffer();
      final parts = value.split(_wordSeparatorRegex);
      buffer.write(parts.first.toLowerCase());
      for (final part in parts.skip(1)) {
        buffer.write(part[0].toUpperCase());
        buffer.write(part.substring(1).toLowerCase());
      }
      field.mutate(buffer.toString());
    }
  }

  static void _toKebabCase(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    buffer.write(parts.first.toLowerCase());
    for (final part in parts.skip(1)) {
      buffer.write('-');
      buffer.write(part.toLowerCase());
    }
    field.mutate(buffer.toString());
  }

  static void _toSnakeCase(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    buffer.write(parts.first.toLowerCase());
    for (final part in parts.skip(1)) {
      buffer.write('_');
      buffer.write(part.toLowerCase());
    }
    field.mutate(buffer.toString());
  }

  static void _toPascalCase(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    for (final part in parts) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1).toLowerCase());
    }
    field.mutate(buffer.toString());
  }

  static void _toTitleCase(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    for (final part in parts) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1).toLowerCase());
      buffer.write(' ');
    }
    field.mutate(buffer.toString().trim());
  }

  static void _toSentenceCase(
      VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    buffer.write(parts.first[0].toUpperCase());
    buffer.write(parts.first.substring(1).toLowerCase());
    for (final part in parts.skip(1)) {
      buffer.write(' ');
      buffer.write(part.toLowerCase());
    }
    field.mutate(buffer.toString());
  }

  static void _toCapitalCase(
      VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    for (final part in parts) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1).toLowerCase());
      buffer.write(' ');
    }
    field.mutate(buffer.toString().trim());
  }

  static void _toConstantCase(
      VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    buffer.write(parts.first.toUpperCase());
    for (final part in parts.skip(1)) {
      buffer.write('_');
      buffer.write(part.toUpperCase());
    }
    field.mutate(buffer.toString());
  }

  static void _toDotCase(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(_wordSeparatorRegex);
    buffer.write(parts.first.toLowerCase());
    for (final part in parts.skip(1)) {
      buffer.write('.');
      buffer.write(part.toLowerCase());
    }
    field.mutate(buffer.toString());
  }

  // ---------------------------------------------------------------------------
  // Array index cache (shared with array_rule.dart pattern)
  // ---------------------------------------------------------------------------
  static const _maxCachedIndex = 256;
  static final _indexStrings =
      List.generate(_maxCachedIndex, (i) => i.toString());
  static String _indexToString(int i) =>
      i < _maxCachedIndex ? _indexStrings[i] : i.toString();
}

class _CompiledGroupRule {
  final bool Function(Map<String, dynamic> data) condition;
  final List<String> keys;
  final List<CompiledValidatorFn> compiledChildren;

  const _CompiledGroupRule(this.condition, this.keys, this.compiledChildren);
}
