// Generated by simple_dart_code_gen. Do not edit.
// ignore_for_file: camel_case_types, constant_identifier_names, always_use_package_imports
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

/// document
@immutable
final class SampleClass {
  /// document
  const SampleClass({
    required this.name,
    required this.age,
  });

  /// 名前
  final String name;

  /// 年齢
  final double? age;

  /// `SampleClass` を複製する
  @useResult
  SampleClass copyWith({
    String? name,
    (double?,)? age,
  }) {
    return SampleClass(
      name: (name ?? this.name),
      age: ((age == null) ? this.age : age.$1),
    );
  }

  /// `SampleClass` のフィールドを変更したものを新しく返す
  @useResult
  SampleClass updateFields({
    String Function(String prevName)? name,
    double? Function(double? prevAge)? age,
  }) {
    return SampleClass(
      name: ((name == null) ? this.name : name(this.name)),
      age: ((age == null) ? this.age : age(this.age)),
    );
  }

  @override
  @useResult
  int get hashCode {
    return Object.hash(
      name,
      age,
    );
  }

  @override
  @useResult
  bool operator ==(
    Object other,
  ) {
    return (((other is SampleClass) && (name == other.name)) &&
        (age == other.age));
  }

  @override
  @useResult
  String toString() {
    return 'SampleClass(name: ${name}, age: ${age}, )';
  }
}
