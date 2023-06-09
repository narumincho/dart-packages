import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_expr.dart' as wellknown_expr;
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;
import 'package:simple_graphql_client_gen/annotation.dart';
import 'package:simple_graphql_client_gen/graphql_type.dart';
import 'package:simple_graphql_client_gen/type_gen.dart';

SimpleDartCode generateQueryCode(IList<GraphQLTypeDeclaration> typeList) {
  return SimpleDartCode(
    importPackageAndFileNames: const IListConst([
      ImportPackageFileNameAndAsName(
        packageAndFileName:
            'package:simple_graphql_client_gen/query_string.dart',
        asName: 'query_string',
      ),
      ImportPackageFileNameAndAsName(
        packageAndFileName:
            'package:simple_graphql_client_gen/graphql_type.dart',
        asName: 'graphql_type',
      ),
      ImportPackageFileNameAndAsName(
        packageAndFileName: './type.dart',
        asName: 'type',
      )
    ]),
    declarationList: _graphQLTypeListToQueryCode(typeList),
  );
}

IList<Declaration> _graphQLTypeListToQueryCode(
  IList<GraphQLTypeDeclaration> typeList,
) {
  final typeMap =
      IMap.fromIterable<String, GraphQLTypeDeclaration, GraphQLTypeDeclaration>(
    typeList,
    keyMapper: (t) => t.name,
    valueMapper: (t) => t,
  );
  return IList(typeList.expand((type) {
    final body = type.body;
    if (type.name == 'String' ||
        type.name == 'Boolean' ||
        type.name == 'Float' ||
        type.name == 'Int') {
      return [];
    }
    return body.match(
      enumFunc: (_) => [],
      objectFunc: (object) => [
        _graphQLTypeQueryClass(type),
        _graphQLTypeAbstractFieldClass(type),
        for (final field in object.fields)
          _graphQLTypeFieldClass(type, field, typeMap),
      ],
      unionFunc: (union) => [_graphQLUnionTypeQueryClass(type, union, typeMap)],
      scalerFunc: (_) => [],
      inputObjectFunc: (_) => [],
    );
  }));
}

String _fieldAbstractClassName(String typeName) {
  return escapeFirstUnderLine('${typeName}_Field');
}

ClassDeclaration _graphQLTypeQueryClass(GraphQLTypeDeclaration type) {
  final typeName = escapeFirstUnderLine(type.name);
  return ClassDeclaration(
    name: typeName,
    documentationComments: type.documentationComments,
    fields: IList([
      Field(
        name: 'fields',
        documentationComments: '',
        type: wellknown_type.IList(TypeNormal(
          name: _fieldAbstractClassName(type.name),
        )),
        parameterPattern: const ParameterPatternPositional(),
      ),
      Field(
        name: 'name',
        documentationComments: 'この構造の型につける型の名前. ※同じ名前で違う構造にするとエラーになるので注意!',
        type: wellknown_type.String,
        parameterPattern: ParameterPatternNamedWithDefault(
          ExprStringLiteral(IList([StringLiteralItemNormal(typeName)])),
        ),
      ),
    ]),
    modifier: ClassModifier.final_,
    implementsClassList: IList([
      if (type.type == null)
        'query_string.GraphQLObjectType'
      else
        'query_string.GraphQLRootObject',
    ]),
    methods: IList([
      Method(
        methodType: MethodType.override,
        name: 'toFieldList',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: const IListConst([]),
        returnType: wellknown_type.IList(const TypeNormal(
          name: 'query_string.QueryField',
        )),
        statements: IList([
          StatementReturn(wellknown_expr.IList(
            wellknown_expr.iterableMap(
              iterable: const ExprVariable('fields'),
              itemVariableName: 'field',
              lambdaStatements: const IListConst([
                StatementReturn(
                  ExprMethodCall(
                    variable: ExprVariable('field'),
                    methodName: 'toField',
                  ),
                ),
              ]),
            ),
          ))
        ]),
      ),
      const Method(
        methodType: MethodType.override,
        name: 'getTypeName',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: IListConst([]),
        returnType: wellknown_type.String,
        statements: IListConst([StatementReturn(ExprVariable('name'))]),
      ),
      Method(
        methodType: MethodType.override,
        name: 'getDescription',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: const IListConst([]),
        returnType: wellknown_type.String,
        statements: IList([
          StatementReturn(ExprStringLiteral(
            IList([StringLiteralItemNormal(type.documentationComments)]),
          ))
        ]),
      ),
      if (type.type != null)
        Method(
          methodType: MethodType.override,
          name: 'getRootObjectType',
          documentationComments: '',
          useResultAnnotation: true,
          returnType:
              const TypeNormal(name: 'graphql_type.GraphQLRootObjectType'),
          parameters: const IListConst([]),
          statements: IList([
            StatementReturn(
              ExprEnumValue(
                typeName: 'graphql_type.GraphQLRootObjectType',
                valueName: type.type == GraphQLRootObjectType.query
                    ? 'query'
                    : 'mutation',
              ),
            )
          ]),
        ),
    ]),
  );
}

