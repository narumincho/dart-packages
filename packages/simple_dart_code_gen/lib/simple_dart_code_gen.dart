// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:dart_style/dart_style.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;

@immutable
final class SimpleDartCode {
  const SimpleDartCode({
    required this.importPackageAndFileNames,
    required this.declarationList,
  });

  /// インポートするファイル名.
  ///
  /// `package:meta/meta.dart` と `package:fast_immutable_collections/fast_immutable_collections.dart` は自動的に入る
  final IList<ImportPackageFileNameAndAsName> importPackageAndFileNames;
  final IList<Declaration> declarationList;

  @useResult
  String toCodeString() {
    final importPackageFileNameAndAsNameList = IList([
      const ImportPackageFileNameAndAsName(
          packageAndFileName: 'package:meta/meta.dart'),
      const ImportPackageFileNameAndAsName(
          packageAndFileName:
              'package:fast_immutable_collections/fast_immutable_collections.dart'),
      ...importPackageAndFileNames,
    ])
        .sort((a, b) =>
            comparePackageName(a.packageAndFileName, b.packageAndFileName))
        .divideIn2(
          (item) => item.packageAndFileName.startsWith('./'),
        );

    final importStatementAbsolute = importPackageFileNameAndAsNameList.last
        .map((n) => n.toImportStatementCodeString())
        .safeJoin('\n');
    final importStatementRelative = importPackageFileNameAndAsNameList.first
        .map((n) => n.toImportStatementCodeString())
        .safeJoin('\n');
    final declarationListCode = declarationList
        .map((declaration) => declaration.toCodeString())
        .safeJoin('\n\n');

    final code = '''
// Generated by simple_dart_code_gen. Do not edit.
// ignore_for_file: camel_case_types, constant_identifier_names, always_use_package_imports
${importStatementAbsolute}

${importStatementRelative}

${declarationListCode}
''';
    return DartFormatter().format(code);
  }
}

int comparePackageName(String a, String b) {
  final aIsLocal = a.startsWith('./');
  final bIsLocal = b.startsWith('./');
  if (aIsLocal && !bIsLocal) {
    return -1;
  }
  if (!aIsLocal && bIsLocal) {
    return 1;
  }
  return a.compareTo(b);
}

@immutable
final class ImportPackageFileNameAndAsName {
  const ImportPackageFileNameAndAsName({
    required this.packageAndFileName,
    this.asName,
  });
  final String packageAndFileName;
  final String? asName;

  String toImportStatementCodeString() {
    final asNameStringOrNull = asName;
    return "import '" +
        packageAndFileName +
        "'" +
        (asNameStringOrNull == null ? '' : 'as ' + asNameStringOrNull) +
        ';';
  }
}

@immutable
abstract class Declaration {
  const Declaration();

  String toCodeString();
}

@immutable
final class ClassDeclaration implements Declaration {
  const ClassDeclaration({
    required this.name,
    required this.documentationComments,
    required this.fields,
    required this.modifier,
    this.implementsClassList = const IListConst([]),
    this.staticFields = const IListConst([]),
    this.methods = const IListConst([]),
    this.isPrivateConstructor = false,
  });
  final String name;
  final String documentationComments;
  final IList<Field> fields;
  final ClassModifier? modifier;
  final IList<String> implementsClassList;
  final IList<StaticField> staticFields;
  final IList<Method> methods;
  final bool isPrivateConstructor;

  @override
  String toCodeString() {
    return documentationCommentsToCodeString(documentationComments) +
        '@immutable\n' +
        switch (modifier) {
          ClassModifier.abstract => 'abstract ',
          ClassModifier.sealed => 'sealed ',
          ClassModifier.final_ => 'final ',
          null => ''
        } +
        'class ' +
        name +
        ' ' +
        implementsClassListToCodeString() +
        '{\n' +
        constructorToCodeString() +
        fieldToCodeString() +
        staticFieldsToCodeString() +
        methodsToCodeString() +
        '\n}';
  }

  String implementsClassListToCodeString() {
    if (implementsClassList.isEmpty) {
      return '';
    }
    return 'implements ' + implementsClassList.safeJoin(',') + ' ';
  }

