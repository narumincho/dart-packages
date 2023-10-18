import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_graphql_client_gen/graphql_post.dart';
import 'package:simple_graphql_client_gen/text.dart';
import 'package:test/test.dart';

void main() {
  test('normal', () {
    expect(
      textFromString('条件を満たしている文字列', maxLength: 50),
      '条件を満たしている文字列',
    );
  });

  test('empty', () {
    expect(
      textFromString('', maxLength: 50),
      null,
    );
  });

  test('over', () {
    expect(
      textFromString('こえてしまう', maxLength: 5),
      null,
    );
  });

  test('trim', () {
    expect(
      textFromString(' 余計な空白は取り除こう\n   ', maxLength: 50),
      '余計な空白は取り除こう',
    );
  });

  test('remove multiple space', () {
    expect(
      textFromString(' 連続した\u3000    空白は \n 1つに   まとめられる  ', maxLength: 50),
      '連続した 空白は 1つに まとめられる',
    );
  });

  test('GraphQLError toString', () {
    expect(
      const GraphqlError(
        message: 'error message',
        path: IListConst(['path', 'to', 'error']),
        extensionsCode: 'sampleCode',
      ).toString(),
      '''
[sampleCode] error message ([
   path,
   to,
   error
])''',
    );
  });

  test;
  test('GraphQLErrors toString', () {
    expect(
      GraphqlErrors(IList([
        const GraphqlError(
          message: 'messageA',
          path: IListConst(['path', 'to', 'error']),
          extensionsCode: 'sampleCodeA',
        ),
        const GraphqlError(
          message: 'messageB',
          path: IListConst(['path', 'to', 'error']),
          extensionsCode: 'sampleCodeB',
        ),
      ])).toString(),
      '''
[sampleCodeA] messageA ([
   path,
   to,
   error
])
[sampleCodeB] messageB ([
   path,
   to,
   error
])''',
    );
  });
}
