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
  /// query {
  ///   __typename
  /// }
  /// ```
  static Future<QueryEmpty> empty(
    Uri url,
    String? auth,
  ) async {
    final response = await graphql_post.graphQLPost(
      uri: url,
      auth: auth,
      query: 'query {\n  __typename\n}\n',
    );
    final errors = response.errors;
    if ((errors != null)) {
      throw errors;
    }
    final data = response.data;
    if ((data == null)) {
      throw Exception('empty response data empty');
    }
    return QueryEmpty.fromJsonValue(data);
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
  ///   accountOne: account(id: $subId) {
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
          'query (\$id: ID!, \$subId: ID!) {\n  account(id: \$id) {\n    id\n    name\n  }\n  accountOne: account(id: \$subId) {\n    name\n  }\n}\n',
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

  /// ```
  /// query ($id: ID!) {
  ///   union(id: $id) {
  ///     __typename
  ///     ... on Account {
  ///       id
  ///       name
  ///     }
  ///     ... on Note {
  ///       description
  ///       subNotes {
  ///         description
  ///       }
  ///     }
  ///   }
  /// }
  /// ```
  static Future<QueryUnion> union(
    Uri url,
    String? auth, {
    required type.ID id,
  }) async {
    final response = await graphql_post.graphQLPost(
      uri: url,
      auth: auth,
      query:
          'query (\$id: ID!) {\n  union(id: \$id) {\n    __typename\n    ... on Account {\n      id\n      name\n    }\n    ... on Note {\n      description\n      subNotes {\n        description\n      }\n    }\n  }\n}\n',
      variables: IMap({'id': id.toJsonValue()}),
    );
    final errors = response.errors;
    if ((errors != null)) {
      throw errors;
    }
    final data = response.data;
    if ((data == null)) {
      throw Exception('union response data empty');
    }
    return QueryUnion.fromJsonValue(data);
  }

  /// ```
  /// mutation ($accountIdInner: ID!, $accountId: ID!, $id: ID!) {
  ///   union(id: $id) {
  ///     __typename
  ///     ... on Account {
  ///       id
  ///       name
  ///     }
  ///     ... on Note {
  ///       description
  ///       subNotes {
  ///         description
  ///         subNotes {
  ///           description
  ///         }
  ///         isLiked(accountId: $accountIdInner)
  ///       }
  ///       isLiked(accountId: $accountId)
  ///     }
  ///   }
  /// }
  /// ```
  static Future<MutationInnerParameter> innerParameter(
    Uri url,
    String? auth, {
    required type.ID accountIdInner,
    required type.ID accountId,
    required type.ID id,
  }) async {
    final response = await graphql_post.graphQLPost(
      uri: url,
      auth: auth,
      query:
          'mutation (\$accountIdInner: ID!, \$accountId: ID!, \$id: ID!) {\n  union(id: \$id) {\n    __typename\n    ... on Account {\n      id\n      name\n    }\n    ... on Note {\n      description\n      subNotes {\n        description\n        subNotes {\n          description\n        }\n        isLiked(accountId: \$accountIdInner)\n      }\n      isLiked(accountId: \$accountId)\n    }\n  }\n}\n',
      variables: IMap({
        'accountIdInner': accountIdInner.toJsonValue(),
        'accountId': accountId.toJsonValue(),
        'id': id.toJsonValue(),
      }),
    );
    final errors = response.errors;
    if ((errors != null)) {
      throw errors;
    }
    final data = response.data;
    if ((data == null)) {
      throw Exception('innerParameter response data empty');
    }
    return MutationInnerParameter.fromJsonValue(data);
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

/// データを取得できる. データを取得するのみで, データを変更しない
@immutable
final class QueryEmpty {
  /// データを取得できる. データを取得するのみで, データを変更しない
  const QueryEmpty();
  @override
  @useResult
  int get hashCode {
    return Object.hashAll([]);
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return (other is QueryEmpty);
  }

  @override
  @useResult
  String toString() {
    return 'QueryEmpty()';
  }

  /// JsonValue から QueryEmptyを生成する. 失敗した場合はエラーが発生する
  static QueryEmpty fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return const QueryEmpty();
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
    required this.accountOne,
  });

  /// IDからアカウントを取得
  final Account? account;

  /// alias account → accountOne
  /// IDからアカウントを取得
  final AccountOnlyName? accountOne;

  /// `QueryAccountWithAlias` を複製する
  @useResult
  QueryAccountWithAlias copyWith({
    (Account?,)? account,
    (AccountOnlyName?,)? accountOne,
  }) {
    return QueryAccountWithAlias(
      account: ((account == null) ? this.account : account.$1),
      accountOne: ((accountOne == null) ? this.accountOne : accountOne.$1),
    );
  }

  /// `QueryAccountWithAlias` のフィールドを変更したものを新しく返す
  @useResult
  QueryAccountWithAlias updateFields({
    Account? Function(Account? prevAccount)? account,
    AccountOnlyName? Function(AccountOnlyName? prevAccountOne)? accountOne,
  }) {
    return QueryAccountWithAlias(
      account: ((account == null) ? this.account : account(this.account)),
      accountOne: ((accountOne == null)
          ? this.accountOne
          : accountOne(this.accountOne)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      account,
      accountOne,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return (((other is QueryAccountWithAlias) && (account == other.account)) &&
        (accountOne == other.accountOne));
  }

  @override
  @useResult
  String toString() {
    return 'QueryAccountWithAlias(account: ${account}, accountOne: ${accountOne}, )';
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
      accountOne: (switch (value.getObjectValueOrThrow('accountOne')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => AccountOnlyName.fromJsonValue(jsonValue),
      }),
    );
  }
}

/// よくあるアカウントの型
@immutable
final class AccountInUnionA
    implements AccountOrNote, AccountOrNoteInInnerParameter {
  /// よくあるアカウントの型
  const AccountInUnionA({
    required this.id,
    required this.name,
  });

  /// 識別するためのID
  final type.ID id;

  /// 名前
  final String? name;

  /// `AccountInUnionA` を複製する
  @useResult
  AccountInUnionA copyWith({
    type.ID? id,
    (String?,)? name,
  }) {
    return AccountInUnionA(
      id: (id ?? this.id),
      name: ((name == null) ? this.name : name.$1),
    );
  }

  /// `AccountInUnionA` のフィールドを変更したものを新しく返す
  @useResult
  AccountInUnionA updateFields({
    type.ID Function(type.ID prevId)? id,
    String? Function(String? prevName)? name,
  }) {
    return AccountInUnionA(
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
    return (((other is AccountInUnionA) && (id == other.id)) &&
        (name == other.name));
  }

  @override
  @useResult
  String toString() {
    return 'AccountInUnionA(id: ${id}, name: ${name}, )';
  }

  /// JsonValue から AccountInUnionAを生成する. 失敗した場合はエラーが発生する
  static AccountInUnionA fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return AccountInUnionA(
      id: type.ID.fromJsonValue(value.getObjectValueOrThrow('id')),
      name: (switch (value.getObjectValueOrThrow('name')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => jsonValue.asStringOrThrow(),
      }),
    );
  }
}

/// ノート
@immutable
final class Note2 {
  /// ノート
  const Note2({
    required this.description,
  });

  /// 説明文
  final type.ID description;

  /// `Note2` を複製する
  @useResult
  Note2 copyWith({
    type.ID? description,
  }) {
    return Note2(description: (description ?? this.description));
  }

  /// `Note2` のフィールドを変更したものを新しく返す
  @useResult
  Note2 updateFields({
    type.ID Function(type.ID prevDescription)? description,
  }) {
    return Note2(
        description: ((description == null)
            ? this.description
            : description(this.description)));
  }

  @override
  @useResult
  int get hashCode {
    return description.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is Note2) && (description == other.description));
  }

  @override
  @useResult
  String toString() {
    return 'Note2(description: ${description}, )';
  }

  /// JsonValue から Note2を生成する. 失敗した場合はエラーが発生する
  static Note2 fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return Note2(
        description:
            type.ID.fromJsonValue(value.getObjectValueOrThrow('description')));
  }
}