  String fieldToCodeString() {
    return fields
        .map(
          (field) =>
              documentationCommentsToCodeString(field.documentationComments) +
              '  final ${field.type.toCodeString()} ${field.name};\n\n',
        )
        .safeJoin();
  }

  String constructorToCodeString() {
    return documentationCommentsToCodeString(documentationComments) +
        '  const ' +
        name +
        (isPrivateConstructor ? '._' : '') +
        constructorFieldsToCodeString() +
        ';\n';
  }

  String constructorFieldsToCodeString() {
    return Parameter.toCodeString(
      true,
      IList(
        fields.map(
          (field) => Parameter(
            name: field.name,
            type: field.type,
            parameterPattern: field.parameterPattern,
          ),
        ),
      ),
    );
  }

  String staticFieldsToCodeString() {
    return staticFields
        .map(
          (field) => field.toCodeString(),
        )
        .safeJoin();
  }

  String methodsToCodeString() {
    final IList<Method> methodList = IList([
      ...switch (modifier) {
        ClassModifier.abstract => [],
        ClassModifier.sealed => [],
        ClassModifier.final_ || null => [
            if (!isPrivateConstructor && fields.isNotEmpty) ...[
              copyWithMethod(),
              updateFieldsMethod(),
            ],
            hashCodeMethod(),
            equalMethod(),
            toStringMethod()
          ]
      },
      ...methods,
    ]);
    return methodList.map((method) => method.toCodeString()).safeJoin();
  }

  Method copyWithMethod() {
    return Method(
      name: 'copyWith',
      documentationComments: '`$name` を複製する',
      useResultAnnotation: true,
      methodType: MethodType.normal,
      parameters: IList(fields.map(
        (field) => Parameter(
          name: field.name,
          type: field.type.getIsNullable()
              ? TypeFunction(
                  returnType: field.type,
                  parameters: const IListConst([]),
                  isNullable: true,
                )
              : field.type.setIsNullable(true),
          parameterPattern: ParameterPatternNamedWithDefault(ExprNull()),
        ),
      )),
      returnType: TypeNormal(name: name),
      statements: IList([
        StatementReturn(ExprConstructor(
          className: name,
          isConst: false,
          namedArguments: IList(fields.mapAndRemoveNull(
            (field) => switch (field.parameterPattern) {
              ParameterPatternPositional() => null,
              _ => (
                  name: field.name,
                  argument: copyWithFieldExpr(field.name, field.type),
                )
            },
          )),
          positionalArguments: IList(fields.mapAndRemoveNull(
            (field) {
              if (field.parameterPattern is! ParameterPatternPositional) {
                return null;
              }
              return copyWithFieldExpr(field.name, field.type);
            },
          )),
        ))
      ]),
    );
  }

  Method updateFieldsMethod() {
    return Method(
      name: 'updateFields',
      documentationComments: '`$name` のフィールドを変更したものを新しく返す',
      useResultAnnotation: true,
      methodType: MethodType.normal,
      parameters: IList(fields.map(
        (field) => Parameter(
          name: field.name,
          type: TypeFunction(
            returnType: field.type,
            parameters: IList([
              (name: 'prev' + toFirstUppercase(field.name), type: field.type)
            ]),
            isNullable: true,
          ),
          parameterPattern: ParameterPatternNamedWithDefault(ExprNull()),
        ),
      )),
      returnType: TypeNormal(name: name),
      statements: IList([
        StatementReturn(ExprConstructor(
          className: name,
          isConst: false,
          namedArguments: IList(
            fields.mapAndRemoveNull(
              (field) => switch (field.parameterPattern) {
                ParameterPatternPositional() => null,
                _ => (
                    name: field.name,
                    argument: updateFieldsFieldExpr(field.name, field.type),
                  )
              },
            ),
          ),
          positionalArguments: IList(
            fields.mapAndRemoveNull(
              (field) => switch (field.parameterPattern) {
                ParameterPatternPositional() =>
                  updateFieldsFieldExpr(field.name, field.type),
                _ => null,
              },
            ),
          ),
        ))
      ]),
    );
  }