ClassDeclaration _graphQLUnionTypeQueryClass(
  GraphQLTypeDeclaration type,
  GraphQLTypeBodyUnion union,
  IMap<String, GraphQLTypeDeclaration> typeMap,
) {
  return ClassDeclaration(
    name: type.name,
    documentationComments: type.documentationComments,
    fields: IList([
      Field(
        name: 'name',
        documentationComments:
            'この構造の型につける型の名前. ※同じ名前で違う構造にするとエラーになるので注意! ※Nameという名前の型が定義されていた場合は...想定外',
        type: wellknown_type.String,
        parameterPattern: ParameterPatternNamedWithDefault(
          ExprStringLiteral(IList([StringLiteralItemNormal(type.name)])),
        ),
      ),
      ...union.possibleTypes.map(
        (possibleType) => Field(
          name: toFirstLowercase(possibleType),
          documentationComments:
              typeMap.get(possibleType)?.documentationComments ?? '',
          type: TypeNormal(name: escapeFirstUnderLine(possibleType)),
          parameterPattern: const ParameterPatternNamed(),
        ),
      )
    ]),
    modifier: ClassModifier.final_,
    implementsClassList: const IListConst(['query_string.GraphQLObjectType']),
    methods: IList([
      Method(
        methodType: MethodType.override,
        name: 'toFieldList',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: const IListConst([]),
        returnType: wellknown_type.IList(const TypeNormal(
          name: 'query_string.QueryField',
        )),
        statements: IList([
          StatementReturn(wellknown_expr.IList(ExprListLiteral(IList([
            _queryFieldFieldExprConstructor(
              '__typename',
              description: '',
              return_: _fieldMethodReturnObject(
                ListType.notList,
                false,
                const ExprConstructor(
                  className: 'query_string.GraphQLOutputTypeString',
                  isConst: true,
                ),
              ),
            ),
            ...union.possibleTypes.map(
              (possibleType) => ExprCall(
                functionName: 'query_string.QueryFieldOn',
                namedArguments: IList([
                  (
                    name: 'typeName',
                    argument: ExprStringLiteral(
                      IList([StringLiteralItemNormal(possibleType)]),
                    ),
                  ),
                  (
                    name: 'return_',
                    argument: ExprVariable(toFirstLowercase(possibleType)),
                  ),
                ]),
              ),
            )
          ]))))
        ]),
      ),
      const Method(
        methodType: MethodType.override,
        name: 'getTypeName',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: IListConst([]),
        returnType: wellknown_type.String,
        statements: IListConst([StatementReturn(ExprVariable('name'))]),
      ),
      Method(
        methodType: MethodType.override,
        name: 'getDescription',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: const IListConst([]),
        returnType: wellknown_type.String,
        statements: IList([
          StatementReturn(ExprStringLiteral(
            IList([StringLiteralItemNormal(type.documentationComments)]),
          ))
        ]),
      ),
    ]),
  );
}

ClassDeclaration _graphQLTypeAbstractFieldClass(GraphQLTypeDeclaration type) {
  return ClassDeclaration(
    name: _fieldAbstractClassName(type.name),
    documentationComments: type.documentationComments,
    fields: const IListConst([]),
    modifier: ClassModifier.sealed,
    implementsClassList: const IListConst(['query_string.IntoGraphQLField']),
  );
}

