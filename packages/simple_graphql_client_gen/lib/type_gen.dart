import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_expr.dart' as wellknown_expr;
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;
import 'package:simple_graphql_client_gen/annotation.dart';
import 'package:simple_graphql_client_gen/graphql_type.dart';
import 'package:simple_graphql_client_gen/to_json.dart';

SimpleDartCode generateTypeCode(IList<GraphQLTypeDeclaration> typeList) {
  return SimpleDartCode(
    importPackageAndFileNames: const IListConst([
      ImportPackageFileNameAndAsName(
        packageAndFileName: 'package:simple_graphql_client_gen/query_string.dart',
        asName: 'query_string',
      ),
      ImportPackageFileNameAndAsName(
        packageAndFileName: 'package:narumincho_json/narumincho_json.dart',
        asName: 'narumincho_json',
      ),
      ImportPackageFileNameAndAsName(
        packageAndFileName: 'package:simple_graphql_client_gen/text.dart',
        asName: 'text',
      ),
    ]),
    declarationList: _generateDeclarationList(typeList),
  );
}

IList<Declaration> _generateDeclarationList(
  IList<GraphQLTypeDeclaration> typeList,
) {
  return typeList.mapAndRemoveNull((type) {
    if (type.name == 'String' || type.name == 'Boolean' || type.name == 'Float' || type.name == 'Int') {
      return null;
    }
    return type.body.match(
      enumFunc: (enumBody) {
        return _graphQLEnumToDartEnumDeclaration(type, enumBody);
      },
      objectFunc: (_) {
        return null;
      },
      unionFunc: (union) {
        return null;
      },
      scalerFunc: (scaler) {
        return _graphQLScalarTypeClass(type);
      },
      inputObjectFunc: (inputObject) {
        return _graphQLTypeInputObjectClass(type, inputObject);
      },
    );
  });
}

EnumDeclaration _graphQLEnumToDartEnumDeclaration(
  GraphQLTypeDeclaration type,
  GraphQLTypeBodyEnum enumBody,
) {
  return EnumDeclaration(
    name: escapeFirstUnderLine(type.name),
    implementsClassList: const IListConst([queryStringIntoQueryInput]),
    documentationComments: type.documentationComments,
    enumValues: enumBody.enumValueList,
    methods: IList([
      const Method(
        name: 'toQueryInput',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'query_string.QueryInput'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprConstructor(
            className: 'query_string.QueryInputEnum',
            isConst: false,
            positionalArguments: IListConst([ExprVariable('name')]),
          ))
        ]),
      ),
      const Method(
        name: 'toJsonValue',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'narumincho_json.JsonValue'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprConstructor(
            className: 'narumincho_json.JsonString',
            isConst: false,
            positionalArguments: IListConst([ExprVariable('name')]),
          ))
        ]),
      ),
      Method(
        name: 'fromJsonValue',
        documentationComments: '',
        useResultAnnotation: false,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'jsonValue',
            type: TypeNormal(name: 'narumincho_json.JsonValue'),
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name)),
        statements: IList([
          StatementSwitch(
            ExprMethodCall(
              variable: ExprVariable('jsonValue'),
              methodName: 'asStringOrThrow',
            ),
            IList(enumBody.enumValueList.map(
              (enumValue) => Tuple2(
                ExprStringLiteral(enumValue.name),
                IList([
                  StatementReturn(ExprEnumValue(
                    typeName: escapeFirstUnderLine(type.name),
                    valueName: enumValue.name,
                  )),
                ]),
              ),
            )),
          ),
          StatementThrow(wellknown_expr.Exception(ExprOperator(
            ExprStringLiteral('unknown Enum Value. typeName ' +
                type.name +
                '. expected ' +
                enumBody.enumValueList
                    .map(
                      (enumValue) => "'" + enumValue.name + "'",
                    )
                    .safeJoin(' or ') +
                '. but got '),
            Operator.add,
            ExprMethodCall(
              variable: ExprVariable('jsonValue'),
              methodName: 'asStringOrThrow',
            ),
          )))
        ]),
      )
    ]),
  );
}

const queryStringIntoQueryInput = 'query_string.IntoQueryInput';