  Method hashCodeMethod() {
    final oneField = fields.length == 1 ? fields.firstOrNull : null;
    final useHashAll = fields.length == 0 || 20 < fields.length;

    return Method(
      name: 'hashCode',
      documentationComments: '',
      useResultAnnotation: true,
      methodType: MethodType.override,
      isGetter: true,
      parameters: const IListConst([]),
      returnType: const TypeNormal(name: 'int'),
      statements: IList([
        StatementReturn(
          oneField == null
              ? ExprMethodCall(
                  variable: ExprVariable('Object'),
                  methodName: useHashAll ? 'hashAll' : 'hash',
                  positionalArguments: useHashAll
                      ? IList([
                          ExprListLiteral(IList(fields.map(
                            (field) => ExprVariable(field.name),
                          )))
                        ])
                      : IList(fields.map(
                          (field) => ExprVariable(field.name),
                        )),
                )
              : ExprGet(
                  expr: ExprVariable(oneField.name), fieldName: 'hashCode'),
        )
      ]),
    );
  }

  Method equalMethod() {
    return Method(
      name: Operator.equal.code,
      documentationComments: '',
      useResultAnnotation: true,
      methodType: MethodType.override,
      parameters: const IListConst([
        Parameter(
          name: 'other',
          type: TypeNormal(name: 'Object'),
          parameterPattern: ParameterPatternPositional(),
        ),
      ]),
      returnType: wellknown_type.bool,
      statements: IList([
        StatementReturn(fields.fold(
          ExprIs(
            expr: const ExprVariable('other'),
            type: TypeNormal(name: name),
          ),
          (expr, field) => ExprOperator(
            expr,
            Operator.logicalAnd,
            ExprOperator(
              ExprVariable(field.name),
              Operator.equal,
              ExprGet(expr: ExprVariable('other'), fieldName: field.name),
            ),
          ),
        ))
      ]),
    );
  }

  Method toStringMethod() {
    final namedCodeList = fields.expand<StringLiteralItem>((field) {
      return switch (field.parameterPattern) {
        ParameterPatternPositional() => const IListConst([]),
        _ => IListConst([
            StringLiteralItemNormal(field.name + ': '),
            StringLiteralItemInterpolation(ExprVariable(field.name)),
            StringLiteralItemNormal(', '),
          ]),
      };
    });
    final positionalCodeList = fields.expand<StringLiteralItem>(
      (field) => switch (field.parameterPattern) {
        ParameterPatternPositional() => [
            StringLiteralItemInterpolation(ExprVariable(field.name)),
            StringLiteralItemNormal(', '),
          ],
        _ => [],
      },
    );
    return Method(
      name: 'toString',
      documentationComments: '',
      useResultAnnotation: true,
      methodType: MethodType.override,
      parameters: const IListConst([]),
      returnType: wellknown_type.String,
      statements: IList([
        StatementReturn(
          ExprStringLiteral(IList([
            StringLiteralItemNormal(name + '('),
            ...positionalCodeList,
            ...namedCodeList,
            StringLiteralItemNormal(')'),
          ])),
        ),
      ]),
    );
  }
}

/// https://dart.dev/language/class-modifiers
enum ClassModifier { abstract, sealed, final_ }

Expr copyWithFieldExpr(String fieldName, Type type) {
  if (type.getIsNullable()) {
    return ExprConditionalOperator(
      ExprOperator(ExprVariable(fieldName), Operator.equal, ExprNull()),
      ExprGet(expr: ExprVariable('this'), fieldName: fieldName),
      ExprCall(functionName: fieldName),
    );
  }
  return ExprOperator(
    ExprVariable(fieldName),
    Operator.nullishCoalescing,
    ExprGet(expr: ExprVariable('this'), fieldName: fieldName),
  );
}

Expr updateFieldsFieldExpr(String fieldName, Type type) {
  return ExprConditionalOperator(
    ExprOperator(ExprVariable(fieldName), Operator.equal, ExprNull()),
    ExprGet(expr: ExprVariable('this'), fieldName: fieldName),
    ExprCall(
      functionName: fieldName,
      positionalArguments: IList([
        ExprGet(expr: ExprVariable('this'), fieldName: fieldName),
      ]),
    ),
  );
}

