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
      const IListConst([Tuple2('a', 'b'), Tuple2('b', 'c')]),
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
}
