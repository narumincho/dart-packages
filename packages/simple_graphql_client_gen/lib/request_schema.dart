import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_json/narumincho_json.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_graphql_client_gen/graphql_post.dart';
import 'package:simple_graphql_client_gen/graphql_type.dart';

Future<IList<GraphQLTypeDeclaration>> requestSchema(Uri uri) async {
  final response = await graphQLPost(query: '''
query IntrospectionQuery {
  __schema {
    
    queryType { name }
    mutationType { name }
    subscriptionType { name }
    types {
      ...FullType
    }
    directives {
      name
      description
      
      locations
      args {
        ...InputValue
      }
    }
  }
}

fragment FullType on __Type {
  kind
  name
  description
  fields(includeDeprecated: true) {
    name
    description
    args {
      ...InputValue
    }
    type {
      ...TypeRef
    }
    isDeprecated
    deprecationReason
  }
  inputFields {
    ...InputValue
  }
  interfaces {
    ...TypeRef
  }
  enumValues(includeDeprecated: true) {
    name
    description
    isDeprecated
    deprecationReason
  }
  possibleTypes {
    ...TypeRef
  }
}

fragment InputValue on __InputValue {
  name
  description
  type { ...TypeRef }
  defaultValue
}

fragment TypeRef on __Type {
  kind
  name
  ofType {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
              }
            }
          }
        }
      }
    }
  }
}
''', uri: uri);
  final data = response.data;
  if (data == null) {
    throw Exception('data is null');
  }
  final schema = data.getValueByKeyOrThrow('__schema');
  final queryTypeName = schema
      .getObjectValueOrThrow('queryType')
      .getObjectValueOrThrow('name')
      .asStringOrThrow();
  final mutationTypeName = schema
      .getObjectValueOrThrow('mutationType')
      .getObjectValueOrThrow('name')
      .asStringOrThrow();
  final typeList = schema.getObjectValueOrThrow('types');
  return IList(
    typeList.getAsArrayWithDecoder(
      (v) => _graphQLTypeToDartClassDeclaration(
        value: v,
        queryTypeName: queryTypeName,
        mutationTypeName: mutationTypeName,
      ),
    ),
  );
}

GraphQLTypeDeclaration _graphQLTypeToDartClassDeclaration({
  required JsonValue value,
  required String queryTypeName,
  required String mutationTypeName,
}) {
  final name = value.getObjectValueOrThrow('name').asStringOrThrow();
  return GraphQLTypeDeclaration(
    name: name,
    documentationComments:
        value.getObjectValueOrThrow('description').asStringOrNull() ?? '',
    body: parseGraphQLTypeBody(value),
    type: name == queryTypeName
        ? GraphQLRootObjectType.query
        : name == mutationTypeName
            ? GraphQLRootObjectType.mutation
            : null,
  );
}

GraphQLTypeBody parseGraphQLTypeBody(JsonValue value) {
  switch (value.getObjectValueOrThrow('kind').asStringOrThrow()) {
    case 'SCALAR':
      return const GraphQLTypeBodyScaler();
    case 'UNION':
      return GraphQLTypeBodyUnion(
        IList(
          value.getObjectValueOrThrow('possibleTypes').asArrayOrThrow(
                (t) => t.getObjectValueOrThrow('name').asStringOrThrow(),
              ),
        ),
      );
    case 'ENUM':
      return GraphQLTypeBodyEnum(IList(
        value.getObjectValueOrThrow('enumValues').asArrayOrThrow(
              (e) => EnumValue(
                name: e.getObjectValueOrThrow('name').asStringOrThrow(),
                documentationComments:
                    e.getObjectValueOrThrow('description').asStringOrThrow(),
              ),
            ),
      ));
    case 'INPUT_OBJECT':
      return GraphQLTypeBodyInputObject(
        value.getObjectValueOrThrow('inputFields').asArrayOrThrow(
              (field) => GraphQLInputValue.fromJsonValue(field),
            ),
      );
    default:
      final fields = value.getObjectValueOrNull('fields');
      return GraphQLTypeBodyObject(
        fields == null
            ? const IListConst([])
            : fields.asArrayOrThrow(
                (field) => GraphQLField.fromJsonValue(field),
              ),
      );
  }
}
