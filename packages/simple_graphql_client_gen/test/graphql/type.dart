// Generated by simple_dart_code_gen. Do not edit.
// ignore_for_file: camel_case_types, constant_identifier_names, always_use_package_imports
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart' as narumincho_json;
import 'package:simple_graphql_client_gen/query_string.dart' as query_string;
import 'package:simple_graphql_client_gen/text.dart' as text;

/// The `ID` scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `"4"`) or integer (such as `4`) input value will be accepted as an ID.
@immutable
final class ID implements query_string.IntoQueryInput {
  /// The `ID` scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `"4"`) or integer (such as `4`) input value will be accepted as an ID.
  const ID(
    this.value,
  );

  /// 文字列. Int の場合もあるが, とりあえず考えない
  final String value;

  /// `ID` を複製する
  @useResult
  ID copyWith({
    String? value,
  }) {
    return ID((value ?? this.value));
  }

  /// `ID` のフィールドを変更したものを新しく返す
  @useResult
  ID updateFields({
    String Function(String prevValue)? value,
  }) {
    return ID(((value == null) ? this.value : value(this.value)));
  }

  @override
  @useResult
  int get hashCode {
    return value.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is ID) && (value == other.value));
  }

  @override
  @useResult
  String toString() {
    return 'ID(${value}, )';
  }

  @override
  @useResult
  query_string.QueryInput toQueryInput() {
    return query_string.QueryInputString(value);
  }

  @override
  @useResult
  narumincho_json.JsonValue toJsonValue() {
    return narumincho_json.JsonString(value);
  }

  static ID fromJsonValue(
    narumincho_json.JsonValue jsonValue,
  ) {
    return ID(jsonValue.asStringOrThrow());
  }
}

/// An enum describing what kind of type a given `__Type` is.
enum GraphQL__TypeKind implements query_string.IntoQueryInput {
  /// Indicates this type is a scalar.
  SCALAR,

  /// Indicates this type is an object. `fields` and `interfaces` are valid fields.
  OBJECT,

  /// Indicates this type is an interface. `fields`, `interfaces`, and `possibleTypes` are valid fields.
  INTERFACE,

  /// Indicates this type is a union. `possibleTypes` is a valid field.
  UNION,

  /// Indicates this type is an enum. `enumValues` is a valid field.
  ENUM,

  /// Indicates this type is an input object. `inputFields` is a valid field.
  INPUT_OBJECT,

  /// Indicates this type is a list. `ofType` is a valid field.
  LIST,

  /// Indicates this type is a non-null. `ofType` is a valid field.
  NON_NULL,
  ;

  @override
  @useResult
  query_string.QueryInput toQueryInput() {
    return query_string.QueryInputEnum(name);
  }

  @override
  @useResult
  narumincho_json.JsonValue toJsonValue() {
    return narumincho_json.JsonString(name);
  }

  static GraphQL__TypeKind fromJsonValue(
    narumincho_json.JsonValue jsonValue,
  ) {
    return (switch (jsonValue.asStringOrNull()) {
      'SCALAR' => GraphQL__TypeKind.SCALAR,
      'OBJECT' => GraphQL__TypeKind.OBJECT,
      'INTERFACE' => GraphQL__TypeKind.INTERFACE,
      'UNION' => GraphQL__TypeKind.UNION,
      'ENUM' => GraphQL__TypeKind.ENUM,
      'INPUT_OBJECT' => GraphQL__TypeKind.INPUT_OBJECT,
      'LIST' => GraphQL__TypeKind.LIST,
      'NON_NULL' => GraphQL__TypeKind.NON_NULL,
      _ => (throw Exception(
          'unknown Enum Value. typeName __TypeKind. expected "SCALAR" or "OBJECT" or "INTERFACE" or "UNION" or "ENUM" or "INPUT_OBJECT" or "LIST" or "NON_NULL". but got ${jsonValue.encode()}')),
    });
  }
}

/// A Directive can be adjacent to many parts of the GraphQL language, a __DirectiveLocation describes one such possible adjacencies.
enum GraphQL__DirectiveLocation implements query_string.IntoQueryInput {
  /// Location adjacent to a query operation.
  QUERY,

  /// Location adjacent to a mutation operation.
  MUTATION,