@immutable
final class Field {
  const Field({
    required this.name,
    required this.documentationComments,
    required this.type,
    required this.parameterPattern,
  });
  final String name;
  final String documentationComments;
  final Type type;
  final ParameterPattern parameterPattern;
}

@immutable
final class StaticField {
  const StaticField({
    required this.name,
    required this.documentationComments,
    required this.type,
    required this.expr,
  });
  final String name;
  final String documentationComments;
  final Type type;
  final Expr expr;

  String toCodeString() {
    final toCodeAndIsConst = expr.toCodeAndIsConst();
    return documentationCommentsToCodeString(
          documentationComments,
        ) +
        '  static ' +
        (toCodeAndIsConst.isConst() ? 'const ' : '') +
        type.toCodeString() +
        ' ' +
        name +
        ' = ' +
        toCodeAndIsConst.code +
        ';\n';
  }
}

@immutable
final class Method {
  const Method({
    required this.name,
    required this.documentationComments,
    required this.returnType,
    required this.parameters,
    required this.methodType,
    required this.statements,
    required this.useResultAnnotation,
    this.isAsync = false,
    this.typeParameters = const IListConst([]),
    this.isGetter = false,
  });
  final String name;
  final String documentationComments;
  final Type returnType;
  final IList<Parameter> parameters;
  final MethodType methodType;
  final IList<Statement> statements;
  final bool isAsync;
  final IList<String> typeParameters;
  final bool isGetter;
  final bool useResultAnnotation;

  String toCodeString() {
    return documentationCommentsToCodeString(documentationComments) +
        (methodType == MethodType.override ? '@override\n' : '') +
        (useResultAnnotation ? '@useResult\n' : '') +
        (methodType == MethodType.static ? 'static ' : '') +
        returnType.toCodeString() +
        ' ' +
        (isGetter ? 'get ' : '') +
        methodNameConsiderOperator() +
        (typeParameters.isEmpty
            ? ''
            : '<' + stringListJoinWithComma(typeParameters) + '>') +
        (isGetter ? '' : Parameter.toCodeString(false, parameters)) +
        (statements.isEmpty
            ? ';\n'
            : (isAsync ? ' async' : '') +
                ' {\n' +
                statements
                    .map(
                      (statement) => statement.toCodeString(),
                    )
                    .safeJoin() +
                '\n}');
  }

  String methodNameConsiderOperator() {
    if (name == '==') {
      return 'operator ==';
    }
    return name;
  }
}

enum MethodType { normal, override, static }

@immutable
final class Parameter {
  const Parameter({
    required this.name,
    required this.type,
    required this.parameterPattern,
  });
  final String name;
  final Type type;
  final ParameterPattern parameterPattern;

  static String toCodeString(
    bool isConstructor,
    IList<Parameter> parameters,
  ) {
    final namedCode = parameters
        .mapAndRemoveNull((parameter) =>
            parameter._positionalArgumentToCodeString(isConstructor))
        .safeJoin();
    final positionalCodeList = parameters.mapAndRemoveNull(
      (parameter) => parameter._namedArgumentToCodeString(isConstructor),
    );
    return '(' +
        namedCode +
        (positionalCodeList.isEmpty
            ? ''
            : '{' + positionalCodeList.safeJoin() + '}') +
        ')';
  }

  String? _positionalArgumentToCodeString(bool isConstructor) {
    return switch (parameterPattern) {
      ParameterPatternPositional() => _nameWithThis(isConstructor) + ',',
      _ => null,
    };
  }

  String? _namedArgumentToCodeString(bool isConstructor) {
    return switch (parameterPattern) {
      ParameterPatternPositional() => null,
      ParameterPatternNamed() =>
        'required ' + _nameWithThis(isConstructor) + ',',
      ParameterPatternNamedWithDefault(:final constDefaultExpr) =>
        _nameWithThis(isConstructor) +
            switch (constDefaultExpr) {
              ExprNull() => '',
              _ => '= ' + constDefaultExpr.toCodeAndIsConst().toCodeString(true)
            } +
            ',',
    };
  }

  String _nameWithThis(bool isConstructor) {
    if (isConstructor) {
      return 'this.' + name;
    }
    return type.toCodeString() + ' ' + name;
  }
}

