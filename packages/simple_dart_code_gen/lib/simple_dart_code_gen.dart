// ignore_for_file: prefer_interpolation_to_compose_strings

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
$importStatementAbsolute

$importStatementRelative

$declarationListCode
''';

    return code;
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
sealed class Declaration {
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
              ? TypeRecord(
                  items: IList([field.type]),
                  isNullable: true,
                )
              : field.type.setIsNullable(true),
          parameterPattern: const ParameterPatternNamedWithDefault(ExprNull()),
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
                  argument: _copyWithFieldExpr(field.name, field.type),
                )
            },
          )),
          positionalArguments: IList(fields.mapAndRemoveNull(
            (field) {
              if (field.parameterPattern is! ParameterPatternPositional) {
                return null;
              }
              return _copyWithFieldExpr(field.name, field.type);
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
          parameterPattern: const ParameterPatternNamedWithDefault(ExprNull()),
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
    final useHashAll = fields.isEmpty || 20 < fields.length;

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
                  variable: const ExprVariable('Object'),
                  methodName: useHashAll ? 'hashAll' : 'hash',
                  positionalArguments: useHashAll
                      ? IList([
                          ExprListLiteral(IList(fields.map(
                            (field) =>
                                (ExprVariable(field.name), spread: false),
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
              ExprGet(expr: const ExprVariable('other'), fieldName: field.name),
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
            const StringLiteralItemNormal(', '),
          ]),
      };
    });
    final positionalCodeList = fields.expand<StringLiteralItem>(
      (field) => switch (field.parameterPattern) {
        ParameterPatternPositional() => [
            StringLiteralItemInterpolation(ExprVariable(field.name)),
            const StringLiteralItemNormal(', '),
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
            const StringLiteralItemNormal(')'),
          ])),
        ),
      ]),
    );
  }
}

/// https://dart.dev/language/class-modifiers
enum ClassModifier { abstract, sealed, final_ }

Expr _copyWithFieldExpr(String fieldName, Type type) {
  if (type.getIsNullable()) {
    return ExprConditionalOperator(
      ExprOperator(ExprVariable(fieldName), Operator.equal, const ExprNull()),
      ExprGet(expr: const ExprVariable('this'), fieldName: fieldName),
      ExprGet(expr: ExprVariable(fieldName), fieldName: r'$1'),
    );
  }
  return ExprOperator(
    ExprVariable(fieldName),
    Operator.nullishCoalescing,
    ExprGet(expr: const ExprVariable('this'), fieldName: fieldName),
  );
}

Expr updateFieldsFieldExpr(String fieldName, Type type) {
  return ExprConditionalOperator(
    ExprOperator(ExprVariable(fieldName), Operator.equal, const ExprNull()),
    ExprGet(expr: const ExprVariable('this'), fieldName: fieldName),
    ExprCall(
      functionName: fieldName,
      positionalArguments: IList([
        ExprGet(expr: const ExprVariable('this'), fieldName: fieldName),
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
    final toCodeAndConstType = expr.toCodeAndConstType();
    return documentationCommentsToCodeString(
          documentationComments,
        ) +
        '  static ' +
        (toCodeAndConstType.isConst() ? 'const ' : '') +
        type.toCodeString() +
        ' ' +
        name +
        ' = ' +
        toCodeAndConstType.code +
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
              _ =>
                '= ' + constDefaultExpr.toCodeAndConstType().toCodeString(true)
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
final class TypeRecord implements Type {
  const TypeRecord({
    required this.items,
    this.isNullable = false,
  });
  final IList<Type> items;
  final bool isNullable;

  @override
  String toCodeString() {
    return '(' +
        items
            .map(
              (item) => item.toCodeString(),
            )
            .safeJoin(', ') +
        (items.length == 1 ? ',' : '') +
        ')' +
        (isNullable ? '?' : '');
  }

  @override
  Type setIsNullable(bool isNullable) {
    return TypeRecord(
      items: items,
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
sealed class Statement {
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
    return 'return ' + expr.toCodeAndConstType().toCodeString(true) + ';\n';
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
    final codeAndConstType = expr.toCodeAndConstType();
    return (codeAndConstType.isConst() ? 'const' : 'final') +
        ' ' +
        variableName +
        ' = ' +
        codeAndConstType.code +
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
        condition.toCodeAndConstType().toCodeString(true) +
        ') {\n' +
        thenStatement.map((statement) => statement.toCodeString()).safeJoin() +
        '}\n';
  }
}

@immutable
final class StatementSwitch implements Statement {
  const StatementSwitch(this.expr, this.patternList);
  final Expr expr;
  final IList<({Pattern pattern, IList<Statement> statements})> patternList;

  @override
  String toCodeString() {
    return 'switch (' +
        expr.toCodeAndConstType().toCodeString(true) +
        ') {\n' +
        patternList
            .map(
              (pattern) =>
                  'case ' +
                  pattern.pattern.toCodeString() +
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
    return 'throw ' + expr.toCodeAndConstType().toCodeString(true) + ';\n';
  }
}

/// 式
@immutable
sealed class Expr {
  const Expr();

  CodeAndConstType toCodeAndConstType();
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      (isAwait ? 'await ' : '') +
          functionName +
          _argumentsToCodeAndConstType(
            positionalArguments: positionalArguments,
            namedArguments: namedArguments,
          ).code,
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprIntLiteral implements Expr {
  const ExprIntLiteral(this.value);
  final int value;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(value.toString(), ConstType.implicit);
  }
}

@immutable
final class ExprStringLiteral implements Expr {
  const ExprStringLiteral(this.items);
  final IList<StringLiteralItem> items;

  @override
  CodeAndConstType toCodeAndConstType() {
    final codeAndConstTypeList =
        IList(items.map((item) => item.toCodeAndConstType()));
    final isAllConst = codeAndConstTypeList.every((item) => item.isConst());
    return CodeAndConstType(
      "'" + codeAndConstTypeList.map((item) => item.code).safeJoin() + "'",
      isAllConst ? ConstType.implicit : ConstType.noConst,
    );
  }
}

@immutable
sealed class StringLiteralItem {
  const StringLiteralItem();

  CodeAndConstType toCodeAndConstType();
}

@immutable
final class StringLiteralItemInterpolation implements StringLiteralItem {
  const StringLiteralItemInterpolation(this.expr);

  final Expr expr;

  @override
  CodeAndConstType toCodeAndConstType() {
    final codeAndConstType = expr.toCodeAndConstType();
    return CodeAndConstType(
      r'${' + codeAndConstType.code + '}',
      codeAndConstType.type,
    );
  }
}

@immutable
final class StringLiteralItemNormal implements StringLiteralItem {
  const StringLiteralItemNormal(this.value);

  final String value;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      _escapeStringLiteralValue(value),
      ConstType.implicit,
    );
  }
}

String _escapeStringLiteralValue(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll('\n', r'\n')
    .replaceAll("'", r"\'");

@immutable
final class ExprEnumValue implements Expr {
  const ExprEnumValue({
    required this.typeName,
    required this.valueName,
  });
  final String typeName;
  final String valueName;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(typeName + '.' + valueName, ConstType.implicit);
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      variable.toCodeAndConstType().toCodeString(true) +
          (optionalChaining ? '?' : '') +
          '.' +
          methodName +
          _argumentsToCodeAndConstType(
            positionalArguments: positionalArguments,
            namedArguments: namedArguments,
          ).code,
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
  CodeAndConstType toCodeAndConstType() {
    final argumentsCodeAndConstType = _argumentsToCodeAndConstType(
      positionalArguments: positionalArguments,
      namedArguments: namedArguments,
    );
    return CodeAndConstType(
      className + argumentsCodeAndConstType.code,
      (isConst && argumentsCodeAndConstType.isConst())
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
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
  final IList<(Expr expr, {bool spread})> items;

  @override
  CodeAndConstType toCodeAndConstType() {
    final codeAndConstTypeIter = items
        .map((item) => (item.$1.toCodeAndConstType(), spread: item.spread));
    final isAllConst = codeAndConstTypeIter.every((item) => item.$1.isConst());
    return CodeAndConstType(
      '[' +
          stringListJoinWithComma(
            IList(codeAndConstTypeIter.map(
              (item) =>
                  (item.spread ? '...' : '') +
                  item.$1.toCodeString(!isAllConst),
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
  CodeAndConstType toCodeAndConstType() {
    final codeAndConstTypeIter = items.map(
      (item) => (
        key: item.key.toCodeAndConstType(),
        value: item.value.toCodeAndConstType(),
      ),
    );
    final isAllConst = codeAndConstTypeIter.every(
      (item) => item.key.isConst() && item.value.isConst(),
    );
    return CodeAndConstType(
      '{' +
          stringListJoinWithComma(
            IList(codeAndConstTypeIter.map(
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      expr.toCodeAndConstType().toCodeString(true) + '.' + fieldName,
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      '(' +
          expr.toCodeAndConstType().toCodeString(true) +
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
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      '(' +
          left.toCodeAndConstType().toCodeString(true) +
          operator.code +
          right.toCodeAndConstType().toCodeString(true) +
          ')',
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprNull implements Expr {
  const ExprNull();

  @override
  CodeAndConstType toCodeAndConstType() {
    return const CodeAndConstType('null', ConstType.implicit);
  }
}

@immutable
final class ExprBool implements Expr {
  const ExprBool(this.value);
  final bool value;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(value.toString(), ConstType.implicit);
  }
}

@immutable
final class ExprConditionalOperator implements Expr {
  const ExprConditionalOperator(this.condition, this.thenExpr, this.elseExpr);
  final Expr condition;
  final Expr thenExpr;
  final Expr elseExpr;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      '(' +
          condition.toCodeAndConstType().toCodeString(true) +
          ' ? ' +
          thenExpr.toCodeAndConstType().toCodeString(true) +
          ' : ' +
          elseExpr.toCodeAndConstType().toCodeString(true) +
          ')',
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprRecord implements Expr {
  const ExprRecord({
    this.positional = const IListConst([]),
    this.named = const IListConst([]),
  });

  final IList<Expr> positional;
  final IList<({String name, Expr argument})> named;

  @override
  CodeAndConstType toCodeAndConstType() {
    return _argumentsToCodeAndConstType(
      positionalArguments: positional,
      namedArguments: named,
      trailingComma: named.isEmpty && positional.length == 1,
    );
  }
}

@immutable
final class ExprSwitch implements Expr {
  const ExprSwitch(this.expr, this.patternList);

  final Expr expr;
  final IList<(Pattern, Expr)> patternList;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      '(switch (' +
          expr.toCodeAndConstType().toCodeString(true) +
          ') {' +
          patternList
              .map(
                (patternAndExpr) =>
                    patternAndExpr.$1.toCodeString() +
                    ' => ' +
                    patternAndExpr.$2.toCodeAndConstType().toCodeString(true) +
                    ',\n',
              )
              .safeJoin() +
          '})',
      ConstType.noConst,
    );
  }
}

@immutable
final class ExprThrow implements Expr {
  const ExprThrow(this.expr);

  final Expr expr;

  @override
  CodeAndConstType toCodeAndConstType() {
    return CodeAndConstType(
      '(throw ' + expr.toCodeAndConstType().toCodeString(true) + ')',
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

CodeAndConstType _argumentsToCodeAndConstType({
  required IList<Expr> positionalArguments,
  required IList<({String name, Expr argument})> namedArguments,
  bool trailingComma = false,
}) {
  final positionalArgumentsCodeAndConstType =
      positionalArguments.map((argument) => argument.toCodeAndConstType());
  final namedArgumentsCodeAndConstType = namedArguments.map(
    (argument) => (
      name: argument.name,
      argument: argument.argument.toCodeAndConstType(),
    ),
  );
  final isAllConst = positionalArgumentsCodeAndConstType
          .every((argument) => argument.isConst()) &&
      namedArgumentsCodeAndConstType
          .every((argument) => argument.argument.isConst());
  return CodeAndConstType(
    '(' +
        stringListJoinWithComma(IList([
          ...positionalArgumentsCodeAndConstType
              .map((argument) => argument.toCodeString(!isAllConst)),
          ...namedArgumentsCodeAndConstType.map(
            (argument) =>
                argument.name +
                ': ' +
                argument.argument.toCodeString(!isAllConst),
          ),
        ])) +
        (trailingComma ? ',' : '') +
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
final class CodeAndConstType {
  const CodeAndConstType(this.code, this.type);
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

@immutable
sealed class Pattern {
  const Pattern();

  String toCodeString();
}

@immutable
final class PatternStringLiteral implements Pattern {
  const PatternStringLiteral(this.items);
  final IList<StringLiteralItem> items;

  @override
  String toCodeString() => ExprStringLiteral(items).toCodeAndConstType().code;
}

@immutable
final class PatternNullLiteral implements Pattern {
  const PatternNullLiteral();

  @override
  String toCodeString() => 'null';
}

@immutable
final class PatternFinal implements Pattern {
  const PatternFinal(this.variableName);

  final String variableName;

  @override
  String toCodeString() => 'final $variableName';
}

@immutable
final class PatternWildcard implements Pattern {
  const PatternWildcard();

  @override
  String toCodeString() => '_';
}

@immutable
final class PatternObject implements Pattern {
  const PatternObject(this.className, this.namedFields);

  final String className;
  final IList<(String, Pattern)> namedFields;

  @override
  String toCodeString() =>
      className +
      '(' +
      namedFields
          .map(
            (field) => switch (field.$2) {
              PatternFinal(:final variableName) => field.$1 == variableName
                  ? ':final ' + variableName
                  : field.$1 + ': ' + field.$2.toCodeString(),
              _ => field.$1 + ': ' + field.$2.toCodeString(),
            },
          )
          .safeJoin(',') +
      ')';
}
