import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

extension NaruminchoUtilIterable<T> on Iterable<T> {
//  先頭から関数を適用し, null だった場合は破棄する
  @useResult
  IList<Output> mapAndRemoveNull<Output>(Output? Function(T) func) {
    final List<Output> result = [];
    for (final item in this) {
      final itemOutput = func(item);
      if (itemOutput != null) {
        result.add(itemOutput);
      }
    }
    return IList(result);
  }

  /// 先頭から関数を適用したときに, 最初に null ではないものを返す
  @useResult
  Output? mapFirstNotNull<Output>(Output? Function(T) func) {
    for (final item in this) {
      final itemOutput = func(item);
      if (itemOutput != null) {
        return itemOutput;
      }
    }
    return null;
  }

  /// `expanded` とは違い `null` を取り除く [flatMap]
  @useResult
  Iterable<Output> flatMapAndRemoveNull<Output>(
      Iterable<Output?> Function(T) func) {
    return this.expand((item) {
      final List<Output> result = [];
      final itemOutput = func(item);
      for (final innerItem in itemOutput) {
        if (innerItem != null) {
          result.add(innerItem);
        }
      }
      return result;
    });
  }

  @useResult
  Iterable<T> addSeparator(T separator) {
    return this.expandIndexed((index, item) {
      if (this.length - 1 == index) {
        return [item];
      }
      return [item, separator];
    });
  }

  @useResult
  Iterable<T> setMinLength(int minLength, T fillValue) {
    if (this.length >= minLength) {
      return this;
    }
    return [...this, ...List.filled(minLength - this.length, fillValue)];
  }
}

extension NaruminchoUtilNullableIterable<T> on Iterable<T?> {
  @useResult
  IList<T>? allNonNullOrNull() {
    final result = <T>[];
    for (final item in this) {
      if (item == null) {
        return null;
      }
      result.add(item);
    }
    return IList(result);
  }
}

extension SafeISet<T> on ISet<T> {
  /// 取り除く要素の指定を T に制限した [removeAll]
  @useResult
  ISet<T> safeRemoveAll(Iterable<T> elements) {
    return removeAll(elements);
  }
}

extension SafeJoin on Iterable<String> {
  /// nullや String 以外の型が含まれていない iterable で [join] メソッドを呼ぶ
  @useResult
  String safeJoin([String separator = '']) {
    return join(separator);
  }
}

/// 文字列の最初の文字を小文字にしたものを返す
@useResult
String toFirstLowercase(String str) {
  if (str.isEmpty) {
    return '';
  }
  return str[0].toLowerCase() + str.substring(1);
}

/// 文字列の最初の文字を大文字にしたものを返す
@useResult
String toFirstUppercase(String str) {
  if (str.isEmpty) {
    return '';
  }
  return str[0].toUpperCase() + str.substring(1);
}

/// 重複ありでリストを2つの要素ずつ取り出したリストを返す
///
/// ```dart
/// splitOverlappingTuple2(['a', 'b', 'c', 'd']) // IList([('a', 'b'), ('b', 'c'), ('c', 'd')])
/// ```
@useResult
IList<(T, T)> splitOverlappingTuple2<T>(Iterable<T> iterable) {
  final firstOrNull = iterable.firstOrNull;
  if (firstOrNull == null) {
    return const IListConst([]);
  }
  return iterable.skip(1).fold<({T prevItem, IList<(T, T)> list})>(
    (prevItem: firstOrNull, list: const IListConst([])),
    (value, element) => (
      prevItem: element,
      list: IList([...value.list, (value.prevItem, element)]),
    ),
  ).list;
}

/// `/` から始まる絶対パスを作成する
///
/// ```dart
/// uriAbsolute(pathSegments: []) // '/'
/// uriAbsolute(pathSegments: ['project', '4e00952222a74177b2586bfb89cb5ca7']) // '/project/4e00952222a74177b2586bfb89cb5ca7'
/// uriAbsolute(pathSegments: ['path'], queryParameters: IMap({'position': 'left', 'empty': '', '': 'emptyValue'})) // '/path?position=left&empty&=emptyValue'
/// ```
///
/// see https://zenn.dev/koji_1009/articles/d86f1bcc775af3
Uri uriAbsolute({
  required Iterable<String> pathSegments,
  IMap<String, String>? queryParameters,
}) {
  if (pathSegments.isEmpty) {
    return Uri(path: '/', queryParameters: queryParameters?.unlock);
  }
  return Uri(
    pathSegments: ['', ...pathSegments],
    queryParameters: queryParameters?.unlock,
  );
}

/// 空ではないないことを保証した文字列
@immutable
final class NonEmptyString {
  const NonEmptyString._(this.value);

  static NonEmptyString? fromString(String value) {
    if (value.isEmpty) {
      return null;
    }
    return NonEmptyString._(value);
  }

  final String value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is NonEmptyString && other.value == value;
}
