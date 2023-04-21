// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:dart_style/dart_style.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_dart_code_gen/wellknown_expr.dart' as wellknown_expr;
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;

@immutable
class SimpleDartCode {
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
      const ImportPackageFileNameAndAsName(
          packageAndFileName: 'package:narumincho_util/narumincho_util.dart'),
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
// ignore_for_file: camel_case_types, constant_identifier_names, prefer_interpolation_to_compose_strings, always_use_package_imports, unnecessary_parenthesis
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
class ImportPackageFileNameAndAsName {
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
class ClassDeclaration extends Declaration {
  const ClassDeclaration({
    required this.name,
    required this.documentationComments,
    required this.fields,
    required this.isAbstract,
    this.implementsClassList = const IListConst([]),
    this.staticFields = const IListConst([]),
    this.methods = const IListConst([]),
    this.isPrivateConstructor = false,
  });
  final String name;
  final String documentationComments;
  final IList<Field> fields;
  final bool isAbstract;
  final IList<String> implementsClassList;
  final IList<StaticField> staticFields;
  final IList<Method> methods;
  final bool isPrivateConstructor;

  @override
  String toCodeString() {
    return documentationCommentsToCodeString(documentationComments) +
        '@immutable\n' +
        (isAbstract ? 'abstract ' : '') +
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
    return [
      if (!isAbstract && !isPrivateConstructor && fields.isNotEmpty) ...[
        copyWithMethod(),
        updateFieldsMethod(),
      ],
      if (!isAbstract) ...[hashCodeMethod(), equalMethod(), toStringMethod()],
      ...methods,
    ].map((method) => method.toCodeString()).safeJoin();
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
                  parameterTypes: const IListConst([]),
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
            (field) {
              if (field.parameterPattern is ParameterPatternPositional) {
                return null;
              }
              return Tuple2(
                field.name,
                copyWithFieldExpr(field.name, field.type),
              );
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
            parameterTypes: IList([field.type]),
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
          namedArguments: IList(fields.mapAndRemoveNull(
            (field) {
              if (field.parameterPattern is ParameterPatternPositional) {
                return null;
              }
              return Tuple2(
                field.name,
                updateFieldsFieldExpr(field.name, field.type),
              );
            },
          )),
          positionalArguments: IList(fields.mapAndRemoveNull(
            (field) {
              if (field.parameterPattern is! ParameterPatternPositional) {
                return null;
              }
              return updateFieldsFieldExpr(field.name, field.type);
            },
          )),
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
    final namedCode = fields.mapAndRemoveNull((field) {
      final text = ExprOperator(
        ExprOperator(
          ExprStringLiteral(field.name + ': '),
          Operator.add,
          wellknown_expr.toStringMethod(ExprVariable(field.name)),
        ),
        Operator.add,
        ExprStringLiteral(','),
      );
      return field.parameterPattern.match(
        positional: (_) => null,
        named: (_) => text,
        namedWithDefault: (_) => text,
      );
    });
    final positionalCodeList = fields.mapAndRemoveNull(
      (field) => field.parameterPattern.match(
        positional: (positional) => ExprVariable(field.name),
        named: (_) => null,
        namedWithDefault: (_) => null,
      ),
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
          wellknown_expr.safeJoinMethod(
            ExprListLiteral(IList([
              ExprStringLiteral(name),
              ExprStringLiteral('('),
              ...positionalCodeList,
              ...namedCode,
              ExprStringLiteral(')'),
            ])),
          ),
        ),
      ]),
    );
  }
}

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
class Field {
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
class StaticField {
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
class Method {
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
class Parameter {
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
    return parameterPattern.match(
      positional: (_) => _nameWithThis(isConstructor) + ',',
      named: (_) => null,
      namedWithDefault: (_) => null,
    );
  }

  String? _namedArgumentToCodeString(bool isConstructor) {
    return parameterPattern.match(
      positional: (_) => null,
      named: (_) => 'required ' + _nameWithThis(isConstructor) + ',',
      namedWithDefault: (n) =>
          _nameWithThis(isConstructor) +
          (n.constDefaultExpr is ExprNull
              ? ''
              : '= ' +
                  n.constDefaultExpr.toCodeAndIsConst().toCodeString(true)) +
          ',',
    );
  }

  String _nameWithThis(bool isConstructor) {
    if (isConstructor) {
      return 'this.' + name;
    }
    return type.toCodeString() + ' ' + name;
  }
}

@immutable
abstract class Type {
  String toCodeString();