ClassDeclaration? _graphQLScalarTypeClass(GraphQLTypeDeclaration type) {
  if (type.name == 'ID') {
    return ClassDeclaration(
      name: 'ID',
      documentationComments: type.documentationComments,
      fields: const IListConst([
        Field(
          name: 'value',
          documentationComments: '文字列. Int の場合もあるが, とりあえず考えない',
          type: wellknown_type.String,
          parameterPattern: ParameterPatternPositional(),
        ),
      ]),
      isAbstract: false,
      isPrivateConstructor: true,
      implementsClassList: const IListConst([queryStringIntoQueryInput]),
      methods: IList([
        const Method(
          name: 'toQueryInput',
          documentationComments: '',
          useResultAnnotation: true,
          returnType: TypeNormal(name: 'query_string.QueryInput'),
          parameters: IListConst([]),
          methodType: MethodType.override,
          statements: IListConst([
            StatementReturn(ExprCall(
              functionName: 'query_string.QueryInputString',
              positionalArguments: IListConst([ExprVariable('value')]),
            ))
          ]),
        ),
        const Method(
          name: 'toJsonValue',
          documentationComments: '',
          useResultAnnotation: true,
          returnType: TypeNormal(name: 'narumincho_json.JsonValue'),
          parameters: IListConst([]),
          methodType: MethodType.override,
          statements: IListConst([
            StatementReturn(ExprConstructor(
              className: 'narumincho_json.JsonString',
              isConst: true,
              positionalArguments: IListConst([ExprVariable('value')]),
            ))
          ]),
        ),
        Method(
          name: 'fromJsonValue',
          documentationComments: '',
          useResultAnnotation: false,
          methodType: MethodType.static,
          parameters: const IListConst([
            Parameter(
              name: 'jsonValue',
              type: TypeNormal(name: 'narumincho_json.JsonValue'),
              parameterPattern: ParameterPatternPositional(),
            )
          ]),
          returnType: TypeNormal(name: escapeFirstUnderLine(type.name)),
          statements: IList([
            StatementReturn(ExprConstructor(
              className: '${escapeFirstUnderLine(type.name)}._',
              isConst: true,
              positionalArguments: const IListConst([
                ExprMethodCall(
                  variable: ExprVariable('jsonValue'),
                  methodName: 'asStringOrThrow',
                )
              ]),
            ))
          ]),
        ),
      ]),
    );
  }
  final annotation = Annotation.fromDocumentationComments(
    type.documentationComments,
  );
  if (annotation == null) {
    return ClassDeclaration(
      name: type.name,
      documentationComments: '${type.documentationComments}\n\n内部表現が不明なスカラー値',
      fields: const IListConst([]),
      isAbstract: false,
      isPrivateConstructor: true,
      implementsClassList: const IListConst([queryStringIntoQueryInput]),
      methods: const IListConst([
        Method(
          name: 'toQueryInput',
          documentationComments: '',
          useResultAnnotation: true,
          returnType: TypeNormal(name: 'query_string.QueryInput'),
          parameters: IListConst([]),
          methodType: MethodType.override,
          statements: IListConst([
            StatementReturn(queryInputNullExprConstructor),
          ]),
        )
      ]),
    );
  }
  return annotation.match(
    dateTimeFunc: (_) => null,
    textFunc: (text) => _annotationTextClassDeclaration(type, text),
    tokenFunc: (token) => _annotationTokenClassDeclaration(type),
    uuidFunc: (token) => _annotationUuidClassDeclaration(type),
    urlFunc: (_) => null,
  );
}

