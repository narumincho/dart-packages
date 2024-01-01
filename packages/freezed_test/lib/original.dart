import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

@immutable
class Original extends Matcher {
  const Original({required this.name, required this.age, required this.tags});

  final String name;
  final int age;
  final IList<String> tags;

  @override
  String toString() => 'Original(name: $name, age: $age, tags: $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Original &&
          name == other.name &&
          age == other.age &&
          tags == other.tags;

  @override
  int get hashCode => Object.hash(name, age, tags);

  @override
  Description describe(Description description) {
    return description.add('Original(name: $name, age: $age, tags: $tags)');
  }

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    print(matchState);
    if (item is! Original) {
      return false;
    }
    final nameMatches = name == item.name;
    final ageMatches = age == item.age;
    final tagsMatches = tags == item.tags;
    if (!nameMatches) {
      matchState['name'] = (name, item.name);
    }
    if (!ageMatches) {
      matchState['age'] = (age, item.age);
    }
    if (!tagsMatches) {
      matchState['tags'] = (tags, item.tags);
    }
    return nameMatches && ageMatches && tagsMatches;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
      Map<dynamic, dynamic> matchState, bool verbose) {
    // print(matchState);

    return mismatchDescription.addAll(
      '[',
      ',',
      ']',
      matchState.mapTo((key, value) {
        print(matchState);
        final (actual, expected) = value as (dynamic, dynamic);
        mismatchDescription.addDescriptionOf(value);
        print(matchState);

        return 'at location $key is $actual instead of $expected';
      }),
    );
  }
}

class SampleIter extends Iterable<int> {
  final List<int> list;

  SampleIter(this.list);

  @override
  Iterator<int> get iterator => list.iterator;
}
