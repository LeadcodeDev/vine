import 'dart:convert';

class VineValidationException implements Exception {
  String code = 'E_VALIDATION_ERROR';
  final statusCode = 422;

  final Map<String, dynamic> message;
  VineValidationException(this.message);

  @override
  String toString() => '[$code]: ${json.encode(message)}';
}
