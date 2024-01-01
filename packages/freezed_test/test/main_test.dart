import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_test/main.dart';
import 'package:freezed_test/original.dart';
import 'package:test/test.dart';

void main() {
  test('freezed equal', () {
    expect(
      Person(age: 10, firstName: 'a', lastName: 'b'),
      Person(age: 12, firstName: 'a', lastName: 'b'),
    );
  });

  test(
    'immutable equal',
    () {
      expect(IList([1, 2]), IList([1, 5]));
    },
  );

  test('orignal equal', () {
    expect(Original('a'), Original('b'));
  });
}
