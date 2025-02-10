import './rules/string_test.dart' as string_test;
import './rules/number_test.dart' as number_test;
import './rules/boolean_test.dart' as boolean_test;
import './rules/any_test.dart' as any_test;
import './rules/enum_test.dart' as enum_test;

void main() {
  string_test.main();
  number_test.main();
  boolean_test.main();
  any_test.main();
  enum_test.main();
}
