import 'dart:convert';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';

@immutable
final class GraphqlResponse {
  const GraphqlResponse(this.data, this.errors);

  final JsonObject? data;
  final GraphqlErrors? errors;
}

@immutable
final class GraphqlErrors implements Exception {
  const GraphqlErrors(this.errors);

  /// nonEmpty
  final IList<GraphqlError> errors;

  @override
  String toString() {
    return errors.join('\n');
  }
}

@immutable
final class GraphqlError implements Exception {
  const GraphqlError({
    required this.message,
    required this.path,
    required this.extensionsCode,
  });

  final String message;
  final IList<PathItem> path;
  final String? extensionsCode;

  @override
  String toString() {
    return '[$extensionsCode] $message ($path)';
  }
}

@immutable
sealed class PathItem {
  const PathItem();
}

class PathItemString implements PathItem {
  const PathItemString(this.value);

  final String value;

  @override
  String toString() =>
      '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"';
}

class PathItemInt implements PathItem {
  const PathItemInt(this.value);

  final int value;

  @override
  String toString() => value.toString();
}

Future<GraphqlResponse> graphQLPost({
  required Uri uri,
  required String query,
  IMap<String, JsonValue>? variables,
  String? auth,
}) async {
  final http.Response response = await http.post(
    uri,
    body: JsonObject(
      IMap({
        'query': JsonString(query),
        'variables':
            variables == null ? const JsonNull() : JsonObject(variables),
      }),
    ).encode(),
    headers: {
      'content-type': 'application/json',
      if (auth != null) 'authorization': 'Bearer $auth',
    },
  );
  final jsonValue = JsonValue.decode(
    utf8.decode(response.bodyBytes),
  );

  final errors = jsonValue
          .getObjectValueOrNull('errors')
          ?.getAsArrayWithDecoder((errorJson) {
        final message =
            errorJson.getObjectValueOrNull('message')?.asStringOrNull();
        final path = IList(errorJson
            .getObjectValueOrNull('path')
            ?.getAsArray()
            ?.map((element) {
          switch (element.asStringOrNull()) {
            case final v?:
              return PathItemString(v);
          }
          switch (element.asDoubleOrNull()) {
            case final v?:
              return PathItemInt(v.toInt());
          }
          throw Exception('expected error path string or int but got $element');
        }));
        final extensionsCode = errorJson
            .getObjectValueOrNull('extensions')
            ?.getObjectValueOrNull('code')
            ?.asStringOrNull();
        return GraphqlError(
          message: message ?? 'Unknown error',
          path: path,
          extensionsCode: extensionsCode,
        );
      }) ??
      const IListConst([]);

  return GraphqlResponse(
    jsonValue.getObjectValueOrThrow('data').asJsonObjectOrNull(),
    errors.isEmpty ? null : GraphqlErrors(errors),
  );
}
