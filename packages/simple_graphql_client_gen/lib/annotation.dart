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
      case 'dateTime':
        return const AnnotationDateTime();
      case 'url':
        return const AnnotationUrl();
      case 'regexp':
        return AnnotationRegExp(
          RegExp(jsonValue.getObjectValueOrThrow('pattern').asStringOrThrow()),
        );
      default:
        return null;
    }
  }
}

final class AnnotationText implements Annotation {
  const AnnotationText({required this.maxLength});

  final int maxLength;
}

final class AnnotationDateTime implements Annotation {
  const AnnotationDateTime();
}

final class AnnotationUrl implements Annotation {
  const AnnotationUrl();
}

final class AnnotationRegExp implements Annotation {
  const AnnotationRegExp(this.pattern);

  final RegExp pattern;
}
