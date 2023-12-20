import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;

@immutable
final class GraphQLTypeDeclaration {
  const GraphQLTypeDeclaration({
    required this.name,
    required this.documentationComments,
    required this.body,
    required this.type,
  });
  final String name;
  final String documentationComments;
  final GraphQLTypeBody body;
  final GraphQLRootObjectType? type;
}

enum GraphQLRootObjectType { mutation, query }

@immutable
sealed class GraphQLTypeBody {
  const GraphQLTypeBody();
}

@immutable
final class GraphQLTypeBodyObject extends GraphQLTypeBody {
  const GraphQLTypeBodyObject(this.fields);
  final IList<GraphQLField> fields;
}

@immutable
final class GraphQLTypeBodyInputObject extends GraphQLTypeBody {
  const GraphQLTypeBodyInputObject(this.fields);
  final IList<GraphQLInputValue> fields;
}

@immutable
final class GraphQLField {
  const GraphQLField({
    required this.name,
    required this.description,
    required this.args,
    required this.type,
  });
  final String name;
  final String description;
  final IList<GraphQLInputValue> args;
  final GraphQLType type;

  static GraphQLField fromJsonValue(JsonValue value) {
    return GraphQLField(
      name: value.getObjectValueOrThrow('name').asStringOrThrow(),
      type:
          _graphQLTypeRefJsonToGraphQLType(value.getObjectValueOrThrow('type')),
      args: value
          .getObjectValueOrThrow('args')
          .asArrayOrThrow(GraphQLInputValue.fromJsonValue),
      description:
          value.getObjectValueOrThrow('description').asStringOrNull() ?? '',
    );
  }
}

@immutable
final class GraphQLInputValue {
  const GraphQLInputValue({
    required this.name,
    required this.description,
    required this.type,
  });
  final String name;
  final String description;
  final GraphQLType type;

  static GraphQLInputValue fromJsonValue(JsonValue value) {
    return GraphQLInputValue(
      name: value.getObjectValueOrThrow('name').asStringOrThrow(),
      description:
          value.getObjectValueOrThrow('description').asStringOrNull() ?? '',
      type:
          _graphQLTypeRefJsonToGraphQLType(value.getObjectValueOrThrow('type')),
    );
  }
}

@immutable
final class GraphQLType {
  const GraphQLType({
    required this.name,
    required this.isNullable,
    required this.listType,
  });
  final String name;
  final bool isNullable;
  final ListType listType;

  @override
  String toString() {
    switch (listType) {
      case ListType.notList:
        return name + (isNullable ? '' : '!');

      case ListType.list:
        return "[$name!]${isNullable ? "" : "!"}";

      case ListType.listItemNullable:
        return "[$name]${isNullable ? "" : "!"}";
    }
  }

  Type toDartType(bool useNamespaceType) {
    if (listType == ListType.notList) {
      return _dartTypeNormal(name, useNamespaceType).setIsNullable(isNullable);
    }
    return TypeNormal(
      name: 'IList',
      isNullable: isNullable,
      arguments: IList([
        _dartTypeNormal(name, useNamespaceType).setIsNullable(
          listType == ListType.listItemNullable,
        ),
      ]),
    );
  }

  Expr toExpr() {
    return ExprConstructor(
      className: 'graphql_type.GraphQLType',
      isConst: true,
      namedArguments: IList([
        (
          name: 'name',
          argument: ExprStringLiteral(IList([StringLiteralItemNormal(name)])),
        ),
        (
          name: 'isNullable',
          argument: ExprBool(isNullable),
        ),
        (
          name: 'listType',
          argument: ExprEnumValue(
              typeName: 'graphql_type.ListType', valueName: listType.name),
        ),
      ]),
    );
  }
}

Type _dartTypeNormal(String name, bool useNamespaceType) {
  if (name == 'Boolean') {
    return wellknown_type.bool;
  }
  if (name == 'String') {
    return wellknown_type.String;
  }
  if (name == 'Float') {
    return wellknown_type.double;
  }
  if (name == 'Int') {
    return wellknown_type.int;
  }
  if (name == 'DateTime') {
    return wellknown_type.DateTime;
  }
  if (useNamespaceType) {
    return TypeNormal(name: 'type.${escapeFirstUnderLine(name)}');
  }
  return TypeNormal(name: escapeFirstUnderLine(name));
}

String escapeFirstUnderLine(String name) {
  if (name.startsWith('_')) {
    return 'GraphQL$name';
  }
  return name;
}

enum ListType { notList, list, listItemNullable }

@immutable
final class GraphQLTypeBodyUnion extends GraphQLTypeBody {
  const GraphQLTypeBodyUnion(this.possibleTypes);
  final IList<String> possibleTypes;
}

@immutable
final class GraphQLTypeBodyEnum extends GraphQLTypeBody {
  const GraphQLTypeBodyEnum(this.enumValueList);
  final IList<EnumValue> enumValueList;
}

@immutable
final class GraphQLTypeBodyScaler extends GraphQLTypeBody {
  const GraphQLTypeBodyScaler();
}

GraphQLType _graphQLTypeRefJsonToGraphQLType(JsonValue value) {
  final kind = value.getObjectValueOrThrow('kind').asStringOrThrow();
  if (kind == 'NON_NULL') {
    final child =
        _graphQLTypeRefJsonToGraphQLType(value.getObjectValueOrThrow('ofType'));

    return GraphQLType(
        name: child.name, isNullable: false, listType: child.listType);
  }
  if (kind == 'LIST') {
    final child =
        _graphQLTypeRefJsonToGraphQLType(value.getObjectValueOrThrow('ofType'));

    return GraphQLType(
      name: child.name,
      isNullable: true,
      listType: child.isNullable ? ListType.listItemNullable : ListType.list,
    );
  }
  return GraphQLType(
    name: value.getObjectValueOrThrow('name').asStringOrNull() ?? 'unknown',
    isNullable: true,
    listType: ListType.notList,
  );
}
