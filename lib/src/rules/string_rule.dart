import 'package:string_validator/string_validator.dart';
import 'package:vine/src/contracts/rule.dart';
import 'package:vine/src/contracts/schema.dart';
import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/helper.dart';

final europeanPhoneRegex =
    RegExp(r'^\+?[0-9]{1,4}[-.\s]?[0-9]{1,4}[-.\s]?[0-9]{4,10}$');

final class VineStringRule implements VineRule {
  final String? message;

  const VineStringRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value is! String) {
      if (field.isUnion) {
        throw Exception('Union type is not supported for string type');
      }

      final error = ctx.errorReporter.format('string', field, message, {});
      ctx.errorReporter
          .report('string', [...field.customKeys, field.name], error);
    }
  }
}

final class VineMinLengthRule implements VineRule {
  final int minValue;
  final String? message;

  const VineMinLengthRule(this.minValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when value.length < minValue) {
      final error = ctx.errorReporter.format('minLength', field, message, {
        'min': minValue,
      });

      ctx.errorReporter
          .report('minLength', [...field.customKeys, field.name], error);
    }
  }
}

final class VineMaxLengthRule implements VineRule {
  final int maxValue;
  final String? message;

  const VineMaxLengthRule(this.maxValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when value.length > maxValue) {
      final error = ctx.errorReporter.format('maxLength', field, message, {
        'max': maxValue,
      });

      ctx.errorReporter
          .report('maxLength', [...field.customKeys, field.name], error);
    }
  }
}

final class VineFixedLengthRule implements VineRule {
  final int count;
  final String? message;

  const VineFixedLengthRule(this.count, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when value.length != count) {
      final error = ctx.errorReporter.format('fixedLength', field, message, {
        'length': count,
      });

      ctx.errorReporter
          .report('fixedLength', [...field.customKeys, field.name], error);
    }
  }
}

final class VineEmailRule implements VineRule {
  final String? message;

  const VineEmailRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !isEmailSimd(value)) {
      final error = ctx.errorReporter.format('email', field, message, {});
      ctx.errorReporter
          .report('email', [...field.customKeys, field.name], error);
    }
  }
}

final class VinePhoneRule implements VineRule {
  final RegExp? regex;
  final String? message;

  const VinePhoneRule(this.regex, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentRegexp = regex ?? europeanPhoneRegex;
    if (field.value case String value when !currentRegexp.hasMatch(value)) {
      final error = ctx.errorReporter.format('phone', field, message, {});
      ctx.errorReporter
          .report('phone', [...field.customKeys, field.name], error);
    }
  }
}

final class VineIpAddressRule implements VineRule {
  final IpAddressVersion? version;
  final String? message;

  const VineIpAddressRule(this.version, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.isIP(version?.value)) {
      final error = ctx.errorReporter.format('ipAddress', field, message,
          {'version': version ?? IpAddressVersion.values.toList()});
      ctx.errorReporter
          .report('ipAddress', [...field.customKeys, field.name], error);
    }
  }
}

final class VineRegexRule implements VineRule {
  final RegExp regex;
  final String? message;

  const VineRegexRule(this.regex, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !regex.hasMatch(value)) {
      final error = ctx.errorReporter.format('regex', field, message, {
        'pattern': regex.pattern,
      });

      ctx.errorReporter
          .report('regex', [...field.customKeys, field.name], error);
    }
  }
}

final class VineHexColorRule implements VineRule {
  final String? message;

  const VineHexColorRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.isHexColor) {
      final error = ctx.errorReporter.format('hexColor', field, message, {});
      ctx.errorReporter
          .report('hexColor', [...field.customKeys, field.name], error);
    }
  }
}

final class VineUrlRule implements VineRule {
  final List<String> protocols;
  final bool requireTld;
  final bool requireProtocol;
  final bool allowUnderscores;
  final String? message;