ClassDeclaration _graphQLTypeInputObjectClass(
  GraphQLTypeDeclaration type,
  GraphQLTypeBodyInputObject inputObject,
) {
  final returnExpr = ExprCall(
    functionName: 'query_string.QueryInputObject',
    positionalArguments: IList([
      wellknown_expr.IList(ExprListLiteral(
        IList(inputObject.fields.map(
          (field) => ExprCall(
            functionName: 'Tuple2',
            positionalArguments: IList([
              ExprStringLiteral(field.name),
              fieldQueryInputMethodFuncReturnExpr(
                field.type,
                ExprVariable(field.type.isNullable ? getValueName(field.name) : field.name),
              ),
            ]),
          ),
        )),
      ))
    ]),
  );
  return ClassDeclaration(
    name: escapeFirstUnderLine(type.name),
    documentationComments: type.documentationComments,
    fields: IList(inputObject.fields.map(
      (field) => Field(
        name: field.name,
        documentationComments: field.description,
        parameterPattern: const ParameterPatternNamed(),
        type: field.type.toDartType(false),
      ),
    )),
    isAbstract: false,
    implementsClassList: const IListConst([queryStringIntoQueryInput]),
    methods: IList([
      Method(
        methodType: MethodType.override,
        name: 'toQueryInput',
        documentationComments: '',
        useResultAnnotation: true,
        parameters: const IListConst([]),
        returnType: const TypeNormal(name: 'query_string.QueryInput'),
        statements: IList([
          ...inputObject.fields.mapAndRemoveNull(
            (field) => field.type.isNullable
                ? StatementFinal(
                    variableName: getValueName(field.name),
                    expr: ExprVariable(field.name),
                  )
                : null,
          ),
          StatementReturn(returnExpr)
        ]),
      ),
      Method(
        name: 'toJsonValue',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: const TypeNormal(name: 'narumincho_json.JsonValue'),
        parameters: const IListConst([]),
        methodType: MethodType.override,
        statements: IList([
          ...inputObject.fields.mapAndRemoveNull(
            (field) => field.type.isNullable
                ? StatementFinal(
                    variableName: getValueName(field.name),
                    expr: ExprVariable(field.name),
                  )
                : null,
          ),
          StatementReturn(ExprConstructor(
            className: 'narumincho_json.JsonObject',
            isConst: true,
            positionalArguments: IList([
              ExprConstructor(
                className: 'IMap',
                isConst: false,
                positionalArguments: IList([
                  ExprMapLiteral(IList(
                    inputObject.fields.map(
                      (field) => Tuple2(
                        ExprStringLiteral(field.name),
                        toJsonValueExpr(
                          field.type,
                          ExprVariable(field.type.isNullable ? getValueName(field.name) : field.name),
                        ),
                      ),
                    ),
                  ))
                ]),
              )
            ]),
          ))
        ]),
      ),
    ]),
  );
}

String getValueName(String name) {
  return '${name}Value';
}

ClassDeclaration _annotationTextClassDeclaration(
  GraphQLTypeDeclaration type,
  AnnotationText text,
) {
  return ClassDeclaration(
    name: type.name,
    documentationComments: type.documentationComments,
    fields: IList([
      Field(
        name: 'value',
        documentationComments: '内部表現の文字列. 最大文字数 ${text.maxLength}',
        type: wellknown_type.String,
        parameterPattern: const ParameterPatternPositional(),
      )
    ]),
    isAbstract: false,
    isPrivateConstructor: true,
    implementsClassList: const IListConst([queryStringIntoQueryInput]),
    methods: IList([
      Method(
        name: 'fromString',
        documentationComments: 'String から 前後の空白と空白の連続を取り除き, 文字数 ${text.maxLength}文字以内の条件を満たすかバリデーションして変換する. 変換できない場合は null が返される',
        useResultAnnotation: true,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'value',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name), isNullable: true),
        statements: IList([
          StatementFinal(
            variableName: 'normalized',
            expr: ExprCall(
              functionName: 'text.textFromString',
              positionalArguments: const IListConst([ExprVariable('value')]),
              namedArguments: IList([
                Tuple2(
                  'maxLength',
                  ExprIntLiteral(text.maxLength),
                ),
              ]),
            ),
          ),
          const StatementIf(
            condition: ExprOperator(
              ExprVariable('normalized'),
              Operator.equal,
              ExprNull(),
            ),
            thenStatement: IListConst([StatementReturn(ExprNull())]),
          ),
          StatementReturn(ExprConstructor(
            className: '${escapeFirstUnderLine(type.name)}._',
            isConst: true,
            positionalArguments: const IListConst([ExprVariable('normalized')]),
          ))
        ]),
      ),
      const Method(
        name: 'toQueryInput',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'query_string.QueryInput'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprCall(
            functionName: 'query_string.QueryInputString',
            positionalArguments: IListConst([ExprVariable('value')]),
          ))
        ]),
      ),
      const Method(
        name: 'toJsonValue',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'narumincho_json.JsonValue'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprConstructor(
            className: 'narumincho_json.JsonString',
            isConst: true,
            positionalArguments: IListConst([ExprVariable('value')]),
          ))
        ]),
      ),
      Method(
        name: 'fromJsonValue',
        documentationComments: '',
        useResultAnnotation: false,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'jsonValue',
            type: TypeNormal(name: 'narumincho_json.JsonValue'),
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name)),
        statements: IList([
          StatementReturn(
            ExprConstructor(
              className: '${escapeFirstUnderLine(type.name)}._',
              isConst: true,
              positionalArguments: const IListConst([
                ExprMethodCall(
                  variable: ExprVariable('jsonValue'),
                  methodName: 'asStringOrThrow',
                )
              ]),
            ),
          )
        ]),
      ),
    ]),
  );
}