/// ノート
@immutable
final class Note implements AccountOrNote {
  /// ノート
  const Note({
    required this.description,
    required this.subNotes,
  });

  /// 説明文
  final type.ID description;

  /// 子ノート
  final IList<Note2> subNotes;

  /// `Note` を複製する
  @useResult
  Note copyWith({
    type.ID? description,
    IList<Note2>? subNotes,
  }) {
    return Note(
      description: (description ?? this.description),
      subNotes: (subNotes ?? this.subNotes),
    );
  }

  /// `Note` のフィールドを変更したものを新しく返す
  @useResult
  Note updateFields({
    type.ID Function(type.ID prevDescription)? description,
    IList<Note2> Function(IList<Note2> prevSubNotes)? subNotes,
  }) {
    return Note(
      description: ((description == null)
          ? this.description
          : description(this.description)),
      subNotes: ((subNotes == null) ? this.subNotes : subNotes(this.subNotes)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      description,
      subNotes,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return (((other is Note) && (description == other.description)) &&
        (subNotes == other.subNotes));
  }

  @override
  @useResult
  String toString() {
    return 'Note(description: ${description}, subNotes: ${subNotes}, )';
  }

  /// JsonValue から Noteを生成する. 失敗した場合はエラーが発生する
  static Note fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return Note(
      description:
          type.ID.fromJsonValue(value.getObjectValueOrThrow('description')),
      subNotes: value.getObjectValueOrThrow('subNotes').asArrayOrThrow((v) {
        return Note2.fromJsonValue(v);
      }),
    );
  }
}

@immutable
sealed class AccountOrNote {
  const AccountOrNote();