  /// Location adjacent to a subscription operation.
  SUBSCRIPTION,

  /// Location adjacent to a field.
  FIELD,

  /// Location adjacent to a fragment definition.
  FRAGMENT_DEFINITION,

  /// Location adjacent to a fragment spread.
  FRAGMENT_SPREAD,

  /// Location adjacent to an inline fragment.
  INLINE_FRAGMENT,

  /// Location adjacent to a variable definition.
  VARIABLE_DEFINITION,

  /// Location adjacent to a schema definition.
  SCHEMA,

  /// Location adjacent to a scalar definition.
  SCALAR,

  /// Location adjacent to an object type definition.
  OBJECT,

  /// Location adjacent to a field definition.
  FIELD_DEFINITION,

  /// Location adjacent to an argument definition.
  ARGUMENT_DEFINITION,

  /// Location adjacent to an interface definition.
  INTERFACE,

  /// Location adjacent to a union definition.
  UNION,

  /// Location adjacent to an enum definition.
  ENUM,

  /// Location adjacent to an enum value definition.
  ENUM_VALUE,

  /// Location adjacent to an input object type definition.
  INPUT_OBJECT,

  /// Location adjacent to an input object field definition.
  INPUT_FIELD_DEFINITION,
  ;

  @override
  @useResult
  query_string.QueryInput toQueryInput() {
    return query_string.QueryInputEnum(name);
  }

  @override
  @useResult
  narumincho_json.JsonValue toJsonValue() {
    return narumincho_json.JsonString(name);
  }

  static GraphQL__DirectiveLocation fromJsonValue(
    narumincho_json.JsonValue jsonValue,
  ) {
    return (switch (jsonValue.asStringOrNull()) {
      'QUERY' => GraphQL__DirectiveLocation.QUERY,
      'MUTATION' => GraphQL__DirectiveLocation.MUTATION,
      'SUBSCRIPTION' => GraphQL__DirectiveLocation.SUBSCRIPTION,
      'FIELD' => GraphQL__DirectiveLocation.FIELD,
      'FRAGMENT_DEFINITION' => GraphQL__DirectiveLocation.FRAGMENT_DEFINITION,
      'FRAGMENT_SPREAD' => GraphQL__DirectiveLocation.FRAGMENT_SPREAD,
      'INLINE_FRAGMENT' => GraphQL__DirectiveLocation.INLINE_FRAGMENT,
      'VARIABLE_DEFINITION' => GraphQL__DirectiveLocation.VARIABLE_DEFINITION,
      'SCHEMA' => GraphQL__DirectiveLocation.SCHEMA,
      'SCALAR' => GraphQL__DirectiveLocation.SCALAR,
      'OBJECT' => GraphQL__DirectiveLocation.OBJECT,
      'FIELD_DEFINITION' => GraphQL__DirectiveLocation.FIELD_DEFINITION,
      'ARGUMENT_DEFINITION' => GraphQL__DirectiveLocation.ARGUMENT_DEFINITION,
      'INTERFACE' => GraphQL__DirectiveLocation.INTERFACE,
      'UNION' => GraphQL__DirectiveLocation.UNION,
      'ENUM' => GraphQL__DirectiveLocation.ENUM,
      'ENUM_VALUE' => GraphQL__DirectiveLocation.ENUM_VALUE,
      'INPUT_OBJECT' => GraphQL__DirectiveLocation.INPUT_OBJECT,
      'INPUT_FIELD_DEFINITION' =>
        GraphQL__DirectiveLocation.INPUT_FIELD_DEFINITION,
      _ => (throw Exception(
          'unknown Enum Value. typeName __DirectiveLocation. expected "QUERY" or "MUTATION" or "SUBSCRIPTION" or "FIELD" or "FRAGMENT_DEFINITION" or "FRAGMENT_SPREAD" or "INLINE_FRAGMENT" or "VARIABLE_DEFINITION" or "SCHEMA" or "SCALAR" or "OBJECT" or "FIELD_DEFINITION" or "ARGUMENT_DEFINITION" or "INTERFACE" or "UNION" or "ENUM" or "ENUM_VALUE" or "INPUT_OBJECT" or "INPUT_FIELD_DEFINITION". but got ${jsonValue.encode()}')),
    });
  }
}
