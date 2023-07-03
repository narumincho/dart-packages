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
}

@immutable
final class GraphqlError implements Exception {
  const GraphqlError({
    required this.message,
    required this.path,
    required this.extensionsCode,
  });

  final String message;
  final IList<String> path;
  final String? extensionsCode;
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
            ?.map((element) => element.asStringOrThrow()));
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
