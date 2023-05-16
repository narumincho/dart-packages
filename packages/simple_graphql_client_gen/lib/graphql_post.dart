import 'dart:convert';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';

@immutable
final class GraphqlResponse {
  const GraphqlResponse(this.data, this.errors);

  final JsonObject? data;
  final IList<GraphqlError> errors;
}

@immutable
final class GraphqlError implements Exception {
  const GraphqlError(this.message, this.code);

  final String message;
  final String? code;
}

Future<GraphqlResponse> graphQLPost({
  required Uri uri,
  required String query,
  IMap<String, JsonValue>? variables,
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
    headers: {'content-type': 'application/json'},
  );
  final jsonValue = JsonValue.decode(
    utf8.decode(response.bodyBytes),
  );

  return GraphqlResponse(
    jsonValue.getObjectValueOrThrow('data').asJsonObjectOrNull(),
    jsonValue
            .getObjectValueOrNull('errors')
            ?.getAsArrayWithDecoder((errorJson) {
          final message =
              errorJson.getObjectValueOrNull('message')?.asStringOrNull();
          final code = errorJson.getObjectValueOrNull('code')?.asStringOrNull();
          if (message == null) {
            return null;
          }
          return GraphqlError(message, code);
        }) ??
        const IListConst([]),
  );
}
