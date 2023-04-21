import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';

@immutable
abstract class Annotation {
  const Annotation();

  static Annotation? fromDocumentationComments(String documentationComments) {
    final simpleGraphQLClientGenAnnotationRegExpMatch = IList(RegExp('### simpleGraphQLClientGenAnnotation\n```json\n(.+)\n```').allMatches(documentationComments)).firstOrNull;
    final simpleGraphQLClientGenAnnotation = simpleGraphQLClientGenAnnotationRegExpMatch?.group(1);
    if (simpleGraphQLClientGenAnnotation == null) {
      return null;
    }
    return fromJson(JsonValue.decode(simpleGraphQLClientGenAnnotation));
  }

  static Annotation? fromJson(JsonValue jsonValue) {
    final type = jsonValue.getObjectValueOrThrow('type').asStringOrThrow();
    switch (type) {
      case 'text':
        return AnnotationText(
          maxLength: jsonValue.getObjectValueOrThrow('maxLength').asDoubleOrThrow().toInt(),
        );
      case 'token':
        return const AnnotationToken();
      case 'uuid':
        return const AnnotationUuid();
      case 'dateTime':
        return const AnnotationDateTime();
      case 'url':
        return const AnnotationUrl();
      default:
        return null;
    }
  }

  T match<T>({
    required T Function(AnnotationText) textFunc,
    required T Function(AnnotationDateTime) dateTimeFunc,
    required T Function(AnnotationToken) tokenFunc,
    required T Function(AnnotationUuid) uuidFunc,
    required T Function(AnnotationUrl) urlFunc,
  });
}

@immutable
class AnnotationText implements Annotation {
  const AnnotationText({required this.maxLength});

  final int maxLength;

  @override
  T match<T>({
    required T Function(AnnotationText) textFunc,
    required T Function(AnnotationDateTime) dateTimeFunc,
    required T Function(AnnotationToken) tokenFunc,
    required T Function(AnnotationUuid) uuidFunc,
    required T Function(AnnotationUrl) urlFunc,
  }) {
    return textFunc(this);
  }
}

@immutable
class AnnotationToken implements Annotation {
  const AnnotationToken();

  @override
  T match<T>({
    required T Function(AnnotationText) textFunc,
    required T Function(AnnotationDateTime) dateTimeFunc,
    required T Function(AnnotationToken) tokenFunc,
    required T Function(AnnotationUuid) uuidFunc,
    required T Function(AnnotationUrl) urlFunc,
  }) {
    return tokenFunc(this);
  }
}

@immutable
class AnnotationUuid implements Annotation {
  const AnnotationUuid();

  @override
  T match<T>({
    required T Function(AnnotationText) textFunc,
    required T Function(AnnotationDateTime) dateTimeFunc,
    required T Function(AnnotationToken) tokenFunc,
    required T Function(AnnotationUuid) uuidFunc,
    required T Function(AnnotationUrl) urlFunc,
  }) {
    return uuidFunc(this);
  }
}

@immutable
class AnnotationDateTime implements Annotation {
  const AnnotationDateTime();

  @override
  T match<T>({
    required T Function(AnnotationText) textFunc,
    required T Function(AnnotationDateTime) dateTimeFunc,
    required T Function(AnnotationToken) tokenFunc,
    required T Function(AnnotationUuid) uuidFunc,
    required T Function(AnnotationUrl) urlFunc,
  }) {
    return dateTimeFunc(this);
  }
}

@immutable
class AnnotationUrl implements Annotation {
  const AnnotationUrl();

  @override
  T match<T>({
    required T Function(AnnotationText) textFunc,
    required T Function(AnnotationDateTime) dateTimeFunc,
    required T Function(AnnotationToken) tokenFunc,
    required T Function(AnnotationUuid) uuidFunc,
    required T Function(AnnotationUrl) urlFunc,
  }) {
    return urlFunc(this);
  }
}
