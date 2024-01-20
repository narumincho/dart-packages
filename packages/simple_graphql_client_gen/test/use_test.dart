import 'package:test/test.dart';

import 'graphql/api.dart';

void main() {
  test('hello', () async {
    expect(
      (await Api.hello(
              Uri(scheme: 'http', host: 'localhost', port: 8000), null))
          .hello,
      'Hello GraphQL',
    );
  });
}