@immutable
sealed class Type {
  String toCodeString();

  Type setIsNullable(bool isNullable);

  bool getIsNullable();
}

@immutable
final class TypeFunction implements Type {
  const TypeFunction({
    required this.returnType,
    required this.parameters,
    this.isNullable = false,
  });
  final Type returnType;
  final IList<({String name, Type type})> parameters;
  final bool isNullable;

  @override
  String toCodeString() {
    return returnType.toCodeString() +
        ' Function(' +
        parameters
            .map((parameter) =>
                parameter.type.toCodeString() + ' ' + parameter.name)
            .safeJoin(',') +
        ')' +
        (isNullable ? '?' : '');
  }

  @override
  Type setIsNullable(bool isNullable) {
    return TypeFunction(
      parameters: parameters,
      returnType: returnType,
      isNullable: true,
    );
  }

  @override
  bool getIsNullable() {
    return isNullable;
  }
}

@immutable
final class TypeNormal implements Type {
  const TypeNormal({
    required this.name,
    this.arguments = const IListConst([]),
    this.isNullable = false,
  });
  final String name;
  final IList<Type> arguments;
  final bool isNullable;

  @override
  String toCodeString() {
    return name +
        (arguments.isEmpty
            ? ''
            : '<' +
                arguments
                    .map((argument) => argument.toCodeString())
                    .safeJoin(', ') +
                '>') +
        (isNullable ? '?' : '');
  }

  TypeNormal setNamespace(String namespace) {
    return TypeNormal(
      name: namespace + '.' + name,
      arguments: arguments,
      isNullable: isNullable,
    );
  }

  @override
  Type setIsNullable(bool isNullable) {
    return TypeNormal(
      name: name,
      arguments: arguments,
      isNullable: isNullable,
    );
  }

  @override
  bool getIsNullable() {
    return isNullable;
  }
}

@immutable
final class EnumDeclaration implements Declaration {
  const EnumDeclaration({
    required this.name,
    required this.documentationComments,
    required this.enumValues,
    this.implementsClassList = const IListConst([]),
    this.methods = const IListConst([]),
  });
  final String name;
  final String documentationComments;
  final IList<EnumValue> enumValues;
  final IList<String> implementsClassList;
  final IList<Method> methods;

  @override
  String toCodeString() {
    return documentationCommentsToCodeString(documentationComments) +
        'enum ' +
        name +
        (implementsClassList.isEmpty
            ? ''
            : ' implements ' + implementsClassList.safeJoin(',')) +
        ' {\n' +
        enumValues.map((enumValue) => enumValue.toCodeString()).safeJoin('\n') +
        (methods.isEmpty
            ? ''
            : ';' +
                methods.map((method) => method.toCodeString()).safeJoin(
                      '\n',
                    )) +
        '}';
  }
}

@immutable
final class EnumValue {
  const EnumValue({
    required this.name,
    required this.documentationComments,
  });
  final String name;
  final String documentationComments;

  String toCodeString() {
    return documentationCommentsToCodeString(documentationComments) +
        '  ' +
        name +
        ',\n';
  }
}

const documentationCommentsSlash = '///';

String documentationCommentsToCodeString(String documentationComments) {
  final trimmed = documentationComments.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return documentationComments.split('\n').map((line) {
    if (line.trim().isEmpty) {
      return documentationCommentsSlash + '\n';
    }
    return documentationCommentsSlash + ' ' + line.trimRight() + '\n';
  }).safeJoin();
}

/// 文
@immutable
abstract class Statement {
  const Statement();

  String toCodeString();
}

/// ```dart
/// return expr;
/// ```
@immutable
final class StatementReturn implements Statement {
  const StatementReturn(this.expr);
  final Expr expr;

  @override
  String toCodeString() {
    return 'return ' + expr.toCodeAndIsConst().toCodeString(true) + ';\n';
  }
}

@immutable
final class StatementFinal implements Statement {
  const StatementFinal({
    required this.variableName,
    required this.expr,
  });
  final String variableName;
  final Expr expr;

