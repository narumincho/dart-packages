import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

/// `dart:convert` の json が型がゆるいため, 作ったもの
@immutable
sealed class JsonValue {
  const JsonValue();

  /// JSON の文字列から変換する. JSONとして正常な文字列でない場合は[FormatException]を発生させる
  @useResult
  static JsonValue decode(String jsonAsString) {
    return JsonValue.fromDynamic(json.decode(jsonAsString));
  }

  /// dart の値から変換する. 基本的に使わない
  @useResult
  static JsonValue fromDynamic(dynamic value) {
    if (value is String) {
      return JsonString(value);
    }
    if (value is bool) {
      return JsonBoolean(value);
    }
    // JavaScript に変換したときの仕様のため
    if (value is num) {
      return Json64bitFloat(value.toDouble());
    }
    if (value is Map<String, dynamic>) {
      return JsonObject(
        IMap(value.map(
          (mapKey, mapValue) {
            return MapEntry(mapKey, JsonValue.fromDynamic(mapValue));
          },
        )),
      );
    }
    if (value is Iterable<dynamic>) {
      return JsonArray(
        IList(value.map((iterItem) {
          return JsonValue.fromDynamic(iterItem);
        })),
      );
    }
    return const JsonNull();
  }

  /// JSON の文字列に変換する
  @useResult
  String encode() {
    return json.encode(toDartObjectOrNull());
  }

  /// dart の オブジェクトに変換する. 基本的に使わない
  /// テストの比較のときに使うと便利かも
  @useResult
  Object? toDartObjectOrNull() {
    return switch (this) {
      JsonString(value: final value) => value,
      JsonBoolean(value: final value) => value,
      Json64bitFloat(value: final value) => value,
      JsonObject(value: final value) => value
          .map<String, Object?>(
            (key, value) => MapEntry(key, value.toDartObjectOrNull()),
          )
          .unlock,
      JsonArray(value: final value) => value
          .map<Object?>(
            (e) => e.toDartObjectOrNull(),
          )
          .toList(growable: false),
      JsonNull() => null
    };
  }

  @useResult
  String? asStringOrNull() {
    return switch (this) {
      JsonString(value: final value) => value,
      _ => null,
    };
  }

  @useResult
  bool? asBoolOrNull() {
    return switch (this) {
      JsonBoolean(value: final value) => value,
      _ => null,
    };
  }

  @useResult
  double? asDoubleOrNull() {
    return switch (this) {
      Json64bitFloat(value: final value) => value,
      _ => null,
    };
  }

  @useResult
  JsonObject? asJsonObjectOrNull() {
    return switch (this) {
      JsonObject() && final obj => obj,
      _ => null,
    };
  }

  @useResult
  JsonValue getObjectValueOrThrow(String key) {
    return getObjectOrThrow().getValueByKeyOrThrow(key);
  }

  @useResult
  JsonValue? getObjectValueOrNull(String key) {
    return asJsonObjectOrNull()?.getValueByKeyOrNull(key);
  }

  @useResult
  String asStringOrThrow() {
    final value = asStringOrNull();
    if (value == null) {
      throw Exception(
        'json error: expected string but got ' + encode(),
      );
    }
    return value;
  }

  @useResult
  bool asBoolOrThrow() {
    final value = asBoolOrNull();
    if (value == null) {
      throw Exception(
        'json error: expected boolean but got ' + encode(),
      );
    }
    return value;
  }

  @useResult
  double asDoubleOrThrow() {
    final value = asDoubleOrNull();
    if (value == null) {
      throw Exception(
        'json error: expected number but got ' + encode(),
      );
    }
    return value;
  }

  @useResult
  JsonObject getObjectOrThrow() {
    final value = asJsonObjectOrNull();
    if (value == null) {
      throw Exception(
        'json error: expected object but got ' + encode(),
      );
    }
    return value;
  }

  @useResult
  bool isNull() {
    return switch (this) {
      JsonNull() => true,
      _ => false,
    };
  }

  @useResult
  IList<JsonValue>? getAsArray() {
    return switch (this) {
      JsonArray(value: final value) => value,
      _ => null,
    };
  }

  @useResult
  IList<T>? getAsArrayWithDecoder<T>(T? Function(JsonValue) decoder) {
    final jsonArray = getAsArray();
    if (jsonArray == null) {
      return null;
    }
    final List<T> result = [];
    for (final jsonItem in jsonArray) {
      final item = decoder(jsonItem);
      if (item == null) {
        return null;
      }
      result.add(item);
    }
    return IList(result);
  }

  @useResult
  IList<T> asArrayOrThrow<T>(T Function(JsonValue) decoder) {
    final jsonArray = getAsArray();
    if (jsonArray == null) {
      throw Exception('json decode error: expected array but got ' + encode());
    }
    return IList(jsonArray.map(decoder));
  }
}

@immutable
class JsonString extends JsonValue {
  const JsonString(this.value);
  final String value;

  @override
  bool operator ==(Object other) {
    return other is JsonString && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

@immutable
class JsonBoolean extends JsonValue {
  const JsonBoolean(this.value);
  final bool value;

  @override
  bool operator ==(Object other) {
    return other is JsonBoolean && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

@immutable
class Json64bitFloat extends JsonValue {
  const Json64bitFloat(this.value);
  final double value;

  @override
  bool operator ==(Object other) {
    return other is Json64bitFloat && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

@immutable
class JsonObject extends JsonValue {
  const JsonObject(this.value);
  final IMap<String, JsonValue> value;

  @override
  bool operator ==(Object other) {
    return other is JsonObject && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @useResult
  JsonValue getValueByKeyOrThrow(String key) {
    final objectValue = getValueByKeyOrNull(key);
    if (objectValue == null) {
      throw Exception(
        'json error: expected { "$key": ??, ... } but got ' + encode(),
      );
    }
    return objectValue;
  }

  JsonValue? getValueByKeyOrNull(String key) {
    return value[key];
  }
}

@immutable
class JsonNull extends JsonValue {
  const JsonNull();

  @override
  bool operator ==(Object other) {
    return other is JsonNull;
  }

  @override
  int get hashCode => null.hashCode;
}

@immutable
class JsonArray extends JsonValue {
  const JsonArray(this.value);
  final IList<JsonValue> value;

  @override
  bool operator ==(Object other) {
    return other is JsonArray &&
        value
            .toList(growable: false)
            .deepEquals(other.value.toList(growable: false));
  }

  @override
  int get hashCode => null.hashCode;
}
