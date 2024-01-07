import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_json/narumincho_json.dart';

@immutable
sealed class Annotation {
  const Annotation();

  static Annotation? fromDocumentationComments(String documentationComments) {
    final simpleGraphQLClientGenAnnotationRegExpMatch = IList(
            RegExp('### simpleGraphQLClientGenAnnotation\n```json\n(.+)\n```')
                .allMatches(documentationComments))
        .firstOrNull;
    final simpleGraphQLClientGenAnnotation =
        simpleGraphQLClientGenAnnotationRegExpMatch?.group(1);
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
          maxLength: jsonValue
              .getObjectValueOrThrow('maxLength')
              .asDoubleOrThrow()
              .toInt(),
        );
      case 'token':
        return const AnnotationToken();
      case 'uuid':
        return const AnnotationUuid();
      case 'dateTime':
        return const AnnotationDateTime();
      case 'url':
        return const AnnotationUrl();
      case 'regex':
        return AnnotationRegex(
          RegExp(jsonValue.getObjectValueOrThrow('pattern').asStringOrThrow()),
        );
      default:
        return null;
    }
  }
}

@immutable
final class AnnotationText implements Annotation {
  const AnnotationText({required this.maxLength});

  final int maxLength;
}

@immutable
final class AnnotationToken implements Annotation {
  const AnnotationToken();
}

@immutable
final class AnnotationUuid implements Annotation {
  const AnnotationUuid();
}

@immutable
final class AnnotationDateTime implements Annotation {
  const AnnotationDateTime();
}

@immutable
final class AnnotationUrl implements Annotation {
  const AnnotationUrl();
}

@immutable
final class AnnotationRegex implements Annotation {
  const AnnotationRegex(this.pattern);

  final RegExp pattern;
}