  @override
  String toCodeString() {
    final codeAndIsConst = expr.toCodeAndIsConst();
    return (codeAndIsConst.isConst() ? 'const' : 'final') +
        ' ' +
        variableName +
        ' = ' +
        codeAndIsConst.code +
        ';\n';
  }
}

@immutable
final class StatementIf implements Statement {
  const StatementIf({
    required this.condition,
    required this.thenStatement,
  });
  final Expr condition;
  final IList<Statement> thenStatement;

  @override
  String toCodeString() {
    return 'if (' +
        condition.toCodeAndIsConst().toCodeString(true) +
        ') {\n' +
        thenStatement.map((statement) => statement.toCodeString()).safeJoin() +
        '}\n';
  }
}

@immutable
final class StatementSwitch implements Statement {
  const StatementSwitch(this.expr, this.patternList);
  final Expr expr;
  final IList<({Expr case_, IList<Statement> statements})> patternList;

  @override
  String toCodeString() {
    return 'switch (' +
        expr.toCodeAndIsConst().toCodeString(true) +
        ') {\n' +
        patternList
            .map(
              (pattern) =>
                  'case' +
                  pattern.case_.toCodeAndIsConst().toCodeString(true) +
                  ': {\n' +
                  pattern.statements
                      .map(
                        (statement) => statement.toCodeString(),
                      )
                      .safeJoin() +
                  '\n}\n',
            )
            .safeJoin('\n') +
        '}\n';
  }
}

@immutable
final class StatementThrow implements Statement {
  const StatementThrow(this.expr);
  final Expr expr;

  @override
  String toCodeString() {
    return 'throw ' + expr.toCodeAndIsConst().toCodeString(true) + ';\n';
  }
}

/// 式
@immutable
sealed class Expr {
  const Expr();

  CodeAndIsConst toCodeAndIsConst();
}

@immutable
final class ExprCall implements Expr {
  const ExprCall({
    required this.functionName,
    this.positionalArguments = const IListConst([]),
    this.namedArguments = const IListConst([]),
    this.isAwait = false,
  });
  final String functionName;
  final IList<Expr> positionalArguments;
  final IList<({String name, Expr argument})> namedArguments;
  final bool isAwait;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      (isAwait ? 'await ' : '') +
          functionName +
          _argumentsToString(positionalArguments, namedArguments).code,
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprIntLiteral implements Expr {
  const ExprIntLiteral(this.value);
  final int value;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(value.toString(), ConstType.implicit);
  }
}

@immutable
final class ExprStringLiteral implements Expr {
  const ExprStringLiteral(this.items);
  final IList<StringLiteralItem> items;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final isDoubleQuote = items.any(
      (element) => element.containSingleQuoteNotDabble,
    );
    final codeAndIsConstList =
        IList(items.map((item) => item.toCodeAndIsConst()));
    final isAllConst = codeAndIsConstList.every((item) => item.isConst());
    return CodeAndIsConst(
      isDoubleQuote
          ? '"' + codeAndIsConstList.map((item) => item.code).safeJoin() + '"'
          : "'" +
              items
                  .map((item) => switch (item) {
                        StringLiteralItemNormal() =>
                          item.toCodeAndIsConst().code.replaceAll("'", r"\'"),
                        StringLiteralItemInterpolation() =>
                          item.toCodeAndIsConst().code
                      })
                  .safeJoin() +
              "'",
      isAllConst ? ConstType.implicit : ConstType.noConst,
    );
  }
}

@immutable
sealed class StringLiteralItem {
  const StringLiteralItem();

  CodeAndIsConst toCodeAndIsConst();

  bool get containSingleQuoteNotDabble;
}

@immutable
final class StringLiteralItemInterpolation implements StringLiteralItem {
  const StringLiteralItemInterpolation(this.expr);

  final Expr expr;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final codeAndIsConst = expr.toCodeAndIsConst();
    return CodeAndIsConst(
      r'${' + codeAndIsConst.code + '}',
      codeAndIsConst.type,
    );
  }

  @override
  bool get containSingleQuoteNotDabble {
    return false;
  }
}

@immutable
final class StringLiteralItemNormal implements StringLiteralItem {
  const StringLiteralItemNormal(this.value);