  /// JsonValue から AccountOrNoteを生成する. 失敗した場合はエラーが発生する
  static AccountOrNote fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    final typeName =
        value.getObjectValueOrThrow('__typename').asStringOrThrow();
    switch (typeName) {
      case 'Account':
        {
          return AccountInUnionA.fromJsonValue(value);
        }

      case 'Note':
        {
          return Note.fromJsonValue(value);
        }
    }
    throw Exception(
        'invalid __typename in AccountOrNote. __typename=${typeName}');
  }
}

/// データを取得できる. データを取得するのみで, データを変更しない
@immutable
final class QueryUnion {
  /// データを取得できる. データを取得するのみで, データを変更しない
  const QueryUnion({
    required this.union,
  });

  /// IDからアカウントもしくはノートを取得
  final AccountOrNote union;

  /// `QueryUnion` を複製する
  @useResult
  QueryUnion copyWith({
    AccountOrNote? union,
  }) {
    return QueryUnion(union: (union ?? this.union));
  }

  /// `QueryUnion` のフィールドを変更したものを新しく返す
  @useResult
  QueryUnion updateFields({
    AccountOrNote Function(AccountOrNote prevUnion)? union,
  }) {
    return QueryUnion(
        union: ((union == null) ? this.union : union(this.union)));
  }

  @override
  @useResult
  int get hashCode {
    return union.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is QueryUnion) && (union == other.union));
  }

  @override
  @useResult
  String toString() {
    return 'QueryUnion(union: ${union}, )';
  }

  /// JsonValue から QueryUnionを生成する. 失敗した場合はエラーが発生する
  static QueryUnion fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return QueryUnion(
        union:
            AccountOrNote.fromJsonValue(value.getObjectValueOrThrow('union')));
  }
}

/// ノート
@immutable
final class NoteInInnerParameterInner {
  /// ノート
  const NoteInInnerParameterInner({
    required this.description,
    required this.subNotes,
    required this.isLiked,
  });

  /// 説明文
  final type.ID description;

  /// 子ノート
  final IList<Note2> subNotes;

  /// 指定したアカウントからいいねされているか
  final bool? isLiked;

  /// `NoteInInnerParameterInner` を複製する
  @useResult
  NoteInInnerParameterInner copyWith({
    type.ID? description,
    IList<Note2>? subNotes,
    (bool?,)? isLiked,
  }) {
    return NoteInInnerParameterInner(
      description: (description ?? this.description),
      subNotes: (subNotes ?? this.subNotes),
      isLiked: ((isLiked == null) ? this.isLiked : isLiked.$1),
    );
  }

  /// `NoteInInnerParameterInner` のフィールドを変更したものを新しく返す
  @useResult
  NoteInInnerParameterInner updateFields({
    type.ID Function(type.ID prevDescription)? description,
    IList<Note2> Function(IList<Note2> prevSubNotes)? subNotes,
    bool? Function(bool? prevIsLiked)? isLiked,
  }) {
    return NoteInInnerParameterInner(
      description: ((description == null)
          ? this.description
          : description(this.description)),
      subNotes: ((subNotes == null) ? this.subNotes : subNotes(this.subNotes)),
      isLiked: ((isLiked == null) ? this.isLiked : isLiked(this.isLiked)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      description,
      subNotes,
      isLiked,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((((other is NoteInInnerParameterInner) &&
                (description == other.description)) &&
            (subNotes == other.subNotes)) &&
        (isLiked == other.isLiked));
  }

  @override
  @useResult
  String toString() {
    return 'NoteInInnerParameterInner(description: ${description}, subNotes: ${subNotes}, isLiked: ${isLiked}, )';
  }

  /// JsonValue から NoteInInnerParameterInnerを生成する. 失敗した場合はエラーが発生する
  static NoteInInnerParameterInner fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return NoteInInnerParameterInner(
      description:
          type.ID.fromJsonValue(value.getObjectValueOrThrow('description')),
      subNotes: value.getObjectValueOrThrow('subNotes').asArrayOrThrow((v) {
        return Note2.fromJsonValue(v);
      }),
      isLiked: (switch (value.getObjectValueOrThrow('isLiked')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => jsonValue.asBoolOrThrow(),
      }),
    );
  }
}

/// ノート
@immutable
final class NoteInInnerParameter implements AccountOrNoteInInnerParameter {
  /// ノート
  const NoteInInnerParameter({
    required this.description,
    required this.subNotes,
    required this.isLiked,
  });

