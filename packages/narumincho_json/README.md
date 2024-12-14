# narumincho_json

[![pub package](https://img.shields.io/pub/v/narumincho_json.svg)](https://pub.dev/packages/narumincho_json)

`dart:convert` の json が型がゆるいため, 作ったもの

```dart
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_json/narumincho_json.dart';
import 'package:test/test.dart';

void main() {
  test('encode array', () {
    expect(
      const JsonArray(
        IListConst([JsonString('a'), JsonString('b'), JsonString('c')]),
      ).encode(),
      '''["a","b","c"]''',
    );
  });
}
```
