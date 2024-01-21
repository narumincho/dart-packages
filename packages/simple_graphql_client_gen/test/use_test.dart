import 'package:test/test.dart';

import 'graphql/api.dart';
import 'graphql/type.dart';

final uri = Uri(scheme: 'http', host: 'localhost', port: 8000);

void main() {
  test('hello', () async {
    expect(
      (await Api.hello(uri, null)).hello,
      'Hello GraphQL',
    );
  });

  test('account', () async {
    expect(
      (await Api.account(id: const ID('sampleId'), uri, null)).account,
      const Account(id: ID('sampleId'), name: 'sample account name'),
    );
  });

  test('alias', () async {
    final response = await Api.withAlias(
      id: const ID('a'),
      subId: const ID('b'),
      uri,
      null,
    );

    expect(
      response.account,
      const Account(id: ID('a'), name: 'sample account name'),
    );

    expect(
      response.accountOne,
      const AccountOnlyName(name: 'sample account name'),
    );
  });
}
