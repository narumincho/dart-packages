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
    switch (body) {
      case GraphQLTypeBodyEnum():
        return [];
      case GraphQLTypeBodyObject() && final object:
        return [
          _graphQLTypeQueryClass(type, object.fields, typeMap),
          _graphQLTypeAbstractFieldClass(type),
          for (final field in object.fields)
            _graphQLTypeFieldClass(type, field, typeMap),
        ];
      case GraphQLTypeBodyUnion() && final union:
        return [_graphQLUnionTypeQueryClass(type, union, typeMap)];
      case GraphQLTypeBodyScaler():
        return [];
      case GraphQLTypeBodyInputObject():
        return [];
    }
  }));
}

String _fieldAbstractClassName(String typeName) {
  return escapeFirstUnderLine('${typeName}_Field');
}

ClassDeclaration _graphQLTypeQueryClass(
  GraphQLTypeDeclaration type,
  IList<GraphQLField> fields,
  IMap<String, GraphQLTypeDeclaration> typeMap,
) {
  final typeName = escapeFirstUnderLine(type.name);
  return ClassDeclaration(
    name: typeName,
    documentationComments: type.documentationComments,
    fields: IList([
      const Field(
        name: 'typeName__',
        documentationComments: 'この構造の型につける型の名前. ※同じ名前で違う構造にするとエラーになるので注意!',
        type: wellknown_type.String,
        parameterPattern: ParameterPatternPositional(),
      ),
      for (final field in fields) _fieldInputField(type.name, field, typeMap),
      Field(
        name: 'extra__',
        documentationComments:
            'フィールド名を変更する場合などに使う 未実装 https://graphql.org/learn/queries/#aliases',
        type: wellknown_type.IMap(
          wellknown_type.String,
          TypeNormal(name: _fieldAbstractClassName(type.name)),
        ),
        parameterPattern: const ParameterPatternPositional(),
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
            ExprListLiteral(IList([
              ...fields.map(
                (field) => (
                  ExprSwitch(
                      ExprVariable(field.name),
                      const IListConst([
                        (PatternNullLiteral(), ExprListLiteral(IListConst([]))),
                        (
                          PatternFinal('field'),
                          ExprListLiteral(IListConst([
                            (
                              ExprMethodCall(
                                variable: ExprVariable('field'),
                                methodName: 'toField',
                              ),
                              spread: false,
                            )
                          ]))
                        ),
                      ])),
                  spread: true,
                ),
              ),
              (
                ExprMethodCall(
                  variable: const ExprVariable('extra__'),
                  methodName: 'mapTo',
                  positionalArguments: IList([
                    const ExprLambda(
                      parameterNames: IListConst(['aliasName', 'field']),
                      statements: IListConst([
                        StatementReturn(
                          ExprMethodCall(
                            variable: ExprMethodCall(
                              variable: ExprVariable('field'),
                              methodName: 'toField',
                            ),
                            methodName: 'setAliasName',
                            positionalArguments:
                                IListConst([ExprVariable('aliasName')]),
                          ),
                        ),
                      ]),
                    )
                  ]),
                ),
                spread: true,
              ),
            ])),
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
        statements: IListConst([StatementReturn(ExprVariable('typeName__'))]),
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
            (
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
              spread: false,
            ),
            ...union.possibleTypes.map(
              (possibleType) => (
                ExprCall(
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
                spread: false,
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

Field _fieldInputField(
  String typeName,
  GraphQLField field,
  IMap<String, GraphQLTypeDeclaration> typeMap,
) {
  // final fieldTypeBody = typeMap.get(field.type.name)?.body;
  return Field(
    name: field.name,
    documentationComments: field.description,
    type: TypeNormal(
        name: _fieldClassName(typeName, field.name), isNullable: true),
    parameterPattern: const ParameterPatternNamedWithDefault(ExprNull()),
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
  final bool isNeedReturn = switch (typeMap.get(field.type.name)?.body) {
    GraphQLTypeBodyEnum() => false,
    GraphQLTypeBodyObject() => true,
    GraphQLTypeBodyUnion() => true,
    GraphQLTypeBodyScaler() => false,
    GraphQLTypeBodyInputObject() => true,
    null => false,
  };

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
      name: 'query_string.QueryFieldField',
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
                    (arg) => (
                      ExprConstructor(
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
                              functionName:
                                  _fieldQueryInputMethodName(arg.name),
                            ),
                          ),
                        ]),
                      ),
                      spread: false,
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
  return _fieldMethodReturnObject(
    type.listType,
    type.isNullable,
    switch (typeData.body) {
      GraphQLTypeBodyEnum() => ExprConstructor(
          className: 'query_string.GraphQLOutputTypeNotObject',
          isConst: true,
          positionalArguments: IList([
            ExprStringLiteral(
              IListConst([StringLiteralItemNormal(typeData.name)]),
            )
          ]),
        ),
      GraphQLTypeBodyObject() => const ExprConstructor(
          className: 'query_string.GraphQLOutputTypeObject',
          isConst: true,
          positionalArguments: IListConst([ExprVariable('return_')]),
        ),
      GraphQLTypeBodyUnion() => const ExprConstructor(
          className: 'query_string.GraphQLOutputTypeObject',
          isConst: true,
          positionalArguments: IListConst([ExprVariable('return_')]),
        ),
      GraphQLTypeBodyScaler() => switch (Annotation.fromDocumentationComments(
          typeData.documentationComments,
        )) {
          null => switch (typeData.name) {
              'Boolean' => const ExprConstructor(
                  className: 'query_string.GraphQLOutputTypeBoolean',
                  isConst: true,
                ),
              'String' => const ExprConstructor(
                  className: 'query_string.GraphQLOutputTypeString',
                  isConst: true,
                ),
              'Float' => const ExprConstructor(
                  className: 'query_string.GraphQLOutputTypeFloat',
                  isConst: true,
                ),
              'Int' => const ExprConstructor(
                  className: 'query_string.GraphQLOutputTypeInt',
                  isConst: true,
                ),
              _ => _exprGraphQLOutputTypeNotObject(typeData.name),
            },
          AnnotationDateTime() => const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeDateTime',
              isConst: true,
            ),
          AnnotationText() => _exprGraphQLOutputTypeNotObject(typeData.name),
          AnnotationUrl() => const ExprConstructor(
              className: 'query_string.GraphQLOutputTypeUrl',
              isConst: true,
            ),
          AnnotationRegExp() => _exprGraphQLOutputTypeNotObject(typeData.name),
        },
      GraphQLTypeBodyInputObject() => const ExprStringLiteral(IListConst([
          StringLiteralItemNormal(
              '<error> return dose not support input object')
        ])),
    },
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