  Type setIsNullable(bool isNullable);

  bool getIsNullable();

  T match<T>({
    required T Function(TypeFunction) typeFunction,
    required T Function(TypeNormal) typeNormal,
  });
}

@immutable
class TypeFunction implements Type {
  const TypeFunction(
      {required this.returnType,
      required this.parameterTypes,
      this.isNullable = false});
  final Type returnType;
  final IList<Type> parameterTypes;
  final bool isNullable;

  @override
  String toCodeString() {
    return returnType.toCodeString() +
        ' Function(' +
        parameterTypes
            .map((parameter) => parameter.toCodeString())
            .safeJoin(',') +
        ')' +
        (isNullable ? '?' : '');
  }

  @override
  Type setIsNullable(bool isNullable) {
    return TypeFunction(
      parameterTypes: parameterTypes,
      returnType: returnType,
      isNullable: true,
    );
  }

  @override
  bool getIsNullable() {
    return isNullable;
  }

  @override
  T match<T>({
    required T Function(TypeFunction) typeFunction,
    required T Function(TypeNormal) typeNormal,
  }) {
    return typeFunction(this);
  }
}

@immutable
class TypeNormal implements Type {
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

  @override
  T match<T>({
    required T Function(TypeFunction) typeFunction,
    required T Function(TypeNormal) typeNormal,
  }) {
    return typeNormal(this);
  }
}

@immutable
class EnumDeclaration extends Declaration {
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
class EnumValue {
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
class StatementReturn implements Statement {
  const StatementReturn(this.expr);
  final Expr expr;

  @override
  String toCodeString() {
    return 'return ' + expr.toCodeAndIsConst().toCodeString(true) + ';\n';
  }
}

@immutable
class StatementFinal implements Statement {
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
class StatementIf implements Statement {
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
class StatementSwitch implements Statement {
  const StatementSwitch(this.expr, this.patternList);
  final Expr expr;
  final IList<Tuple2<Expr, IList<Statement>>> patternList;