String _fieldClassName(String typeName, String fieldName) {
  return escapeFirstUnderLine('${typeName}_$fieldName');
}

ClassDeclaration _graphQLTypeFieldClass(
  GraphQLTypeDeclaration type,
  GraphQLField field,
  IMap<String, GraphQLTypeDeclaration> typeMap,
) {
  final description =
      '${field.description}\n\ntype: `${field.type.toDartType(true).toCodeString()}`';
  final returnField = Field(
    name: 'return_',
    documentationComments: '',
    type: TypeNormal(
      name: escapeFirstUnderLine(field.type.name),
    ),
    parameterPattern: const ParameterPatternPositional(),
  );
  final bool isNeedReturn = typeMap.get(field.type.name)?.body.match(
            enumFunc: (_) => false,
            objectFunc: (_) => true,
            unionFunc: (_) => true,
            scalerFunc: (_) => false,
            inputObjectFunc: (_) => true,
          ) ??
      false;

  return ClassDeclaration(
    name: _fieldClassName(type.name, field.name),
    documentationComments: description,
    fields: IList([
      for (final arg in field.args)
        Field(
          name: arg.name,
          documentationComments: arg.description,
          type: TypeNormal(
            name: 'query_string.VariableOrStaticValue',
            arguments: IList([arg.type.toDartType(true)]),
          ),
          parameterPattern: arg.type.isNullable
              ? const ParameterPatternNamedWithDefault(
                  ExprConstructor(
                    className: 'query_string.StaticValue',
                    positionalArguments: IListConst([ExprNull()]),
                    isConst: true,
                  ),
                )
              : const ParameterPatternNamed(),
        ),
      if (isNeedReturn) returnField
    ]),
    modifier: ClassModifier.final_,
    implementsClassList: IList([_fieldAbstractClassName(type.name)]),
    methods: IList([
      _toFieldMethod(type, field, typeMap),
      ...field.args.map(
        (field) => _fieldQueryInputMethod(field),
      )
    ]),
  );
}

Method _toFieldMethod(
  GraphQLTypeDeclaration type,
  GraphQLField field,
  IMap<String, GraphQLTypeDeclaration> typeMap,
) {
  return Method(
    name: 'toField',
    documentationComments: '',
    useResultAnnotation: true,
    returnType: const TypeNormal(
      name: 'query_string.QueryField',
    ),
    parameters: const IListConst([]),
    methodType: MethodType.override,
    statements: IList([
      StatementReturn(
        _queryFieldFieldExprConstructor(
          field.name,
          description: field.description,
          args: field.args.isNotEmpty
              ? wellknown_expr.IList(ExprListLiteral(IList(
                  field.args.map(
                    (arg) => ExprConstructor(
                      className: 'query_string.QueryFieldArg',
                      isConst: false,
                      namedArguments: IList([
                        (
                          name: 'name',
                          argument: ExprStringLiteral(
                            IList([StringLiteralItemNormal(arg.name)]),
                          ),
                        ),
                        (
                          name: 'input',
                          argument: ExprCall(
                            functionName: _fieldQueryInputMethodName(arg.name),
                          ),
                        ),
                      ]),
                    ),
                  ),
                )))
              : null,
          return_: _toFieldMethodReturn(field.type, typeMap),
        ),
      )
    ]),
  );
}

Expr _queryFieldFieldExprConstructor(
  String fieldName, {
  Expr? args,
  required Expr return_,
  required String description,
}) {
  return ExprConstructor(
    className: 'query_string.QueryFieldField',
    isConst: true,
    positionalArguments: IList([
      ExprStringLiteral(IList([StringLiteralItemNormal(fieldName)]))
    ]),
    namedArguments: IList([
      if (args != null) (name: 'args', argument: args),
      (
        name: 'description',
        argument:
            ExprStringLiteral(IList([StringLiteralItemNormal(description)]))
      ),
      (name: 'return_', argument: return_),
    ]),
  );
}

