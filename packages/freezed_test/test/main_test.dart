import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_test/main.dart';
import 'package:freezed_test/original.dart';
import 'package:test/test.dart';

void main() {
  test('freezed equal', () {
    expect(
      Person(
        age: 10,
        firstName: 'a',
        lastName: 'b',
        tags: IList(['a', 'b']),
        mTags: ['a', 'b'],
        set: ISet(['a', 'b']),
      ),
      Person(
        age: 10,
        firstName: 'a',
        lastName: 'b',
        tags: IList(['a', 'b']),
        mTags: ['a', 'b'],
        set: ISet(['b', 'a']),
      ),
    );
  });

  test(
    'immutable equal',
    () {
      expect(
        IList([
          IList([1, 2])
        ]),
        IList([
          IList([1, 5])
        ]),
      );
    },
  );

  test(
    'immutable equal set',
    () {
      expect(
        ISet(['b', 'a']),
        ISet(['a', 'b']),
      );
    },
  );

  test('orignal equal', () {
    expect(Original(name: 'a', age: 32, tags: IList(['a'])),
        equals(Original(name: 'b', age: 33, tags: IList(['b']))));
  });

  test('SampleIter', () {
    expect(SampleIter([1, 2, 3]), equals(SampleIter([1, 2, 2])));
  });
}
