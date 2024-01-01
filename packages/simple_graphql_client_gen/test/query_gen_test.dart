import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_graphql_client_gen/graphql_type.dart';
import 'package:test/test.dart';
import 'package:simple_graphql_client_gen/query_gen.dart';

void main() {
  test('empty', () {
    final code = generateQueryCode(IList([]));
    expect(
      code.declarationList,
      IList([]),
    );
  });

  test('hello Query', () {
    final code = generateQueryCode(const IListConst([
      GraphQLTypeDeclaration(
        name: 'Query',
        type: GraphQLRootObjectType.query,
        documentationComments: 'コメント',
        body: GraphQLTypeBodyObject(IListConst([
          GraphQLField(
            name: 'hello',
            description: '固定の挨拶を返す',
            args: IListConst([]),
            type: GraphQLType(
              name: 'String',
              isNullable: false,
              listType: ListType.notList,
            ),
          ),
        ])),
      )
    ]));
    expect(
      code.declarationList,
      IList([
        const ClassDeclaration(
          name: 'Query',
          documentationComments: 'コメント',
          fields: IListConst([]),
          modifier: ClassModifier.final_,
        ),
        const ClassDeclaration(
          name: 'Query',
          documentationComments: 'コメント',
          fields: IListConst([]),
          modifier: ClassModifier.final_,
        ),
        const ClassDeclaration(
          name: 'Query',
          documentationComments: 'コメント',
          fields: IListConst([]),
          modifier: ClassModifier.final_,
        )
      ]),
    );
  });
}
