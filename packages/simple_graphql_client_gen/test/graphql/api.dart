// Generated by simple_dart_code_gen. Do not edit.
// ignore_for_file: camel_case_types, constant_identifier_names, always_use_package_imports
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart' as narumincho_json;
import 'package:simple_graphql_client_gen/graphql_post.dart' as graphql_post;

import './type.dart' as type;

/// APIを呼ぶ
@immutable
abstract class Api {
  /// APIを呼ぶ
  const Api();

  /// ```
  /// query {
  ///   hello
  /// }
  /// ```
  static Future<QueryHello> hello(
    Uri url,
    String? auth,
  ) async {
    final response = await graphql_post.graphQLPost(
      uri: url,
      auth: auth,
      query: 'query {\n  hello\n}\n',
    );
    final errors = response.errors;
    if ((errors != null)) {
      throw errors;
    }
    final data = response.data;
    if ((data == null)) {
      throw Exception('hello response data empty');
    }
    return QueryHello.fromJsonValue(data);
  }

  /// ```
  /// query ($id: ID!) {
  ///   account(id: $id) {
  ///     id
  ///     name
  ///   }
  /// }
  /// ```
  static Future<QueryAccount> account(
    Uri url,
    String? auth, {
    required type.ID id,
  }) async {
    final response = await graphql_post.graphQLPost(
      uri: url,
      auth: auth,
      query:
          'query (\$id: ID!) {\n  account(id: \$id) {\n    id\n    name\n  }\n}\n',
      variables: IMap({'id': id.toJsonValue()}),
    );
    final errors = response.errors;
    if ((errors != null)) {
      throw errors;
    }
    final data = response.data;
    if ((data == null)) {
      throw Exception('account response data empty');
    }
    return QueryAccount.fromJsonValue(data);
  }

  /// ```
  /// query ($id: ID!, $subId: ID!) {
  ///   account(id: $id) {
  ///     id
  ///     name
  ///   }
  ///   account(id: $subId) {
  ///     name
  ///   }
  /// }
  /// ```
  static Future<QueryAccountWithAlias> withAlias(
    Uri url,
    String? auth, {
    required type.ID id,
    required type.ID subId,
  }) async {
    final response = await graphql_post.graphQLPost(
      uri: url,
      auth: auth,
      query:
          'query (\$id: ID!, \$subId: ID!) {\n  account(id: \$id) {\n    id\n    name\n  }\n  account(id: \$subId) {\n    name\n  }\n}\n',
      variables: IMap({
        'id': id.toJsonValue(),
        'subId': subId.toJsonValue(),
      }),
    );
    final errors = response.errors;
    if ((errors != null)) {
      throw errors;
    }
    final data = response.data;
    if ((data == null)) {
      throw Exception('withAlias response data empty');
    }
    return QueryAccountWithAlias.fromJsonValue(data);
  }
}

/// データを取得できる. データを取得するのみで, データを変更しない
@immutable
final class QueryHello {
  /// データを取得できる. データを取得するのみで, データを変更しない
  const QueryHello({
    required this.hello,
  });

  /// 挨拶をする
  final String hello;

  /// `QueryHello` を複製する
  @useResult
  QueryHello copyWith({
    String? hello,
  }) {
    return QueryHello(hello: (hello ?? this.hello));
  }

  /// `QueryHello` のフィールドを変更したものを新しく返す
  @useResult
  QueryHello updateFields({
    String Function(String prevHello)? hello,
  }) {
    return QueryHello(
        hello: ((hello == null) ? this.hello : hello(this.hello)));
  }

  @override
  @useResult
  int get hashCode {
    return hello.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is QueryHello) && (hello == other.hello));
  }

  @override
  @useResult
  String toString() {
    return 'QueryHello(hello: ${hello}, )';
  }

  /// JsonValue から QueryHelloを生成する. 失敗した場合はエラーが発生する
  static QueryHello fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return QueryHello(
        hello: value.getObjectValueOrThrow('hello').asStringOrThrow());
  }
}

/// よくあるアカウントの型
@immutable
final class Account {
  /// よくあるアカウントの型
  const Account({
    required this.id,
    required this.name,
  });

  /// 識別するためのID
  final type.ID id;

  /// 名前
  final String? name;

  /// `Account` を複製する
  @useResult
  Account copyWith({
    type.ID? id,
    (String?,)? name,
  }) {
    return Account(
      id: (id ?? this.id),
      name: ((name == null) ? this.name : name.$1),
    );
  }