const queryInputNullExprConstructor = ExprConstructor(
  className: 'query_string.QueryInputNull',
  isConst: true,
);

ClassDeclaration _annotationTokenClassDeclaration(GraphQLTypeDeclaration type) {
  return ClassDeclaration(
    name: type.name,
    documentationComments: type.documentationComments,
    fields: const IListConst([
      Field(
        name: 'value',
        documentationComments: '内部表現の文字列. 例: `c1f6dba3586d4fcbbbe2e3edb67667e10ccb03b9ade741478fe8d656bba9a79d`',
        type: wellknown_type.String,
        parameterPattern: ParameterPatternPositional(),
      ),
    ]),
    isAbstract: false,
    isPrivateConstructor: true,
    implementsClassList: const IListConst([queryStringIntoQueryInput]),
    methods: IList([
      Method(
        name: 'fromString',
        documentationComments: 'String からバリデーションして変換する. 変換できない場合は null が返される',
        useResultAnnotation: true,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'value',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name), isNullable: true),
        statements: IList([
          const StatementFinal(
            variableName: 'normalized',
            expr: ExprMethodCall(
              variable: ExprConstructor(
                className: 'RegExp',
                isConst: false,
                positionalArguments: IListConst([ExprStringLiteral(r'^[0-9a-f]{64}$')]),
              ),
              methodName: 'stringMatch',
              positionalArguments: IListConst([ExprVariable('value')]),
            ),
          ),
          const StatementIf(
            condition: ExprOperator(
              ExprVariable('normalized'),
              Operator.equal,
              ExprNull(),
            ),
            thenStatement: IListConst([StatementReturn(ExprNull())]),
          ),
          StatementReturn(ExprConstructor(
            className: '${escapeFirstUnderLine(type.name)}._',
            isConst: true,
            positionalArguments: const IListConst([ExprVariable('normalized')]),
          ))
        ]),
      ),
      const Method(
        name: 'toQueryInput',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'query_string.QueryInput'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprCall(
            functionName: 'query_string.QueryInputString',
            positionalArguments: IListConst([ExprVariable('value')]),
          ))
        ]),
      ),
      const Method(
        name: 'toJsonValue',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'narumincho_json.JsonValue'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprConstructor(
            className: 'narumincho_json.JsonString',
            isConst: true,
            positionalArguments: IListConst([ExprVariable('value')]),
          ))
        ]),
      ),
      Method(
        name: 'fromJsonValue',
        documentationComments: '',
        useResultAnnotation: false,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'jsonValue',
            type: TypeNormal(name: 'narumincho_json.JsonValue'),
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name)),
        statements: IList([
          StatementReturn(
            ExprConstructor(
              className: '${escapeFirstUnderLine(type.name)}._',
              isConst: true,
              positionalArguments: const IListConst([
                ExprMethodCall(
                  variable: ExprVariable('jsonValue'),
                  methodName: 'asStringOrThrow',
                )
              ]),
            ),
          )
        ]),
      ),
    ]),
  );
}

