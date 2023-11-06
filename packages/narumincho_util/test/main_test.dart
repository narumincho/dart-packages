import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:test/test.dart';

void main() {
  test('flatMapAndRemoveNull', () {
    expect(
      const IListConst(['a', 'bb', 'c']).flatMapAndRemoveNull((text) {
        if (text.length == 2) {
          return [null];
        }
        return [text, text * 2];
      }),
      const IListConst(['a', 'aa', 'c', 'cc']),
    );
  });

  test('splitOverlappingTuple2', () {
    expect(
      splitOverlappingTuple2(['a', 'b', 'c']),
      const IListConst([('a', 'b'), ('b', 'c')]),
    );
  });

  test('splitOverlappingTuple2 empty', () {
    expect(
      splitOverlappingTuple2([]),
      const IListConst([]),
    );
  });

  test('splitOverlappingTuple2 1', () {
    expect(
      splitOverlappingTuple2(['a']),
      const IListConst([]),
    );
  });

  test('toNotNullable null', () {
    expect([1, null, 32].toNotNullable(), null);
  });

  test('toNotNullable not null', () {
    expect([1, 32, 28].toNotNullable(), [1, 32, 28]);
  });

  test('toFirstUppercase', () {
    expect(toFirstUppercase('name'), 'Name');
  });

  test('toFirstUppercase empty', () {
    expect(toFirstUppercase(''), '');
  });

  test('uriAbsolute top', () {
    expect(uriAbsolute(pathSegments: []).toString(), '/');
  });

  test('uriAbsolute pathSegments', () {
    expect(
      uriAbsolute(pathSegments: ['project', '4e00952222a74177b2586bfb89cb5ca7'])
          .toString(),
      '/project/4e00952222a74177b2586bfb89cb5ca7',
    );
  });

  test('uriAbsolute queryParameters', () {
    expect(
      uriAbsolute(
          pathSegments: ['path'],
          queryParameters: const IMapConst({
            'position': 'left',
            'empty': '',
            '': 'emptyValue',
          })).toString(),
      '/path?position=left&empty&=emptyValue',
    );
  });

  test('setMinLength', () {
    expect(
      IList(const IListConst(['a', 'b', 'c']).setMinLength(6, 'fill')),
      const IListConst(['a', 'b', 'c', 'fill', 'fill', 'fill']),
    );
  });

  test('setMinLength over', () {
    expect(
      IList(const IListConst(['a', 'b', 'c']).setMinLength(2, 'fill')),
      const IListConst(['a', 'b', 'c']),
    );
  });
}
