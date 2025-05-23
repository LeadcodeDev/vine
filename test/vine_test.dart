import './rules/any_test.dart' as any_test;
import './rules/array_test.dart' as array_test;
import './rules/boolean_test.dart' as boolean_test;
import './rules/enum_test.dart' as enum_test;
import './rules/number_test.dart' as number_test;
import './rules/string_test.dart' as string_test;
import './rules/object_test.dart' as object_test;
import './rules/union_test.dart' as union_test;
import './rules/date_test.dart' as date_test;
import './open_api_test.dart' as openapi_test;

void main() async {
  string_test.main();
  number_test.main();
  boolean_test.main();
  any_test.main();
  enum_test.main();
  array_test.main();
  object_test.main();
  union_test.main();
  date_test.main();
  openapi_test.main();
}
