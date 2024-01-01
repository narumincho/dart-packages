import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;

void main() async {
  final code = SimpleDartCode(
    importPackageAndFileNames: const IListConst([]),
    declarationList: IListConst([
      ClassDeclaration(
        name: 'ClassDeclaration',
        documentationComments: '',
        fields: IList([
          const Field(
            name: 'name',
            documentationComments: '',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternNamed(),
          ),
          const Field(
            name: 'documentationComments',
            documentationComments: '',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternNamed(),
          ),
          Field(
            name: 'fields',
            documentationComments: '',
            type: wellknown_type.IList(const TypeNormal(name: 'Field')),
            parameterPattern: const ParameterPatternNamed(),
          ),
          Field(
            name: 'modifier',
            documentationComments: '',
            type: wellknown_type.IList(const TypeNormal(name: 'Field')),
            parameterPattern: const ParameterPatternNamed(),
          ),
        ]),
        modifier: ClassModifier.final_,
      )
    ]),
  ).toCodeString();
  await File('./packages/simple_graphql_client_gen/lib/out.dart')
      .writeAsString(code);
}
