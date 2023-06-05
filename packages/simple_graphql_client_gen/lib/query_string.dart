// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_graphql_client_gen/graphql_type.dart';

@immutable
sealed class QueryField {
  const QueryField();
}

@immutable
final class QueryFieldField implements QueryField {
  const QueryFieldField(
    this.fieldName, {
    this.args = const IListConst([]),
    required this.description,
    required this.return_,
  });
  final String fieldName;
  final String description;
  final IList<QueryFieldArg> args;
  final GraphQLOutputTypeConsiderListNull return_;
}

@immutable
final class GraphQLOutputTypeConsiderListNull {
  const GraphQLOutputTypeConsiderListNull(
      this.type, this.listType, this.isNullable);
  final GraphQLOutputType type;
  final ListType listType;
  final bool isNullable;
}

@immutable
sealed class GraphQLOutputType {}

@immutable
final class GraphQLOutputTypeNotObject implements GraphQLOutputType {
  const GraphQLOutputTypeNotObject(this.typeName);
  final String typeName;
}

@immutable
final class GraphQLOutputTypeString implements GraphQLOutputType {
  const GraphQLOutputTypeString();
}

@immutable
final class GraphQLOutputTypeBoolean implements GraphQLOutputType {
  const GraphQLOutputTypeBoolean();
}

@immutable
final class GraphQLOutputTypeDateTime implements GraphQLOutputType {
  const GraphQLOutputTypeDateTime();
}

@immutable
final class GraphQLOutputTypeUrl implements GraphQLOutputType {
  const GraphQLOutputTypeUrl();
}

@immutable
final class GraphQLOutputTypeObject implements GraphQLOutputType {
  const GraphQLOutputTypeObject(this.objectType);
  final GraphQLObjectType objectType;
}

@immutable
final class GraphQLOutputTypeFloat implements GraphQLOutputType {
  const GraphQLOutputTypeFloat();
}

@immutable
final class GraphQLOutputTypeInt implements GraphQLOutputType {
  const GraphQLOutputTypeInt();
}

@immutable
final class QueryFieldOn implements QueryField {
  const QueryFieldOn({
    required this.typeName,
    required this.return_,
  });
  final String typeName;
  final GraphQLObjectType return_;
}

String queryFieldListToString(
  GraphQLObjectType objectType,
  GraphQLRootObjectType rootObjectType,
) {
  final queryInputVariableList = collectVariableInQueryFieldList(objectType);
  return (rootObjectType == GraphQLRootObjectType.mutation
          ? 'mutation'
          : 'query') +
      (queryInputVariableList.isEmpty
          ? ''
          : ' (' +
              queryInputVariableList
                  .map(
                    (variable) =>
                        r'$' + variable.name + ': ' + variable.type.toString(),
                  )
                  .safeJoin(', ') +
              ')') +
      _queryFieldListToStringLoop(objectType, 0) +
      '\n';
}

String _queryFieldListToStringLoop(
  GraphQLObjectType objectType,
  int indent,
) {
  return ' {\n' +
      objectType
          .toFieldList()
          .map(
            (queryField) => _queryFieldToString(
              queryField,
              indent + 1,
            ),
          )
          .safeJoin('\n') +
      '\n' +
      ('  ' * indent) +
      '}';
}

String _queryFieldToString(
  QueryField queryField,
  int indent,
) {
  return ('  ' * indent) +
      (switch (queryField) {
        QueryFieldField(:final fieldName, :final return_, :final args) =>
          fieldName +
              (args.isEmpty
                  ? ''
                  : '(' +
                      args
                          .map(
                            (arg) =>
                                arg.name + ': ' + arg.input.toQueryString(),
                          )
                          .safeJoin(', ') +
                      ')') +
              switch (return_.type) {
                GraphQLOutputTypeObject(:final objectType) =>
                  _queryFieldListToStringLoop(objectType, indent),
                _ => '',
              },
        // Dart 3.0.2 bug https://github.com/dart-lang/sdk/issues/52151
        // ignore: unreachable_switch_case
        QueryFieldOn(:final typeName, :final return_) =>
          return_.toFieldList().isEmpty
              ? '# ... on ' + typeName + '{}'
              : '... on ' +
                  typeName +
                  _queryFieldListToStringLoop(
                    return_,
                    indent,
                  ),
      });
}

IList<QueryInputVariable> collectVariableInQueryFieldList(
  GraphQLObjectType? objectType,
) {
  if (objectType == null) {
    return const IListConst([]);
  }
  return IList(
    objectType.toFieldList().expand(
          (field) => _collectVariableInQueryField(field),
        ),
  );
}