  /// 説明文
  final type.ID description;

  /// 子ノート
  final IList<NoteInInnerParameterInner> subNotes;

  /// 指定したアカウントからいいねされているか
  final bool? isLiked;

  /// `NoteInInnerParameter` を複製する
  @useResult
  NoteInInnerParameter copyWith({
    type.ID? description,
    IList<NoteInInnerParameterInner>? subNotes,
    (bool?,)? isLiked,
  }) {
    return NoteInInnerParameter(
      description: (description ?? this.description),
      subNotes: (subNotes ?? this.subNotes),
      isLiked: ((isLiked == null) ? this.isLiked : isLiked.$1),
    );
  }

  /// `NoteInInnerParameter` のフィールドを変更したものを新しく返す
  @useResult
  NoteInInnerParameter updateFields({
    type.ID Function(type.ID prevDescription)? description,
    IList<NoteInInnerParameterInner> Function(
            IList<NoteInInnerParameterInner> prevSubNotes)?
        subNotes,
    bool? Function(bool? prevIsLiked)? isLiked,
  }) {
    return NoteInInnerParameter(
      description: ((description == null)
          ? this.description
          : description(this.description)),
      subNotes: ((subNotes == null) ? this.subNotes : subNotes(this.subNotes)),
      isLiked: ((isLiked == null) ? this.isLiked : isLiked(this.isLiked)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      description,
      subNotes,
      isLiked,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((((other is NoteInInnerParameter) &&
                (description == other.description)) &&
            (subNotes == other.subNotes)) &&
        (isLiked == other.isLiked));
  }

  @override
  @useResult
  String toString() {
    return 'NoteInInnerParameter(description: ${description}, subNotes: ${subNotes}, isLiked: ${isLiked}, )';
  }

  /// JsonValue から NoteInInnerParameterを生成する. 失敗した場合はエラーが発生する
  static NoteInInnerParameter fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return NoteInInnerParameter(
      description:
          type.ID.fromJsonValue(value.getObjectValueOrThrow('description')),
      subNotes: value.getObjectValueOrThrow('subNotes').asArrayOrThrow((v) {
        return NoteInInnerParameterInner.fromJsonValue(v);
      }),
      isLiked: (switch (value.getObjectValueOrThrow('isLiked')) {
        narumincho_json.JsonNull() => null,
        final jsonValue => jsonValue.asBoolOrThrow(),
      }),
    );
  }
}

@immutable
sealed class AccountOrNoteInInnerParameter {
  const AccountOrNoteInInnerParameter();

  /// JsonValue から AccountOrNoteInInnerParameterを生成する. 失敗した場合はエラーが発生する
  static AccountOrNoteInInnerParameter fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    final typeName =
        value.getObjectValueOrThrow('__typename').asStringOrThrow();
    switch (typeName) {
      case 'Account':
        {
          return AccountInUnionA.fromJsonValue(value);
        }

      case 'Note':
        {
          return NoteInInnerParameter.fromJsonValue(value);
        }
    }
    throw Exception(
        'invalid __typename in AccountOrNoteInInnerParameter. __typename=${typeName}');
  }
}

/// データを作成、更新ができる
@immutable
final class MutationInnerParameter {
  /// データを作成、更新ができる
  const MutationInnerParameter({
    required this.union,
  });

  /// IDからアカウントもしくはノートを取得
  final AccountOrNoteInInnerParameter union;

  /// `MutationInnerParameter` を複製する
  @useResult
  MutationInnerParameter copyWith({
    AccountOrNoteInInnerParameter? union,
  }) {
    return MutationInnerParameter(union: (union ?? this.union));
  }

  /// `MutationInnerParameter` のフィールドを変更したものを新しく返す
  @useResult
  MutationInnerParameter updateFields({
    AccountOrNoteInInnerParameter Function(
            AccountOrNoteInInnerParameter prevUnion)?
        union,
  }) {
    return MutationInnerParameter(
        union: ((union == null) ? this.union : union(this.union)));
  }

  @override
  @useResult
  int get hashCode {
    return union.hashCode;
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return ((other is MutationInnerParameter) && (union == other.union));
  }

  @override
  @useResult
  String toString() {
    return 'MutationInnerParameter(union: ${union}, )';
  }

  /// JsonValue から MutationInnerParameterを生成する. 失敗した場合はエラーが発生する
  static MutationInnerParameter fromJsonValue(
    narumincho_json.JsonValue value,
  ) {
    return MutationInnerParameter(
        union: AccountOrNoteInInnerParameter.fromJsonValue(
            value.getObjectValueOrThrow('union')));
  }
}