  @override
  String toCodeString() {
    return 'switch (' +
        expr.toCodeAndIsConst().toCodeString(true) +
        ') {\n' +
        patternList
            .map(
              (pattern) =>
                  'case' +
                  pattern.first.toCodeAndIsConst().toCodeString(true) +
                  ': {\n' +
                  pattern.second
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
class StatementThrow implements Statement {
  const StatementThrow(this.expr);
  final Expr expr;

  @override
  String toCodeString() {
    return 'throw ' + expr.toCodeAndIsConst().toCodeString(true) + ';\n';
  }
}

/// 式
@immutable
abstract class Expr {
  const Expr();

  CodeAndIsConst toCodeAndIsConst();
}

@immutable
class ExprCall implements Expr {
  const ExprCall({
    required this.functionName,
    this.positionalArguments = const IListConst([]),
    this.namedArguments = const IListConst([]),
    this.isAwait = false,
  });
  final String functionName;
  final IList<Expr> positionalArguments;
  final IList<Tuple2<String, Expr>> namedArguments;
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
class ExprIntLiteral implements Expr {
  const ExprIntLiteral(this.value);
  final int value;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(value.toString(), ConstType.implicit);
  }
}

@immutable
class ExprStringLiteral implements Expr {
  const ExprStringLiteral(this.value);
  final String value;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final isDoubleQuote = value.contains("'") && !value.contains('"');
    final isNeedRaw = (value.contains(r'\') || value.contains(r'$')) &&
        !value.contains('\n') &&
        (!isDoubleQuote && !value.contains("'"));
    final escapedCommon = isNeedRaw
        ? value
        : value
            .replaceAll(r'\', r'\\')
            .replaceAll(r'$', r'\$')
            .replaceAll('\n', r'\n');

    return CodeAndIsConst(
      (isNeedRaw ? 'r' : '') +
          (isDoubleQuote
              ? '"' + escapedCommon + '"'
              : "'" + escapedCommon.replaceAll("'", r"\'") + "'"),
      ConstType.implicit,
    );
  }
}

@immutable
class ExprEnumValue implements Expr {
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
class ExprMethodCall implements Expr {
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
  final IList<Tuple2<String, Expr>> namedArguments;
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
class ExprConstructor implements Expr {
  const ExprConstructor({
    required this.className,
    required this.isConst,
    this.positionalArguments = const IListConst([]),
    this.namedArguments = const IListConst([]),
  });
  final String className;
  final IList<Expr> positionalArguments;
  final IList<Tuple2<String, Expr>> namedArguments;
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
class ExprLambda implements Expr {
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
class ExprListLiteral implements Expr {
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
class ExprMapLiteral implements Expr {
  const ExprMapLiteral(this.items);
  final IList<Tuple2<Expr, Expr>> items;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    final codeAndIsConstIter = items.map(
      (item) => Tuple2(
        item.first.toCodeAndIsConst(),
        item.second.toCodeAndIsConst(),
      ),
    );
    final isAllConst = codeAndIsConstIter.every(
      (item) => item.first.isConst() && item.second.isConst(),
    );
    return CodeAndIsConst(
      '{' +
          stringListJoinWithComma(
            IList(codeAndIsConstIter.map(
              (item) =>
                  item.first.toCodeString(!isAllConst) +
                  ': ' +
                  item.second.toCodeString(!isAllConst),
            )),
          ) +
          '}',
      isAllConst ? ConstType.explicit : ConstType.noConst,
    );
  }
}

@immutable
class ExprVariable implements Expr {
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
class ExprGet implements Expr {
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
class ExprIs implements Expr {
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
class ExprOperator implements Expr {
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
class ExprNull implements Expr {
  const ExprNull();

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return const CodeAndIsConst('null', ConstType.implicit);
  }
}

@immutable
class ExprBool implements Expr {
  const ExprBool(this.value);
  final bool value;

  @override
  CodeAndIsConst toCodeAndIsConst() {
    return CodeAndIsConst(value.toString(), ConstType.implicit);
  }
}

@immutable
class ExprConditionalOperator implements Expr {
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
  IList<Tuple2<String, Expr>> namedArguments,
) {
  final positionalArgumentsCodeAndIsConst =
      positionalArguments.map((argument) => argument.toCodeAndIsConst());
  final namedArgumentsCodeAndIsConst = namedArguments.map(
    (argument) => Tuple2(
      argument.first,
      argument.second.toCodeAndIsConst(),
    ),
  );
  final isAllConst = positionalArgumentsCodeAndIsConst
          .every((argument) => argument.isConst()) &&
      namedArgumentsCodeAndIsConst
          .every((argument) => argument.second.isConst());
  return CodeAndIsConst(
    '(' +
        stringListJoinWithComma(IList([
          ...positionalArgumentsCodeAndIsConst
              .map((argument) => argument.toCodeString(!isAllConst)),
          ...namedArgumentsCodeAndIsConst.map(
            (argument) =>
                argument.first +
                ': ' +
                argument.second.toCodeString(!isAllConst),
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
class CodeAndIsConst {
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

  /// 暗黙的const (constが出力されない) */
  implicit,

  /// 明示的的な const */
  explicit,
}

@immutable
abstract class ParameterPattern {
  const ParameterPattern();

  T match<T>({
    required T Function(ParameterPatternPositional) positional,
    required T Function(ParameterPatternNamed) named,
    required T Function(ParameterPatternNamedWithDefault) namedWithDefault,
  });
}

@immutable
class ParameterPatternPositional implements ParameterPattern {
  const ParameterPatternPositional();

  @override
  T match<T>({
    required T Function(ParameterPatternPositional) positional,
    required T Function(ParameterPatternNamed) named,
    required T Function(ParameterPatternNamedWithDefault) namedWithDefault,
  }) {
    return positional(this);
  }
}

@immutable
class ParameterPatternNamed implements ParameterPattern {
  const ParameterPatternNamed();

  @override
  T match<T>({
    required T Function(ParameterPatternPositional) positional,
    required T Function(ParameterPatternNamed) named,
    required T Function(ParameterPatternNamedWithDefault) namedWithDefault,
  }) {
    return named(this);
  }
}

@immutable
class ParameterPatternNamedWithDefault implements ParameterPattern {
  const ParameterPatternNamedWithDefault(this.constDefaultExpr);
  final Expr constDefaultExpr;

  @override
  T match<T>({
    required T Function(ParameterPatternPositional) positional,
    required T Function(ParameterPatternNamed) named,
    required T Function(ParameterPatternNamedWithDefault) namedWithDefault,
  }) {
    return namedWithDefault(this);
  }
}