  final String value;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      value
          .replaceAll(r'\', r'\\')
          .replaceAll(r'$', r'\$')
          .replaceAll('\n', r'\n'),
      ConstType.implicit,
    );
  }

  @override
  bool get containSingleQuoteNotDabble {
    return value.contains("'") && !value.contains('"');
  }
}

@immutable
final class ExprEnumValue implements Expr {
  const ExprEnumValue({
    required this.typeName,
    required this.valueName,
  });
  final String typeName;
  final String valueName;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(typeName + '.' + valueName, ConstType.implicit);
  }
}

@immutable
final class ExprMethodCall implements Expr {
  const ExprMethodCall({
    required this.variable,
    required this.methodName,
    this.positionalArguments = const IListConst([]),
    this.namedArguments = const IListConst([]),
    this.optionalChaining = false,
  });
  final Expr variable;
  final String methodName;
  final IList<Expr> positionalArguments;
  final IList<({String name, Expr argument})> namedArguments;
  final bool optionalChaining;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      variable.toCodeAndIsConst().toCodeString(true) +
          (optionalChaining ? '?' : '') +
          '.' +
          methodName +
          _argumentsToString(positionalArguments, namedArguments).code,
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprConstructor implements Expr {
  const ExprConstructor({
    required this.className,
    required this.isConst,
    this.positionalArguments = const IListConst([]),
    this.namedArguments = const IListConst([]),
  });
  final String className;
  final IList<Expr> positionalArguments;
  final IList<({String name, Expr argument})> namedArguments;
  final bool isConst;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final argumentsCodeAndIsConst =
        _argumentsToString(positionalArguments, namedArguments);
    return CodeAndIsConst(
      className + argumentsCodeAndIsConst.code,
      (isConst && argumentsCodeAndIsConst.isConst())
          ? ConstType.explicit
          : ConstType.noConst,
    );
  }
}

@immutable
final class ExprLambda implements Expr {
  const ExprLambda({
    required this.parameterNames,
    required this.statements,
  });
  final IList<String> parameterNames;
  final IList<Statement> statements;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      '(' +
          parameterNames.safeJoin(',') +
          ') {\n' +
          statements.map((statement) => statement.toCodeString()).safeJoin() +
          '\n}',
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprListLiteral implements Expr {
  const ExprListLiteral(this.items);
  final IList<Expr> items;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final codeAndIsConstIter = items.map((item) => item.toCodeAndIsConst());
    final isAllConst = codeAndIsConstIter.every((item) => item.isConst());
    return CodeAndIsConst(
      '[' +
          stringListJoinWithComma(
            IList(codeAndIsConstIter.map(
              (item) => item.toCodeString(!isAllConst),
            )),
          ) +
          ']',
      isAllConst ? ConstType.explicit : ConstType.noConst,
    );
  }
}

@immutable
final class ExprMapLiteral implements Expr {
  const ExprMapLiteral(this.items);
  final IList<({Expr key, Expr value})> items;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final codeAndIsConstIter = items.map(
      (item) => (
        key: item.key.toCodeAndIsConst(),
        value: item.value.toCodeAndIsConst(),
      ),
    );
    final isAllConst = codeAndIsConstIter.every(
      (item) => item.key.isConst() && item.value.isConst(),
    );
    return CodeAndIsConst(
      '{' +
          stringListJoinWithComma(
            IList(codeAndIsConstIter.map(
              (item) =>
                  item.key.toCodeString(!isAllConst) +
                  ': ' +
                  item.value.toCodeString(!isAllConst),
            )),
          ) +
          '}',
      isAllConst ? ConstType.explicit : ConstType.noConst,
    );
  }
}

@immutable
final class ExprVariable implements Expr {
  const ExprVariable(this.name, {this.isConst = false});
  final String name;
  final bool isConst;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      name,
      isConst ? ConstType.implicit : ConstType.noConst,
    );
  }
}

