// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_graphql_client_gen/graphql_type.dart';

@immutable
abstract class QueryField {
  const QueryField();

  T match<T>({
    required T Function(QueryFieldField) field,
    required T Function(QueryFieldOn) on,
  });
}

@immutable
class QueryFieldField implements QueryField {
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

  @override
  T match<T>({
    required T Function(QueryFieldField) field,
    required T Function(QueryFieldOn) on,
  }) {
    return field(this);
  }
}

@immutable
class GraphQLOutputTypeConsiderListNull {
  const GraphQLOutputTypeConsiderListNull(this.type, this.listType, this.isNullable);
  final GraphQLOutputType type;
  final ListType listType;
  final bool isNullable;
}

@immutable
abstract class GraphQLOutputType {
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  });
}

@immutable
class GraphQLOutputTypeNotObject implements GraphQLOutputType {
  const GraphQLOutputTypeNotObject(this.typeName);
  final String typeName;

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return scalar(this);
  }
}

@immutable
class GraphQLOutputTypeString implements GraphQLOutputType {
  const GraphQLOutputTypeString();

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return string(this);
  }
}

@immutable
class GraphQLOutputTypeBoolean implements GraphQLOutputType {
  const GraphQLOutputTypeBoolean();

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return boolean(this);
  }
}

@immutable
class GraphQLOutputTypeDateTime implements GraphQLOutputType {
  const GraphQLOutputTypeDateTime();

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return dateTime(this);
  }
}

@immutable
class GraphQLOutputTypeUrl implements GraphQLOutputType {
  const GraphQLOutputTypeUrl();

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return url(this);
  }
}

@immutable
class GraphQLOutputTypeObject implements GraphQLOutputType {
  const GraphQLOutputTypeObject(this.objectType);
  final GraphQLObjectType objectType;

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return object(this);
  }
}

@immutable
class GraphQLOutputTypeFloat implements GraphQLOutputType {
  const GraphQLOutputTypeFloat();

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return float(this);
  }
}

@immutable
class GraphQLOutputTypeInt implements GraphQLOutputType {
  const GraphQLOutputTypeInt();

  @override
  T match<T>({
    required T Function(GraphQLOutputTypeNotObject) scalar,
    required T Function(GraphQLOutputTypeString) string,
    required T Function(GraphQLOutputTypeBoolean) boolean,
    required T Function(GraphQLOutputTypeDateTime) dateTime,
    required T Function(GraphQLOutputTypeUrl) url,
    required T Function(GraphQLOutputTypeObject) object,
    required T Function(GraphQLOutputTypeFloat) float,
    required T Function(GraphQLOutputTypeInt) int,
  }) {
    return int(this);
  }
}

@immutable
class QueryFieldOn implements QueryField {
  const QueryFieldOn({
    required this.typeName,
    required this.return_,
  });
  final String typeName;
  final GraphQLObjectType return_;

  @override
  T match<T>({
    required T Function(QueryFieldField) field,
    required T Function(QueryFieldOn) on,
  }) {
    return on(this);
  }
}

String queryFieldListToString(
  GraphQLObjectType objectType,
  GraphQLRootObjectType rootObjectType,
) {
  final queryInputVariableList = collectVariableInQueryFieldList(objectType);
  return (rootObjectType == GraphQLRootObjectType.mutation ? 'mutation' : 'query') +
      (queryInputVariableList.isEmpty
          ? ''
          : ' (' +
              queryInputVariableList
                  .map(
                    (variable) => r'$' + variable.name + ': ' + variable.type.toString(),
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
      queryField.match(
        field: (field) =>
            field.fieldName +
            (field.args.isEmpty
                ? ''
                : '(' +
                    field.args
                        .map(
                          (arg) => arg.name + ': ' + arg.input.toQueryString(),
                        )
                        .safeJoin(', ') +
                    ')') +
            field.return_.type.match(
              object: (object) => _queryFieldListToStringLoop(object.objectType, indent),
              scalar: (_) => '',
              string: (_) => '',
              boolean: (_) => '',
              url: (_) => '',
              dateTime: (_) => '',
              float: (_) => '',
              int: (_) => '',
            ),
        on: (pattern) => pattern.return_.toFieldList().isEmpty
            ? '# ... on ' + pattern.typeName + '{}'
            : '... on ' +
                pattern.typeName +
                _queryFieldListToStringLoop(
                  pattern.return_,
                  indent,
                ),
      );
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
  return queryField.match(
    field: (field) {
      return field.args.mapAndRemoveNull((arg) {
        final input = arg.input;
        if (input is QueryInputVariable) {
          return input;
        }
        return null;
      });
    },
    on: (onData) {
      return collectVariableInQueryFieldList(onData.return_);
    },
  );
}

@immutable
class QueryFieldArg {
  const QueryFieldArg({
    required this.name,
    required this.input,
  });
  final String name;
  final QueryInput input;
}

@immutable
abstract class VariableOrStaticValue<T> {
  const VariableOrStaticValue();

  QueryInput toQueryInput({
    required GraphQLType type,
    required QueryInput Function(T) staticValueToQueryInputFunc,
  });
}

@immutable
class Variable<T> extends VariableOrStaticValue<T> {
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
class StaticValue<T> extends VariableOrStaticValue<T> {
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
abstract class QueryInput {
  const QueryInput();

  String toQueryString();
}

@immutable
class QueryInputString extends QueryInput {
  const QueryInputString(this.value);
  final String value;

  @override
  String toQueryString() {
    return '"${value.replaceAll(r"\", r"\\").replaceAll('"', r'\"')}"';
  }
}

@immutable
class QueryInputNumber extends QueryInput {
  const QueryInputNumber(this.value);
  final num value;

  @override
  String toQueryString() {
    return value.toString();
  }
}

@immutable
class QueryInputBoolean extends QueryInput {
  const QueryInputBoolean(this.value);
  final bool value;

  @override
  String toQueryString() {
    return value.toString();
  }
}

@immutable
class QueryInputNull extends QueryInput {
  const QueryInputNull();
  @override
  String toQueryString() {
    return 'null';
  }
}

@immutable
class QueryInputArray extends QueryInput {
  const QueryInputArray(this.items);
  final IList<QueryInput> items;

  @override
  String toQueryString() {
    return '[' + items.map((item) => item.toQueryString()).safeJoin(', ') + ']';
  }
}

@immutable
class QueryInputObject extends QueryInput {
  const QueryInputObject(this.entries);
  final IList<Tuple2<String, QueryInput>> entries;

  @override
  String toQueryString() {
    return '{' + entries.map((item) => item.first + ': ' + item.second.toQueryString()).safeJoin(',') + '}';
  }
}

@immutable
class QueryInputEnum extends QueryInput {
  const QueryInputEnum(this.valueName);
  final String valueName;

  @override
  String toQueryString() {
    return valueName;
  }
}

@immutable
class QueryInputDateTime extends QueryInput {
  const QueryInputDateTime(this.value);
  final DateTime value;

  @override
  String toQueryString() {
    return value.millisecondsSinceEpoch.toString();
  }
}

@immutable
class QueryInputVariable extends QueryInput {
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
