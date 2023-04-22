import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

extension MoreImmutableCollection<T> on IList<T> {
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
}

extension FlatMapRemoveNull<T> on Iterable<T> {
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
}

extension SafeISet<T> on ISet<T> {
  /// 取り除く要素の指定を T に制限した [removeAll]
  @useResult
  ISet<T> safeRemoveAll(Iterable<T> elements) {
    return removeAll(elements);
  }
}

extension SaveJoin on Iterable<String> {
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
/// splitOverlappingTuple2(['a', 'b', 'c']) // IList([Tuple2('a', 'b'), Tuple2('b', 'c')])
/// ```
@useResult
IList<Tuple2<T, T>> splitOverlappingTuple2<T>(Iterable<T> iterable) {
  final firstOrNull = iterable.firstOrNull;
  if (firstOrNull == null) {
    return const IListConst([]);
  }
  return iterable
      .skip(1)
      .fold<Tuple2<T, IList<Tuple2<T, T>>>>(
        Tuple2(firstOrNull, const IListConst([])),
        (value, element) => Tuple2(
          element,
          IList([...value.second, Tuple2(value.first, element)]),
        ),
      )
      .second;
}