IList<QueryInputVariable> _collectVariableInQueryField(
  QueryField queryField,
) {
  return switch (queryField) {
    // dart bug
    // ignore: unused_result
    QueryFieldField(:final args) => args.mapAndRemoveNull((arg) {
        final input = arg.input;
        if (input is QueryInputVariable) {
          return input;
        }
        return null;
      }),
    // Dart 3.0.2 bug https://github.com/dart-lang/sdk/issues/52151
    // ignore: unreachable_switch_case
    QueryFieldOn(:final return_) => collectVariableInQueryFieldList(return_),
  };
}

@immutable
final class QueryFieldArg {
  const QueryFieldArg({
    required this.name,
    required this.input,
  });
  final String name;
  final QueryInput input;
}

@immutable
sealed class VariableOrStaticValue<T> {
  const VariableOrStaticValue();

  QueryInput toQueryInput({
    required GraphQLType type,
    required QueryInput Function(T) staticValueToQueryInputFunc,
  });
}

@immutable
final class Variable<T> extends VariableOrStaticValue<T> {
  const Variable(this.name);
  final String name;

  @override
  QueryInput toQueryInput({
    required GraphQLType type,
    required QueryInput Function(T) staticValueToQueryInputFunc,
  }) {
    return QueryInputVariable(name, type);
  }
}

@immutable
final class StaticValue<T> extends VariableOrStaticValue<T> {
  const StaticValue(this.value);
  final T value;

  @override
  QueryInput toQueryInput({
    required GraphQLType type,
    required QueryInput Function(T) staticValueToQueryInputFunc,
  }) {
    return staticValueToQueryInputFunc(value);
  }
}

@immutable
sealed class QueryInput {
  const QueryInput();

  String toQueryString();
}

@immutable
final class QueryInputString extends QueryInput {
  const QueryInputString(this.value);
  final String value;

  @override
  String toQueryString() {
    return '"${value.replaceAll(r"\", r"\\").replaceAll('"', r'\"')}"';
  }
}

@immutable
final class QueryInputNumber extends QueryInput {
  const QueryInputNumber(this.value);
  final num value;

  @override
  String toQueryString() {
    return value.toString();
  }
}

@immutable
final class QueryInputBoolean extends QueryInput {
  const QueryInputBoolean(this.value);
  final bool value;

  @override
  String toQueryString() {
    return value.toString();
  }
}

@immutable
final class QueryInputNull extends QueryInput {
  const QueryInputNull();
  @override
  String toQueryString() {
    return 'null';
  }
}

@immutable
final class QueryInputArray extends QueryInput {
  const QueryInputArray(this.items);
  final IList<QueryInput> items;

  @override
  String toQueryString() {
    return '[' + items.map((item) => item.toQueryString()).safeJoin(', ') + ']';
  }
}

@immutable
final class QueryInputObject extends QueryInput {
  const QueryInputObject(this.entries);
  final IList<Tuple2<String, QueryInput>> entries;

  @override
  String toQueryString() {
    return '{' +
        entries
            .map((item) => item.first + ': ' + item.second.toQueryString())
            .safeJoin(',') +
        '}';
  }
}

@immutable
final class QueryInputEnum extends QueryInput {
  const QueryInputEnum(this.valueName);
  final String valueName;

  @override
  String toQueryString() {
    return valueName;
  }
}

@immutable
final class QueryInputDateTime extends QueryInput {
  const QueryInputDateTime(this.value);
  final DateTime value;

  @override
  String toQueryString() {
    return value.millisecondsSinceEpoch.toString();
  }
}

@immutable
final class QueryInputVariable extends QueryInput {
  const QueryInputVariable(this.name, this.type);
  final String name;
  final GraphQLType type;

  @override
  String toQueryString() {
    return r'$' + name;
  }
}

@immutable
abstract class GraphQLRootObject implements GraphQLObjectType {
  const GraphQLRootObject();
  GraphQLRootObjectType getRootObjectType();
}

@immutable
abstract class GraphQLObjectType {
  const GraphQLObjectType();

  IList<QueryField> toFieldList();
  String getTypeName();
  String getDescription();
}

@immutable
abstract class IntoGraphQLField {
  const IntoGraphQLField();

  QueryField toField();
}

@immutable
abstract class IntoQueryInput {
  const IntoQueryInput();

  QueryInput toQueryInput();

  JsonValue toJsonValue();
}
