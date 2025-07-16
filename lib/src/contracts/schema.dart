import 'package:vine/src/contracts/vine.dart';
import 'package:vine/src/introspection.dart';
import 'package:vine/src/schema/object/object_schema.dart';

abstract interface class VineSchema<T extends ErrorReporter>
    implements SchemaIntrospection {
  /// Validate the field [field] the field to validate
  void parse(VineValidationContext ctx, FieldContext field);

  /// Clone the schema
  VineSchema clone();
}

/// The IP address version
/// - [v4] IPv4
/// - [v6] IPv6
/// ```dart
/// vine.string().ipAddress(version: IpAddressVersion.v4);
/// ```
enum IpAddressVersion {
  v4(4),
  v6(6);

  final int value;

  const IpAddressVersion(this.value);
}

/// The UUID version
/// - [v3] Version 3
/// - [v4] Version 4
/// - [v5] Version 5
/// ```dart
/// vine.string().uuid(version: UuidVersion.v4);
/// ```
enum UuidVersion {
  v3(3),
  v4(4),
  v5(5);

  final int value;

  const UuidVersion(this.value);
}

/// Enum contract to use your enum in the [VineEnum] schema
abstract interface class VineEnumerable<T> {
  T get value;
}

abstract interface class BasicSchema<T extends VineSchema> {
  T requiredIfExist(List<String> values);

  T requiredIfAnyExist(List<String> values);

  T requiredIfMissing(List<String> values);

  T requiredIfAnyMissing(List<String> values);

  T transform(Function(VineValidationContext ctx, FieldContext field) fn);

  T nullable();

  T optional();
}