  const VineUrlRule(this.protocols, this.requireTld, this.requireProtocol,
      this.allowUnderscores, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value
        when !value.isURL({
          'protocols': protocols,
          'requireTld': requireTld,
          'requireProtocol': requireProtocol,
          'allowUnderscores': allowUnderscores,
        })) {
      final error = ctx.errorReporter.format('url', field, message, {});
      ctx.errorReporter.report('url', [...field.customKeys, field.name], error);
    }
  }
}

final class VineAlphaRule implements VineRule {
  final String? message;

  const VineAlphaRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.isAlpha) {
      final error = ctx.errorReporter.format('alpha', field, message, {});
      ctx.errorReporter
          .report('alpha', [...field.customKeys, field.name], error);
    }
  }
}

final class VineAlphaNumericRule implements VineRule {
  final String? message;

  const VineAlphaNumericRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.isAlphanumeric) {
      final error =
          ctx.errorReporter.format('alphaNumeric', field, message, {});
      ctx.errorReporter
          .report('alphaNumeric', [...field.customKeys, field.name], error);
    }
  }
}

final class VineStartWithRule implements VineRule {
  final String attemptedValue;
  final String? message;

  const VineStartWithRule(this.attemptedValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.startsWith(attemptedValue)) {
      final error = ctx.errorReporter
          .format('startWith', field, message, {'value': attemptedValue});
      ctx.errorReporter
          .report('startWith', [...field.customKeys, field.name], error);
    }
  }
}

final class VineEndWithRule implements VineRule {
  final String attemptedValue;
  final String? message;

  const VineEndWithRule(this.attemptedValue, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.endsWith(attemptedValue)) {
      final error = ctx.errorReporter
          .format('endWith', field, message, {'value': attemptedValue});
      ctx.errorReporter
          .report('endWith', [...field.customKeys, field.name], error);
    }
  }
}

final class VineConfirmedRule implements VineRule {
  final String? targetField;
  final bool include;
  final String? message;

  const VineConfirmedRule(this.targetField, this.include, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final confirmedKey = targetField ?? '${field.name}_confirmation';
    final hasKey = ctx.data.containsKey(confirmedKey);

    if (!hasKey) {
      final error = ctx.errorReporter
          .format('missingProperty', field, message, {'field': confirmedKey});
      ctx.errorReporter
          .report('missingProperty', [...field.customKeys, field.name], error);
    }

    final currentValue = ctx.data[confirmedKey];
    if ((field.value as String) != currentValue) {
      final error = ctx.errorReporter
          .format('confirmed', field, message, {'attemptedName': confirmedKey});
      ctx.errorReporter
          .report('confirmed', [...field.customKeys, field.name], error);
    }

    if (!include) {
      ctx.data.remove(confirmedKey);
    }
  }
}

final class VineTrimRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).trim());
  }
}

final class VineNormalizeEmailRule implements VineRule {
  final bool lowerCase;

  const VineNormalizeEmailRule(this.lowerCase);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).normalizeEmail({
      'lowercase': lowerCase,
    }));
  }
}

final class VineUpperCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).toUpperCase());
  }
}

final class VineLowerCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    field.mutate((field.value as String).toLowerCase());
  }
}

final class VineToCamelCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value) {
      final buffer = StringBuffer();
      final parts = value.split(RegExp(r'[_\s-]'));

      buffer.write(parts.first.toLowerCase());

      for (final part in parts.skip(1)) {
        buffer.write(part[0].toUpperCase());
        buffer.write(part.substring(1).toLowerCase());
      }

      field.mutate(buffer.toString());
    }
  }
}

final class VineToKebabCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    buffer.write(parts.first.toLowerCase());

    for (final part in parts.skip(1)) {
      buffer.write('-');
      buffer.write(part.toLowerCase());
    }

    field.mutate(buffer.toString());
  }
}