@immutable
final class ExprGet implements Expr {
  const ExprGet({required this.expr, required this.fieldName});
  final Expr expr;
  final String fieldName;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      expr.toCodeAndIsConst().toCodeString(true) + '.' + fieldName,
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprIs implements Expr {
  const ExprIs({required this.expr, required this.type});
  final Expr expr;
  final Type type;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      '(' +
          expr.toCodeAndIsConst().toCodeString(true) +
          ' is ' +
          type.toCodeString() +
          ')',
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprOperator implements Expr {
  const ExprOperator(this.left, this.operator, this.right);
  final Expr left;
  final Expr right;
  final Operator operator;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      '(' +
          left.toCodeAndIsConst().toCodeString(true) +
          operator.code +
          right.toCodeAndIsConst().toCodeString(true) +
          ')',
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprNull implements Expr {
  const ExprNull();

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return const CodeAndIsConst('null', ConstType.implicit);
  }
}

@immutable
final class ExprBool implements Expr {
  const ExprBool(this.value);
  final bool value;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(value.toString(), ConstType.implicit);
  }
}

@immutable
final class ExprConditionalOperator implements Expr {
  const ExprConditionalOperator(this.condition, this.thenExpr, this.elseExpr);
  final Expr condition;
  final Expr thenExpr;
  final Expr elseExpr;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(
      '(' +
          condition.toCodeAndIsConst().toCodeString(true) +
          ' ? ' +
          thenExpr.toCodeAndIsConst().toCodeString(true) +
          ' : ' +
          elseExpr.toCodeAndIsConst().toCodeString(true) +
          ')',
      ConstType.noConst,
    );
  }
}

enum Operator {
  /// `??`
  nullishCoalescing('??'),

  /// `!=`
  notEqual('!='),

  /// `==`
  equal('=='),

  /// `+`
  add('+'),

  /// `&&`
  logicalAnd('&&');

  const Operator(this.code);
  final String code;
}

CodeAndIsConst _argumentsToString(
  IList<Expr> positionalArguments,
  IList<({String name, Expr argument})> namedArguments,
) {
  final positionalArgumentsCodeAndIsConst =
      positionalArguments.map((argument) => argument.toCodeAndIsConst());
  final namedArgumentsCodeAndIsConst = namedArguments.map(
    (argument) => (
      name: argument.name,
      argument: argument.argument.toCodeAndIsConst(),
    ),
  );
  final isAllConst = positionalArgumentsCodeAndIsConst
          .every((argument) => argument.isConst()) &&
      namedArgumentsCodeAndIsConst
          .every((argument) => argument.argument.isConst());
  return CodeAndIsConst(
    '(' +
        stringListJoinWithComma(IList([
          ...positionalArgumentsCodeAndIsConst
              .map((argument) => argument.toCodeString(!isAllConst)),
          ...namedArgumentsCodeAndIsConst.map(
            (argument) =>
                argument.name +
                ': ' +
                argument.argument.toCodeString(!isAllConst),
          ),
        ])) +
        ')',
    isAllConst ? ConstType.explicit : ConstType.noConst,
  );
}

String stringListJoinWithComma(IList<String> list) {
  if (list.isEmpty) {
    return '';
  }
  final first = list.firstOrNull;
  if (first != null && list.length == 1) {
    return first;
  }
  return list.map((item) => item + ',').safeJoin();
}

@immutable
final class CodeAndIsConst {
  const CodeAndIsConst(this.code, this.type);
  final String code;
  final ConstType type;

  /// @param isLimit 全体として const ではない (const を出力する) なら true
  String toCodeString(bool isLimit) {
    return ((type == ConstType.explicit && isLimit) ? 'const ' : '') + code;
  }

  bool isConst() {
    return type != ConstType.noConst;
  }
}

enum ConstType {
  noConst,

  /// 暗黙的const (constが出力されない)
  implicit,

  /// 明示的的な const
  explicit,
}

@immutable
sealed class ParameterPattern {
  const ParameterPattern();
}

@immutable
final class ParameterPatternPositional implements ParameterPattern {
  const ParameterPatternPositional();
}

@immutable
final class ParameterPatternNamed implements ParameterPattern {
  const ParameterPatternNamed();
}

@immutable
final class ParameterPatternNamedWithDefault implements ParameterPattern {
  const ParameterPatternNamedWithDefault(this.constDefaultExpr);
  final Expr constDefaultExpr;
}