abstract interface class VineString
    implements VineSchema, BasicSchema<VineString> {
  /// Check if the string has a minimum length [value] the minimum length [message] the error message to display
  /// ```dart
  /// vine.string().minLength(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().minLength(5, message: 'The value must be at least 5 characters long');
  /// ```
  VineString minLength(int value, {String? message});

  /// Check if the string has a maximum length [value] the maximum length [message] the error message to display
  /// ```dart
  /// vine.string().maxLength(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().maxLength(5, message: 'The value must be at most 5 characters long');
  /// ```
  VineString maxLength(int value, {String? message});

  /// Check if the string has a fixed length [value] the fixed length [message] the error message to display
  /// ```dart
  /// vine.string().fixedLength(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().fixedLength(5, message: 'The value must be exactly 5 characters long');
  /// ```
  VineString fixedLength(int value, {String? message});

  /// Check if the string is an email [message] the error message to display
  /// ```dart
  /// vine.string().email();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().email(message: 'The value must be a valid email address');
  /// ```
  VineString email({String? message});

  /// Check if the string is a phone number [message] the error message to display
  /// ```dart
  /// vine.string().phone();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().phone(message: 'The value must be a valid phone number');
  /// ```
  VineString phone({RegExp? match, String? message});

  /// Check if the string is an IP address [version] the IP address version [message] the error message to display
  /// ```dart
  /// vine.string().ipAddress();
  /// ```
  /// By default it will check for both IPv4 and IPv6 addresses
  /// You can specify the IP address version
  /// ```dart
  /// vine.string().ipAddress(version: IpAddressVersion.v4);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().ipAddress(message: 'The value must be a valid IP address');
  /// ```
  VineString ipAddress({IpAddressVersion? version, String? message});

  /// Check if the string is a URL [message] the error message to display
  /// ```dart
  /// vine.string().url();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().url(message: 'The value must be a valid URL');
  /// ```
  VineString url({String? message});

  /// Check if the string contains only alphabetic characters [message] the error message to display
  /// ```dart
  /// vine.string().alpha();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().alpha(
  ///   message: 'The value must contain only alphabetic characters');
  /// ```
  VineString alpha({String? message});

  /// Check if the string contains only alphabetic and numeric characters [message] the error message to display
  /// ```dart
  /// vine.string().alphaNumeric();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().alphaNumeric(
  ///   message: 'The value must contain only alphabetic and numeric characters');
  /// ```
  VineString alphaNumeric({String? message});

  /// Check if the string matches a regular expression [regex] the regular expression [message] the error message to display
  /// ```dart
  /// vine.string().startsWith('Hello');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().startsWith('Hello',
  ///   message: 'The value must start with Hello');
  /// ```
  VineString startsWith(String value, {String? message});

  /// Check if the string ends with a specific value [value] the value to check [message] the error message to display
  /// ```dart
  /// vine.string().endsWith('World');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().endsWith('World',
  ///   message: 'The value must end with World');
  /// ```
  VineString endsWith(String value, {String? message});

  /// Check if the string as another field named field_confirmation, [message] the error message to display
  /// ```dart
  /// vine.string().confirmed();
  /// ```
  /// The default related field is the field name suffixed with _confirmation
  /// You can specify a custom related field
  /// ```dart
  /// vine.string().confirmed(property: 'password');
  /// ```
  /// By default, the confirmation field will be removed from the data object
  ///
  /// If you want to keep the confirmation field in the data object, you can set [include] to true
  /// ```dart
  /// vine.string().confirmed(include: true);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().confirmed(
  ///   message: 'The value must be confirmed');
  /// ```
  VineString confirmed(
      {String? property, bool include = false, String? message});

  /// Remove leading and trailing whitespace from the string
  /// ```dart
  /// vine.string().trim();
  /// ```
  VineString trim();

  /// Normalize the email address by removing leading and trailing whitespace and converting the domain part to lowercase
  /// ```dart
  /// vine.string().normalizeEmail();
  /// ```
  /// By default, the domain part will be converted to lowercase
  /// You can disable this by setting [lowercase] to false
  /// ```dart
  /// vine.string().normalizeEmail(lowercase: false);
  /// ```
  VineString normalizeEmail({bool lowercase = true});

  /// Convert the string to uppercase
  /// ```dart
  /// vine.string().toUpperCase();
  /// ```
  VineString toUpperCase();

  /// Convert the string to lowercase
  /// ```dart
  /// vine.string().toLowerCase();
  /// ```
  VineString toLowerCase();

  /// Convert the string to camel case
  /// ```dart
  /// vine.string().toCamelCase();
  /// ```
  VineString toCamelCase();

  /// Check if the string is a UUID [version] the UUID version [message] the error message to display
  /// ```dart
  /// vine.string().uuid();
  /// ```
  /// By default, it will check for any UUID version
  /// You can specify the UUID version
  /// ```dart
  /// vine.string().uuid(version: UuidVersion.v4);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().uuid(
  ///   message: 'The value must be a valid UUID');
  /// ```
  VineString uuid({UuidVersion? version, String? message});

  /// Check if the string is a credit card number [message] the error message to display
  /// ```dart
  /// vine.string().isCreditCard();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().isCreditCard(
  ///   message: 'The value must be a valid credit card number');
  /// ```
  VineString isCreditCard({String? message});

  /// Check if the string is the same as another field [value] the field name [message] the error message to display
  /// ```dart
  /// vine.string().sameAs('password');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().sameAs('password',
  ///   message: 'The value must be the same as the password');
  /// ```
  VineString sameAs(String value, {String? message});

  /// Check if the string is not the same as another field [value] the field name [message] the error message to display
  /// ```dart
  /// vine.string().notSameAs('password');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().notSameAs('password',
  ///   message: 'The value must not be the same as the password');
  /// ```
  VineString notSameAs(String value, {String? message});

  /// Check if the string is in a list of values [values] the list of values [message] the error message to display
  /// ```dart
  /// vine.string().inList(['admin', 'user']);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().inList(['admin', 'user'],
  ///   message: 'The value must be one of admin or user');
  /// ```
  VineString inList(List<String> values, {String? message});

  /// Check if the string is not in a list of values [values] the list of values [message] the error message to display
  /// ```dart
  /// vine.string().notInList(['admin', 'user']);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().notInList(['admin', 'user'],
  ///   message: 'The value must not be one of admin or user');
  /// ```
  VineString notInList(List<String> values, {String? message});

  /// Check if the string is a valid regular [RegExp] [expression] the regular expression [message] the error message to display
  /// ```dart
  /// vine.string().regexp(RegExp(r'^[a-zA-Z]+$'));
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.string().regexp(RegExp(r'^[a-zA-Z]+$'),
  ///   message: 'The value must contain only alphabetic characters');
  /// ```
  VineString regex(RegExp expression, {String? message});

  /// Set the example value for the string [value] the example value
  /// ```dart
  /// vine.string().example('foo');
  /// ```
  VineString example(String value);
}

abstract interface class VineNumber
    implements VineSchema, BasicSchema<VineNumber> {
  /// Check if the number is in a range of values [values] the range of values [message] the error message to display
  /// ```dart
  /// vine.number().range([1, 10]);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().range([1, 10],
  ///   message: 'The value must be between 1 and 10');
  /// ```
  VineNumber range(List<num> values, {String? message});

  /// Check if the number is at least [value] the minimum value [message] the error message to display
  /// ```dart
  /// vine.number().min(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().min(5, message: 'The value must be at least 5');
  /// ```
  VineNumber min(num value, {String? message});

  /// Check if the number is at most [value] the maximum value [message] the error message to display
  /// ```dart
  /// vine.number().max(10);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().max(10, message: 'The value must be at most 10');
  /// ```
  VineNumber max(num value, {String? message});

  /// Check if the number is negative [message] the error message to display
  /// ```dart
  /// vine.number().negative();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().negative(message: 'The value must be a negative number');
  /// ```
  VineNumber negative({String? message});

  /// Check if the number is positive [message] the error message to display
  /// ```dart
  /// vine.number().positive();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().positive(message: 'The value must be a positive number');
  /// ```
  VineNumber positive({String? message});

  /// Check if the number is a double [message] the error message to display
  /// ```dart
  /// vine.number().double();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().double(message: 'The value must be a double');
  /// ```
  VineNumber double({String? message});

  /// Check if the number is an integer [message] the error message to display
  /// ```dart
  /// vine.number().integer();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  VineNumber integer({String? message});

  /// Set the example value for the number [value] the example value
  /// ```dart
  /// vine.number().example(10);
  /// ```
  VineNumber example(num value);
}

abstract interface class VineBoolean
    implements VineSchema, BasicSchema<VineBoolean> {
  /// Set the example value for the boolean [value] the example value
  /// ```dart
  /// vine.boolean().example(true);
  /// ```
  VineBoolean example(bool value);
}

abstract interface class VineAny implements VineSchema, BasicSchema<VineAny> {
  /// Set the example value for the any [value] the example value
  /// ```dart
  /// vine.any().example('foo');
  /// ```
  VineAny example(dynamic value);
}

abstract interface class VineEnum<T extends VineEnumerable>
    implements VineSchema, BasicSchema<VineEnum<T>> {
  /// Set the example value for the enum [value] the example value
  /// ```dart
  /// vine.enum().example('foo');
  /// ```
  VineEnum<T> example(T value);
}

abstract interface class VineObject
    implements VineSchema, BasicSchema<VineObject> {
  Map<String, VineSchema> get properties;

  VineObject merge(VineObjectSchema schema);
}

abstract interface class VineGroup implements VineSchema {
  /// Check if the object matches the condition [fn] the condition to check [object] the object schema to apply
  /// ```dart
  /// vine.group((group) {
  ///   group.when((data) => data['type'] == 'admin', {
  ///     'name': vine.string().required(),
  ///     'email': vine.string().required().email(),
  ///   });
  /// });
  VineGroup when(bool Function(Map<String, dynamic> data) fn,
      Map<String, VineSchema> object);

  /// Apply the schema if the condition is not met [fn] the schema to apply
  /// ```dart
  /// vine
  ///   .group((group) {
  ///     group.when((data) => data['type'] == 'admin', {
  ///       'name': vine.string().required(),
  ///       'email': vine.string().required().email(),
  ///     })
  ///   })
  ///   .otherwise((ctx, field) {
  ///      field.customKeys.add(field.name);
  ///   });
  VineGroup otherwise(Function(VineValidationContext, FieldContext) fn);
}

abstract interface class VineArray
    implements VineSchema, BasicSchema<VineArray> {
  /// Check if the array has a minimum length [value] the minimum length [message] the error message to display
  /// ```dart
  /// vine.array().minLength(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.array().minLength(5, message: 'The value must have at least 5 items');
  /// ```
  VineArray minLength(int value, {String? message});

  /// Check if the array has a maximum length [value] the maximum length [message] the error message to display
  /// ```dart
  /// vine.array().maxLength(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.array().maxLength(5, message: 'The value must have at most 5 items');
  /// ```
  VineArray maxLength(int value, {String? message});

  /// Check if the array has a fixed length [value] the fixed length [message] the error message to display
  /// ```dart
  /// vine.array().fixedLength(5);
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.array().fixedLength(5, message: 'The value must have exactly 5 items');
  /// ```
  VineArray fixedLength(int value, {String? message});

  /// Check if values in the array are unique [message] the error message to display
  /// ```dart
  /// vine.array().unique();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.array().unique(message: 'The values must be unique');
  /// ```
  VineArray unique({String? message});
}

abstract interface class VineUnion
    implements VineSchema, BasicSchema<VineUnion> {
  VineUnion example(dynamic value);
}

abstract interface class VineDate implements VineSchema, BasicSchema<VineDate> {
  /// Check if the date is before [value] the date to compare [message] the error message to display
  /// ```dart
  /// vine.date().before(DateTime.now());
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.date().before(DateTime.now(), message: 'The date must be before today');
  /// ```
  VineDate before(DateTime value, {String? message});

  /// Check if the date is after [value] the date to compare [message] the error message to display
  /// ```dart
  /// vine.date().after(DateTime.now());
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.date().after(DateTime.now(), message: 'The date must be after today');
  /// ```
  VineDate after(DateTime value, {String? message});

  /// Check if the date is between [min] the minimum date [max] the maximum date [message] the error message to display
  /// ```dart
  /// vine.date().between(DateTime(2021, 1, 1), DateTime(2021, 12, 31));
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.date().between(DateTime(2021, 1, 1), DateTime(2021, 12, 31),
  ///   message: 'The date must be between 2021-01-01 and 2021-12-31');
  /// ```
  ///  You can specify a custom error message
  VineDate between(DateTime min, DateTime max, {String? message});

  /// Check if the date is before another field [value] the field name [message] the error message to display
  /// ```dart
  /// vine.date().beforeField('end');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.date().beforeField('end', message: 'The date must be before the end date');
  /// ```
  VineDate beforeField(String value, {String? message});

  /// Check if the date is after another field [value] the field name [message] the error message to display
  /// ```dart
  /// vine.date().afterField('start');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.date().afterField('start', message: 'The date must be after the start date');
  /// ```
  VineDate afterField(String value, {String? message});

  /// Check if the date is between two fields [start] the start field [end] the end field [message] the error message to display
  /// ```dart
  /// vine.date().betweenFields('start', 'end');
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.date().betweenFields('start', 'end',
  ///   message: 'The date must be between the start and end date');
  /// ```
  VineDate betweenFields(String start, String end, {String? message});

  /// Set the example value for the date [value] the example value
  /// ```dart
  /// vine.date().example(DateTime.now());
  /// ```
  VineDate example(String value);
}
