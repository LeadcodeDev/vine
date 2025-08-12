import 'package:vine/src/contracts/vine.dart';

abstract interface class VineRule {
  void handle(VineValidationContext ctx, VineFieldContext field);
}
