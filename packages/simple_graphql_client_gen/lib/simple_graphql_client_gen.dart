import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_graphql_client_gen/api_gen.dart' as api_gen;
import 'package:simple_graphql_client_gen/query_gen.dart';
import 'package:simple_graphql_client_gen/query_string.dart';
import 'package:simple_graphql_client_gen/request_schema.dart';
import 'package:simple_graphql_client_gen/type_gen.dart';

@immutable
class TypeAndQueryCode {
  const TypeAndQueryCode({required this.type, required this.query});
  final SimpleDartCode type;
  final SimpleDartCode query;
}

Future<TypeAndQueryCode> generateQueryCodeFromHttp({required Uri uri}) async {
  final graphQLTypeList = await requestSchema(uri);
  return TypeAndQueryCode(
    type: generateTypeCode(graphQLTypeList),
    query: generateQueryCode(graphQLTypeList),
  );
}

SimpleDartCode generateApiCode(
  IMap<String, GraphQLRootObject> apiMap,
) {
  return api_gen.generateApiCode(apiMap);
}
