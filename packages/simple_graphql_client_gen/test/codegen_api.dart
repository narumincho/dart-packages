import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_graphql_client_gen/query_string.dart';
import 'package:simple_graphql_client_gen/simple_graphql_client_gen.dart';
import './graphql/query.dart' as query;

const note = query.Note('Note', description: query.Note_description());

const IMap<String, GraphQLRootObject> _apiMap = IMapConst({
  'hello': query.Query(
    'QueryHello',
    hello: query.Query_hello(),
  ),
  'account': query.Query(
    'QueryAccount',
    account: query.Query_account(
      id: Variable('id'),
      query.Account(
        'Account',
        id: query.Account_id(),
        name: query.Account_name(),
      ),
    ),
  ),
  'withAlias': query.Query(
    'QueryAccountWithAlias',
    extra__: IMapConst({
      'accountOne': query.Query_account(
        id: Variable('subId'),
        query.Account(
          'AccountOnlyName',
          name: query.Account_name(),
        ),
      ),
    }),
    account: query.Query_account(
      id: Variable('id'),
      query.Account(
        'Account',
        id: query.Account_id(),
        name: query.Account_name(),
      ),
    ),
  ),
  'union': query.Query(
    'QueryUnion',
    union: query.Query_union(
      id: Variable('id'),
      query.AccountOrNote(
        'AccountOrNote',
        account: query.Account(
          'AccountInUnionA',
          id: query.Account_id(),
          name: query.Account_name(),
        ),
        note: query.Note(
          'Note',
          description: query.Note_description(),
          subNotes: query.Note_subNotes(
            query.Note('Note2', description: query.Note_description()),
          ),
        ),
      ),
    ),
  ),
  // なぜか生成がうまくいっている? Mutation にしてみる
  'innerParameter': query.Mutation(
    'MutationInnerParameter',
    union: query.Mutation_union(
      id: Variable('id'),
      query.AccountOrNote(
        'AccountOrNoteInInnerParameter',
        account: query.Account(
          'AccountInUnionA',
          id: query.Account_id(),
          name: query.Account_name(),
        ),
        note: query.Note(
          'NoteInInnerParameter',
          description: query.Note_description(),
          subNotes: query.Note_subNotes(
            query.Note(
              'NoteInInnerParameterInner',
              description: query.Note_description(),
              subNotes: query.Note_subNotes(
                query.Note('Note2', description: query.Note_description()),
              ),
              isLiked: query.Note_isLiked(
                accountId: Variable('accountIdInner'),
              ),
            ),
          ),
          isLiked: query.Note_isLiked(accountId: Variable('accountId')),
        ),
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
