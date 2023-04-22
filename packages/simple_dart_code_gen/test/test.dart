import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_type.dart';
import 'package:test/test.dart';

void main() {
  test('flatMapAndRemoveNull', () {
    const code = SimpleDartCode(
      importPackageAndFileNames: IListConst([]),
      declarationList: IListConst([
        ClassDeclaration(
          name: 'SampleClass',
          documentationComments: 'document',
          fields: IListConst([
            Field(
              name: 'name',
              documentationComments: '名前',
              type: String,
              parameterPattern: ParameterPatternNamed(),
            ),
            Field(
              name: 'age',
              documentationComments: '年齢',
              type: double,
              parameterPattern: ParameterPatternNamed(),
            ),
          ]),
          isAbstract: false,
        ),
      ]),
    );
    expect(code.toCodeString(), '''
// Generated by simple_dart_code_gen. Do not edit.
// ignore_for_file: camel_case_types, constant_identifier_names, prefer_interpolation_to_compose_strings, always_use_package_imports, unnecessary_parenthesis
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_util/narumincho_util.dart';

/// document
@immutable
class SampleClass {
  /// document
  const SampleClass({
    required this.name,
    required this.age,
  });

  /// 名前
  final String name;

  /// 年齢
  final double age;

  /// `SampleClass` を複製する
  @useResult
  SampleClass copyWith({
    String? name,
    double? age,
  }) {
    return SampleClass(
      name: (name ?? this.name),
      age: (age ?? this.age),
    );
  }

  /// `SampleClass` のフィールドを変更したものを新しく返す
  @useResult
  SampleClass updateFields({
    String Function(String prevName)? name,
    double Function(double prevAge)? age,
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
    return [
      'SampleClass',
      '(',
      (('name: ' + name.toString()) + ','),
      (('age: ' + age.toString()) + ','),
      ')',
    ].safeJoin();
  }
}
''');
  });
}