final class VineToSnakeCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    buffer.write(parts.first.toLowerCase());

    for (final part in parts.skip(1)) {
      buffer.write('_');
      buffer.write(part.toLowerCase());
    }

    field.mutate(buffer.toString());
  }
}

final class VineToPascalCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    for (final part in parts) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1).toLowerCase());
    }

    field.mutate(buffer.toString());
  }
}

final class VineToTitleCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    for (final part in parts) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1).toLowerCase());
      buffer.write(' ');
    }

    field.mutate(buffer.toString().trim());
  }
}

final class VineToSentenceCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    buffer.write(parts.first[0].toUpperCase());
    buffer.write(parts.first.substring(1).toLowerCase());

    for (final part in parts.skip(1)) {
      buffer.write(' ');
      buffer.write(part.toLowerCase());
    }

    field.mutate(buffer.toString());
  }
}

final class VineToCapitalCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    for (final part in parts) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1).toLowerCase());
      buffer.write(' ');
    }

    field.mutate(buffer.toString().trim());
  }
}

final class VineToConstantCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    buffer.write(parts.first.toUpperCase());

    for (final part in parts.skip(1)) {
      buffer.write('_');
      buffer.write(part.toUpperCase());
    }

    field.mutate(buffer.toString());
  }
}

final class VineToDotCaseRule implements VineRule {
  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final buffer = StringBuffer();
    final parts = (field.value as String).split(RegExp(r'\[_\s-'));

    buffer.write(parts.first.toLowerCase());

    for (final part in parts.skip(1)) {
      buffer.write('.');
      buffer.write(part.toLowerCase());
    }

    field.mutate(buffer.toString());
  }
}

final class VineUuidRule implements VineRule {
  final UuidVersion? version;
  final String? message;

  const VineUuidRule(this.version, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.isUUID()) {
      final error = ctx.errorReporter.format('uuid', field, message, {
        'version': version ?? UuidVersion.values.toList(),
      });

      ctx.errorReporter
          .report('uuid', [...field.customKeys, field.name], error);
    }
  }
}

final class VineCreditCardRule implements VineRule {
  final String? message;

  const VineCreditCardRule(this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (field.value case String value when !value.isCreditCard) {
      final error = ctx.errorReporter.format('creditCard', field, message, {});
      ctx.errorReporter
          .report('creditCard', [...field.customKeys, field.name], error);
    }
  }
}

final class VineSameAsRule implements VineRule {
  final String value;
  final String? message;

  const VineSameAsRule(this.value, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);

    if (currentContext[value] != field.value) {
      final error =
          ctx.errorReporter.format('sameAs', field, message, {'field': value});
      ctx.errorReporter
          .report('sameAs', [...field.customKeys, field.name], error);
    }
  }
}

final class VineNotSameAsRule implements VineRule {
  final String value;
  final String? message;

  const VineNotSameAsRule(this.value, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    final currentContext = ctx.getFieldContext(field.customKeys);

    if (currentContext[value] == field.value) {
      final error = ctx.errorReporter
          .format('notSameAs', field, message, {'field': value});
      ctx.errorReporter
          .report('notSameAs', [...field.customKeys, field.name], error);
    }
  }
}

final class VineInListRule implements VineRule {
  final List<String> values;
  final String? message;

  const VineInListRule(this.values, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (!values.contains(field.value)) {
      final error = ctx.errorReporter
          .format('inList', field, message, {'values': values});
      ctx.errorReporter
          .report('inList', [...field.customKeys, field.name], error);
    }
  }
}

final class VineNotInListRule implements VineRule {
  final List<String> values;
  final String? message;

  const VineNotInListRule(this.values, this.message);

  @override
  void handle(VineValidationContext ctx, VineFieldContext field) {
    if (values.contains(field.value)) {
      final error = ctx.errorReporter
          .format('notInList', field, message, {'values': values});
      ctx.errorReporter
          .report('notInList', [...field.customKeys, field.name], error);
    }
  }
}
