import 'package:meta/meta.dart';

@immutable
class Original {
  final String value;

  const Original(this.value);

  @override
  String toString() => 'Original($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Original && value == other.value);

  @override
  int get hashCode => value.hashCode;
}
