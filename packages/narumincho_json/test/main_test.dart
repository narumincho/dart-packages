import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_json/narumincho_json.dart';
import 'package:test/test.dart';

void main() {
  test('encode string', () {
    expect(const JsonString('それな').encode(), '"それな"');
  });

  test('encode array', () {
    expect(
      const JsonArray(
        IListConst([JsonString('a'), JsonString('b'), JsonString('c')]),
      ).encode(),
      '''["a","b","c"]''',
    );
  });

  test('encode object', () {
    expect(
      const JsonObject(IMapConst({'key': JsonString('サンプル値')})).encode(),
      '''{"key":"サンプル値"}''',
    );
  });

  test('JsonValue DecodeJson', () {
    expect(
      JsonValue.fromDynamic({
        'キー': '値',
        'a': ['item0', 'item1']
      }),
      const JsonObject(
        IMapConst({
          'キー': JsonString('値'),
          'a': JsonArray(IListConst([
            JsonString('item0'),
            JsonString('item1'),
          ]))
        }),
      ),
    );
  });

  test('JsonValue Equality', () {
    expect(const JsonString('a'), const JsonString('a'));
    // ignore: prefer_const_constructors
    expect(JsonString('a'), JsonString('a'));

    // ignore: prefer_const_constructors
    expect(JsonString('a') == JsonString('b'), false);
  });

  test('JsonValue Equality Array', () {
    expect(
        const JsonArray(IListConst([JsonString('a')])) ==
            const JsonArray(IListConst([JsonString('a')])),
        true);

    expect(
        const JsonArray(IListConst([JsonString('a')])) ==
            const JsonArray(IListConst([JsonString('a')])),
        true);
  });

  test('JsonValue Equality Object', () {
    expect(
        const JsonObject(IMapConst({'k': JsonString('a')})) ==
            const JsonObject(IMapConst({'k': JsonString('a')})),
        true);
  });

  test('null', () {
    expect(
        const JsonObject(
          IMapConst(
            {'query': JsonString('sampleQuery'), 'variables': JsonNull()},
          ),
        ).toDartObjectOrNull(),
        {'query': 'sampleQuery', 'variables': null});
  });

  test('decode', () {
    expect(
      JsonValue.decode('''
{
    "data": {
        "allGoalMethod": [
            {
                "id": "6cf06df7770e7074f22b1e7c05547185",
                "name": "aaa",
                "goal": null
            },
            {
                "id": "8e78d57e123322968c60d06725a26d0c",
                "name": "cc",
                "goal": {
                    "id": "6cf06df7770e7074f22b1e7c05547185"
                }
            },
            {
                "id": "a108e3ff1e1172df130e43b90ed5c467",
                "name": "ddd",
                "goal": {
                    "id": "8e78d57e123322968c60d06725a26d0c"
                }
            },
            {
                "id": "b1ab65789cdae23752da2a493e233caf",
                "name": "bbbb",
                "goal": {
                    "id": "6cf06df7770e7074f22b1e7c05547185"
                }
            }
        ]
    }
}
'''),
      JsonValue.fromDynamic({
        'data': {
          'allGoalMethod': [
            {
              'id': '6cf06df7770e7074f22b1e7c05547185',
              'name': 'aaa',
              'goal': null
            },
            {
              'id': '8e78d57e123322968c60d06725a26d0c',
              'name': 'cc',
              'goal': {'id': '6cf06df7770e7074f22b1e7c05547185'}
            },
            {
              'id': 'a108e3ff1e1172df130e43b90ed5c467',
              'name': 'ddd',
              'goal': {'id': '8e78d57e123322968c60d06725a26d0c'}
            },
            {
              'id': 'b1ab65789cdae23752da2a493e233caf',
              'name': 'bbbb',
              'goal': {'id': '6cf06df7770e7074f22b1e7c05547185'}
            }
          ]
        }
      }),
    );
  });

  test('decode format error', () {
    expect(
      () {
        final _ = JsonValue.decode('json として不正な文字列');
      },
      throwsFormatException,
    );
  });
}