  /// `Account` のフィールドを変更したものを新しく返す
  @useResult
  Account updateFields({
    type.ID Function(type.ID prevId)? id,
    String? Function(String? prevName)? name,
  }) {
    return Account(
      id: ((id == null) ? this.id : id(this.id)),
      name: ((name == null) ? this.name : name(this.name)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      id,
      name,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return (((other is Account) && (id == other.id)) && (name == other.name));
  }

  @override
  @useResult
  String toString() {
    return 'Account(id: ${id}, name: ${name}, )';
  }

  /// JsonValue から Accountを生成する. 失敗した場合はエラーが発生する
  static Account fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return Account(
      id: type.ID.fromJsonValue(value.getObjectValueOrThrow('id')),
      name: (switch (value.getObjectValueOrThrow('name')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => jsonValue.asStringOrThrow(),
      }),
    );
  }
}

/// データを取得できる. データを取得するのみで, データを変更しない
@immutable
final class QueryAccount {
  /// データを取得できる. データを取得するのみで, データを変更しない
  const QueryAccount({
    required this.account,
  });

  /// IDからアカウントを取得
  final Account? account;

  /// `QueryAccount` を複製する
  @useResult
  QueryAccount copyWith({
    (Account?,)? account,
  }) {
    return QueryAccount(
        account: ((account == null) ? this.account : account.$1));
  }

  /// `QueryAccount` のフィールドを変更したものを新しく返す
  @useResult
  QueryAccount updateFields({
    Account? Function(Account? prevAccount)? account,
  }) {
    return QueryAccount(
        account: ((account == null) ? this.account : account(this.account)));
  }

  @override
  @useResult
  int get hashCode {
    return account.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is QueryAccount) && (account == other.account));
  }

  @override
  @useResult
  String toString() {
    return 'QueryAccount(account: ${account}, )';
  }

  /// JsonValue から QueryAccountを生成する. 失敗した場合はエラーが発生する
  static QueryAccount fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return QueryAccount(
        account: (switch (value.getObjectValueOrThrow('account')) {
      narumincho_json.JsonNull() => null,
      final jsonValue => Account.fromJsonValue(jsonValue),
    }));
  }
}

/// よくあるアカウントの型
@immutable
final class AccountOnlyName {
  /// よくあるアカウントの型
  const AccountOnlyName({
    required this.name,
  });

  /// 名前
  final String? name;

  /// `AccountOnlyName` を複製する
  @useResult
  AccountOnlyName copyWith({
    (String?,)? name,
  }) {
    return AccountOnlyName(name: ((name == null) ? this.name : name.$1));
  }

  /// `AccountOnlyName` のフィールドを変更したものを新しく返す
  @useResult
  AccountOnlyName updateFields({
    String? Function(String? prevName)? name,
  }) {
    return AccountOnlyName(
        name: ((name == null) ? this.name : name(this.name)));
  }

  @override
  @useResult
  int get hashCode {
    return name.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is AccountOnlyName) && (name == other.name));
  }

  @override
  @useResult
  String toString() {
    return 'AccountOnlyName(name: ${name}, )';
  }

  /// JsonValue から AccountOnlyNameを生成する. 失敗した場合はエラーが発生する
  static AccountOnlyName fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return AccountOnlyName(
        name: (switch (value.getObjectValueOrThrow('name')) {
      narumincho_json.JsonNull() => null,
      final jsonValue => jsonValue.asStringOrThrow(),
    }));
  }
}

/// データを取得できる. データを取得するのみで, データを変更しない
@immutable
final class QueryAccountWithAlias {
  /// データを取得できる. データを取得するのみで, データを変更しない
  const QueryAccountWithAlias({
    required this.account,
    required this.account,
  });

  /// IDからアカウントを取得
  final Account? account;

  /// IDからアカウントを取得
  final AccountOnlyName? account;

  /// `QueryAccountWithAlias` を複製する
  @useResult
  QueryAccountWithAlias copyWith({
    (Account?,)? account,
    (AccountOnlyName?,)? account,
  }) {
    return QueryAccountWithAlias(
      account: ((account == null) ? this.account : account.$1),
      account: ((account == null) ? this.account : account.$1),
    );
  }

  /// `QueryAccountWithAlias` のフィールドを変更したものを新しく返す
  @useResult
  QueryAccountWithAlias updateFields({
    Account? Function(Account? prevAccount)? account,
    AccountOnlyName? Function(AccountOnlyName? prevAccount)? account,
  }) {
    return QueryAccountWithAlias(
      account: ((account == null) ? this.account : account(this.account)),
      account: ((account == null) ? this.account : account(this.account)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      account,
      account,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return (((other is QueryAccountWithAlias) && (account == other.account)) &&
        (account == other.account));
  }

  @override
  @useResult
  String toString() {
    return 'QueryAccountWithAlias(account: ${account}, account: ${account}, )';
  }

  /// JsonValue から QueryAccountWithAliasを生成する. 失敗した場合はエラーが発生する
  static QueryAccountWithAlias fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return QueryAccountWithAlias(
      account: (switch (value.getObjectValueOrThrow('account')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => Account.fromJsonValue(jsonValue),
      }),
      account: (switch (value.getObjectValueOrThrow('account')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => AccountOnlyName.fromJsonValue(jsonValue),
      }),
    );
  }
}
