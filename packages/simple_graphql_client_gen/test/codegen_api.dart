import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_graphql_client_gen/query_string.dart';
import 'package:simple_graphql_client_gen/simple_graphql_client_gen.dart';
import './graphql/query.dart' as query;

const IMap<String, GraphQLRootObject> _apiMap = IMapConst({
  'hello': query.Query(
    'QueryHello',
    IMapConst({}),
    hello: query.Query_hello(),
  ),
  'account': query.Query(
    'QueryAccount',
    IMapConst({}),
    account: query.Query_account(
      id: Variable('id'),
      query.Account(
        'Account',
        IMapConst({}),
        id: query.Account_id(),
        name: query.Account_name(),
      ),
    ),
  ),
  'withAlias': query.Query(
    'QueryAccountWithAlias',
    IMapConst({
      'accountOne': query.Query_account(
        id: Variable('subId'),
        query.Account(
          'AccountOnlyName',
          IMapConst({}),
          name: query.Account_name(),
        ),
      ),
    }),
    account: query.Query_account(
      id: Variable('id'),
      query.Account(
        'Account',
        IMapConst({}),
        id: query.Account_id(),
        name: query.Account_name(),
      ),
    ),
  ),
});

/// GraphQL からコード生成します
void main() async {
  print('コード生成を開始します');
  final codeData = generateApiCode(_apiMap);

  await _writeCodeInFileWithLog('api.dart', codeData);
  print('コード生成に成功しました');
}

Future<void> _writeCodeInFileWithLog(
  String fileName,
  SimpleDartCode code,
) async {
  final file =
      await File('./test/graphql/$fileName').writeAsString(code.toCodeString());
  print('${file.absolute.uri} に書き込みました.');
}
