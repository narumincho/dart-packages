import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;
import 'package:test/test.dart';

void main() {
  test('flatMapAndRemoveNull', () {
    final code = SimpleDartCode(
      importPackageAndFileNames: const IListConst([]),
      declarationList: IList([
        ClassDeclaration(
          name: 'SampleClass',
          documentationComments: 'document',
          fields: IList([
            const Field(
              name: 'name',
              documentationComments: '名前',
              type: wellknown_type.String,
              parameterPattern: ParameterPatternNamed(),
            ),
            Field(
              name: 'age',
              documentationComments: '年齢',
              type: wellknown_type.double.setIsNullable(true),
              parameterPattern: const ParameterPatternNamed(),
            ),
          ]),
          modifier: ClassModifier.final_,
        ),
      ]),
    );
    expect(code.toCodeString(), r"""
// Generated by simple_dart_code_gen. Do not edit.
// ignore_for_file: camel_case_types, constant_identifier_names, always_use_package_imports
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';



/// document
@immutable
final class SampleClass {
/// document
  const SampleClass({required this.name,required this.age,});
/// 名前
  final String name;

/// 年齢
  final double? age;

/// `SampleClass` を複製する
@useResult
SampleClass copyWith({String? name,(double?,)? age,}) {
return SampleClass(name: (name??this.name),age: ((age==null) ? this.age : age.$1),);

}/// `SampleClass` のフィールドを変更したものを新しく返す
@useResult
SampleClass updateFields({String Function(String prevName)? name,double? Function(double? prevAge)? age,}) {
return SampleClass(name: ((name==null) ? this.name : name(this.name)),age: ((age==null) ? this.age : age(this.age)),);

}@override
@useResult
int get hashCode {
return Object.hash(name,age,);

}@override
@useResult
bool operator ==(Object other,) {
return (((other is SampleClass)&&(name==other.name))&&(age==other.age));

}@override
@useResult
String toString() {
return 'SampleClass(name: ${name}, age: ${age}, )';

}
}
""");
  });

  test('stringLiteral normal', () {
    expect(
      const ExprStringLiteral(IListConst([StringLiteralItemNormal('テスト')]))
          .toCodeAndConstType()
          .code,
      "'テスト'",
    );
  });

  test('stringLiteral double quote', () {
    expect(
      const ExprStringLiteral(IListConst([
        StringLiteralItemNormal("only single quote (')"),
      ])).toCodeAndConstType().code,
      ''''only single quote (\\')\'''',
    );
  });

  test('stringLiteral interpolation', () {
    expect(
      const ExprStringLiteral(IListConst([
        StringLiteralItemNormal('テスト'),
        StringLiteralItemInterpolation(ExprVariable('test')),
        StringLiteralItemInterpolation(
            ExprGet(expr: ExprVariable('obj'), fieldName: 'name')),
      ])).toCodeAndConstType().code,
      r"'テスト${test}${obj.name}'",
    );
  });

  test(
    'class to string method',
    () {
      const sampleClass = ClassDeclaration(
        name: 'SampleClass',
        documentationComments: 'document',
        fields: IListConst([
          Field(
            name: 'pos',
            documentationComments: '位置引数',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternPositional(),
          ),
          Field(
            name: 'name',
            documentationComments: '名前',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternNamed(),
          ),
          Field(
            name: 'age',
            documentationComments: '年齢',
            type: wellknown_type.double,
            parameterPattern: ParameterPatternNamed(),
          ),
        ]),
        modifier: null,
      );

      expect(sampleClass.toStringMethod().toCodeString(), r'''
@override
@useResult
String toString() {
return 'SampleClass(${pos}, name: ${name}, age: ${age}, )';

}''');
    },
  );

  test('record empty', () {
    expect(
      const ExprRecord().toCodeAndConstType().code,
      '()',
    );
  });

  test('record positional one', () {
    expect(
      const ExprRecord(
        positional: IListConst([ExprIntLiteral(28)]),
      ).toCodeAndConstType().code,
      '(28,)',
    );
  });

  test('switch expr', () {
    expect(
      const ExprSwitch(
        ExprVariable('value'),
        IListConst([
          (
            PatternNullLiteral(),
            ExprStringLiteral(IListConst([
              StringLiteralItemNormal('value is null'),
            ])),
          ),
          (
            PatternStringLiteral(
                IListConst([StringLiteralItemNormal('sampleText')])),
            ExprStringLiteral(IListConst([
              StringLiteralItemNormal('value is sampleText!'),
            ])),
          ),
          (
            PatternFinal('valueNotNull'),
            ExprStringLiteral(IListConst([
              StringLiteralItemNormal('value is '),
              StringLiteralItemInterpolation(ExprVariable('valueNotNull'))
            ])),
          ),
        ]),
      ).toCodeAndConstType().code,
      r'''
(switch (value) {null => 'value is null',
'sampleText' => 'value is sampleText!',
final valueNotNull => 'value is ${valueNotNull}',
})''',
    );
  });
}