Expr _toFieldMethodReturn(
  GraphQLType type,
  IMap<String, GraphQLTypeDeclaration> typeMap,
) {
  final typeData = typeMap.get(type.name);
  if (typeData == null) {
    return const ExprStringLiteral(
      IListConst([StringLiteralItemNormal('<error> type not found')]),
    );
  }
  final annotation = Annotation.fromDocumentationComments(
    typeData.documentationComments,
  );
  return _fieldMethodReturnObject(
    type.listType,
    type.isNullable,
    typeData.body.match(
      enumFunc: (_) => ExprConstructor(
        className: 'query_string.GraphQLOutputTypeNotObject',
        isConst: true,
        positionalArguments: IList([
          ExprStringLiteral(
            IListConst([StringLiteralItemNormal(typeData.name)]),
          )
        ]),
      ),
      objectFunc: (_) => const ExprConstructor(
        className: 'query_string.GraphQLOutputTypeObject',
        isConst: true,
        positionalArguments: IListConst([ExprVariable('return_')]),
      ),
      unionFunc: (_) => const ExprConstructor(
        className: 'query_string.GraphQLOutputTypeObject',
        isConst: true,
        positionalArguments: IListConst([ExprVariable('return_')]),
      ),
      scalerFunc: (scalar) {
        if (annotation == null) {
          if (typeData.name == 'Boolean') {
            return const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeBoolean',
              isConst: true,
            );
          }
          if (typeData.name == 'String') {
            return const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeString',
              isConst: true,
            );
          }
          if (typeData.name == 'Float') {
            return const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeFloat',
              isConst: true,
            );
          }
          if (typeData.name == 'Int') {
            return const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeInt',
              isConst: true,
            );
          }
          return _exprGraphQLOutputTypeNotObject(typeData.name);
        }
        return switch (annotation) {
          AnnotationDateTime() => const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeDateTime',
              isConst: true,
            ),
          AnnotationText() => _exprGraphQLOutputTypeNotObject(typeData.name),
          AnnotationToken() => _exprGraphQLOutputTypeNotObject(typeData.name),
          AnnotationUuid() => _exprGraphQLOutputTypeNotObject(typeData.name),
          AnnotationUrl() => const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeUrl',
              isConst: true,
            ),
        };
      },
      inputObjectFunc: (_) => const ExprStringLiteral(IListConst([
        StringLiteralItemNormal('<error> return dose not support input object')
      ])),
    ),
  );
}

Expr _exprGraphQLOutputTypeNotObject(String typeName) {
  return ExprConstructor(
    className: 'query_string.GraphQLOutputTypeNotObject',
    isConst: true,
    positionalArguments: IList([
      ExprStringLiteral(IListConst([StringLiteralItemNormal(typeName)]))
    ]),
  );
}

Expr _fieldMethodReturnObject(
  ListType listType,
  bool isNullable,
  Expr graphQLOutputTypeObjectExpr,
) {
  return ExprConstructor(
    className: 'query_string.GraphQLOutputTypeConsiderListNull',
    isConst: true,
    positionalArguments: IList([
      graphQLOutputTypeObjectExpr,
      ExprEnumValue(
          typeName: 'graphql_type.ListType', valueName: listType.name),
      ExprBool(isNullable),
    ]),
  );
}

Method _fieldQueryInputMethod(GraphQLInputValue field) {
  final queryInputExpr = ExprMethodCall(
    variable: ExprVariable(field.name),
    methodName: 'toQueryInput',
    namedArguments: IList([
      (name: 'type', argument: field.type.toExpr()),
      (
        name: 'staticValueToQueryInputFunc',
        argument: ExprLambda(
          parameterNames: const IListConst(['staticValue']),
          statements: IList([
            StatementReturn(fieldQueryInputMethodFuncReturnExpr(
              field.type,
              const ExprVariable('staticValue'),
            ))
          ]),
        ),
      ),
    ]),
  );

  return Method(
    name: _fieldQueryInputMethodName(field.name),
    documentationComments: '',
    useResultAnnotation: true,
    methodType: MethodType.normal,
    returnType: const TypeNormal(
      name: 'query_string.QueryInput',
    ),
    statements: IList([StatementReturn(queryInputExpr)]),
    parameters: const IListConst([]),
  );
}

String _fieldQueryInputMethodName(String fieldName) {
  return '${fieldName}ToQueryInput';
}
