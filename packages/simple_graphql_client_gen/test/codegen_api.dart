import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_graphql_client_gen/query_string.dart';
import 'package:simple_graphql_client_gen/simple_graphql_client_gen.dart';
import './graphql/query.dart' as query;

const IMap<String, GraphQLRootObject> _apiMap = IMapConst({
  'hello': query.Query(
    name: 'QueryHello',
    IListConst([query.Query_hello()]),
  ),
  'account': query.Query(
    name: 'QueryAccount',
    IListConst([
      query.Query_account(
        id: Variable('id'),
        query.Account(
          IListConst([
            query.Account_id(),
            query.Account_name(),
          ]),
        ),
      ),
    ]),
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