ClassDeclaration _annotationUuidClassDeclaration(GraphQLTypeDeclaration type) {
  const valueName = 'value';
  const valueExpr = ExprVariable(valueName);

  return ClassDeclaration(
    name: type.name,
    documentationComments: type.documentationComments,
    fields: const IListConst([
      Field(
        name: valueName,
        documentationComments: '内部表現の文字列. 例: `25c8b0b108ad4c0f82be9a5b21ae985f`',
        type: wellknown_type.String,
        parameterPattern: ParameterPatternPositional(),
      ),
    ]),
    isAbstract: false,
    isPrivateConstructor: true,
    implementsClassList: const IListConst([queryStringIntoQueryInput]),
    methods: IList([
      Method(
        name: 'fromString',
        documentationComments: 'String からバリデーションして変換する. 変換できない場合は null が返される',
        useResultAnnotation: true,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'value',
            type: wellknown_type.String,
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name), isNullable: true),
        statements: IList([
          const StatementFinal(
            variableName: 'normalized',
            expr: ExprMethodCall(
              variable: ExprConstructor(
                className: 'RegExp',
                isConst: false,
                positionalArguments: IListConst([ExprStringLiteral(r'^[0-9a-f]{32}$')]),
              ),
              methodName: 'stringMatch',
              positionalArguments: IListConst([ExprVariable('value')]),
            ),
          ),
          const StatementIf(
            condition: ExprOperator(
              ExprVariable('normalized'),
              Operator.equal,
              ExprNull(),
            ),
            thenStatement: IListConst([StatementReturn(ExprNull())]),
          ),
          StatementReturn(ExprConstructor(
            className: '${escapeFirstUnderLine(type.name)}._',
            isConst: true,
            positionalArguments: const IListConst([ExprVariable('normalized')]),
          ))
        ]),
      ),
      const Method(
        name: 'toQueryInput',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'query_string.QueryInput'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprCall(
            functionName: 'query_string.QueryInputString',
            positionalArguments: IListConst([valueExpr]),
          ))
        ]),
      ),
      const Method(
        name: 'toJsonValue',
        documentationComments: '',
        useResultAnnotation: true,
        returnType: TypeNormal(name: 'narumincho_json.JsonValue'),
        parameters: IListConst([]),
        methodType: MethodType.override,
        statements: IListConst([
          StatementReturn(ExprConstructor(
            className: 'narumincho_json.JsonString',
            isConst: true,
            positionalArguments: IListConst([valueExpr]),
          ))
        ]),
      ),
      Method(
        name: 'fromJsonValue',
        documentationComments: '',
        useResultAnnotation: false,
        methodType: MethodType.static,
        parameters: const IListConst([
          Parameter(
            name: 'jsonValue',
            type: TypeNormal(name: 'narumincho_json.JsonValue'),
            parameterPattern: ParameterPatternPositional(),
          )
        ]),
        returnType: TypeNormal(name: escapeFirstUnderLine(type.name)),
        statements: IList([
          StatementReturn(
            ExprConstructor(
              className: '${escapeFirstUnderLine(type.name)}._',
              isConst: true,
              positionalArguments: const IListConst([
                ExprMethodCall(
                  variable: ExprVariable('jsonValue'),
                  methodName: 'asStringOrThrow',
                )
              ]),
            ),
          )
        ]),
      ),
    ]),
  );
}

Expr fieldQueryInputMethodFuncReturnExpr(
  GraphQLType type,
  Expr variableExpr,
) {
  if (type.isNullable) {
    return ExprConditionalOperator(
      ExprOperator(variableExpr, Operator.equal, const ExprNull()),
      queryInputNullExprConstructor,
      _fieldQueryInputMethodNonNullValue(type, variableExpr),
    );
  }
  return _fieldQueryInputMethodNonNullValue(type, variableExpr);
}

Expr _fieldQueryInputMethodNonNullValue(GraphQLType type, Expr variableExpr) {
  if (type.listType == ListType.list || type.listType == ListType.listItemNullable) {
    return ExprCall(
      functionName: 'query_string.QueryInputArray',
      positionalArguments: IList([
        wellknown_expr.IList(wellknown_expr.iterableMap(
          iterable: variableExpr,
          itemVariableName: 'item',
          lambdaStatements: IList([
            StatementReturn(fieldQueryInputMethodFuncReturnExpr(
              GraphQLType(
                name: type.name,
                isNullable: type.listType == ListType.listItemNullable,
                listType: ListType.notList,
              ),
              const ExprVariable('item'),
            ))
          ]),
        )),
      ]),
    );
  }
  if (type.name == 'String' && type.listType == ListType.notList) {
    return ExprCall(
      functionName: 'query_string.QueryInputString',
      positionalArguments: IList([variableExpr]),
    );
  }
  if (type.name == 'Boolean' && type.listType == ListType.notList) {
    return ExprCall(
      functionName: 'query_string.QueryInputBoolean',
      positionalArguments: IList([variableExpr]),
    );
  }
  if ((type.name == 'Float' || type.name == 'Int') && type.listType == ListType.notList) {
    return ExprCall(
      functionName: 'query_string.QueryInputNumber',
      positionalArguments: IList([variableExpr]),
    );
  }
  if (type.name == 'DateTime' && type.listType == ListType.notList) {
    return ExprCall(
      functionName: 'query_string.QueryInputDateTime',
      positionalArguments: IList([variableExpr]),
    );
  }
  return ExprMethodCall(
    variable: variableExpr,
    methodName: 'toQueryInput',
  );
}