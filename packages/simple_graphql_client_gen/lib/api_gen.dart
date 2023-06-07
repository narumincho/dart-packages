// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:narumincho_util/narumincho_util.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_expr.dart' as wellknown_expr;
import 'package:simple_dart_code_gen/wellknown_type.dart' as wellknown_type;
import 'package:simple_graphql_client_gen/graphql_type.dart';
import 'package:simple_graphql_client_gen/query_string.dart';
import 'package:simple_graphql_client_gen/to_json.dart';

SimpleDartCode generateApiCode(IMap<String, GraphQLRootObject> apiMap) {
  // 同じ型の名前で構造が同じものかどうか調べるために Map を使う
  final objectTypeList = apiMap.values.expand(
    (element) => collectObjectType(element).toEntryList(),
  );
  final objectTypeMapMut = Map<String, GraphQLObjectType>();
  for (final objectType in objectTypeList) {
    final mapValue = objectTypeMapMut[objectType.key];
    if (mapValue == null) {
      objectTypeMapMut[objectType.key] = objectType.value;
    } else {
      if (mapValue != objectType.value) {
        throw Exception('同じ型の名前なのに構造が違う ${objectType.key}');
      }
    }
  }
  final objectTypeMap = objectTypeMapMut.lock;

  return SimpleDartCode(
    importPackageAndFileNames: IList([
      const ImportPackageFileNameAndAsName(
        packageAndFileName:
            'package:simple_graphql_client_gen/graphql_post.dart',
        asName: 'graphql_post',
      ),
      const ImportPackageFileNameAndAsName(
        packageAndFileName: 'package:narumincho_json/narumincho_json.dart',
        asName: 'narumincho_json',
      ),
      const ImportPackageFileNameAndAsName(
        packageAndFileName: './type.dart',
        asName: 'type',
      ),
    ]),
    declarationList: IList([
      ClassDeclaration(
        name: 'Api',
        documentationComments: 'APIを呼ぶ',
        fields: const IListConst([]),
        modifier: ClassModifier.abstract,
        methods: IList(
          apiMap.mapTo(
            (apiName, objectType) => _createApiCallMethod(
              apiName,
              objectType,
            ),
          ),
        ),
      ),
      for (final objectType in objectTypeMap.values)
        ..._objectTypeClassDeclaration(
          objectType,
          IList(objectTypeMap.values),
        )
    ]),
  );
}

IMap<String, GraphQLObjectType> collectObjectType(GraphQLObjectType object) {
  // フラットにする
  final Map<String, GraphQLObjectType> children = Map.fromEntries(
    object.toFieldList().expand((fieldOrOn) => switch (fieldOrOn) {
          QueryFieldField(:final return_) => switch (return_.type) {
              GraphQLOutputTypeObject(:final objectType) =>
                collectObjectType(objectType).toEntryList(),
              _ => [],
            },
          // Dart 3.0.2 bug https://github.com/dart-lang/sdk/issues/52151
          // ignore: unreachable_switch_case
          QueryFieldOn(:final return_) =>
            collectObjectType(return_).toEntryList(),
        }),
  );
  return IMap({object.getTypeName(): object, ...children});
}

Method _createApiCallMethod(
  String apiName,
  GraphQLRootObject objectType,
) {
  final variableList = collectVariableInQueryFieldList(objectType);
  final queryCode = queryFieldListToString(
    objectType,
    objectType.getRootObjectType(),
  );
  return Method(
    name: apiName,
    isAsync: true,
    documentationComments: '```\n' + queryCode + '```',
    useResultAnnotation: false,
    returnType: TypeNormal(
      name: 'Future',
      arguments: IList([TypeNormal(name: objectType.getTypeName())]),
    ),
    parameters: IList(
      [
        Parameter(
          name: 'origin',
          type: wellknown_type.Uri,
          parameterPattern: const ParameterPatternPositional(),
        ),
        ...variableList.map(
          (variable) => Parameter(
            name: variable.name,
            type: variable.type.toDartType(true),
            parameterPattern: const ParameterPatternNamed(),
          ),
        )
      ],
    ),
    methodType: MethodType.static,
    statements: IList([
      StatementFinal(
        variableName: 'response',
        expr: ExprCall(
          functionName: 'graphql_post.graphQLPost',
          namedArguments: IList([
            (name: 'uri', argument: ExprVariable('origin')),
            (
              name: 'query',
              argument: ExprStringLiteral(
                  IList([StringLiteralItemNormal(queryCode)])),
            ),
            if (variableList.isNotEmpty)
              (
                name: 'variables',
                argument: ExprConstructor(
                  className: 'IMap',
                  isConst: false,
                  positionalArguments: IList([
                    ExprMapLiteral(
                      IList(variableList.map(
                        (variable) => (
                          key: ExprStringLiteral(
                            IList([StringLiteralItemNormal(variable.name)]),
                          ),
                          value: toJsonValueExpr(
                              variable.type, ExprVariable(variable.name)),
                        ),
                      )),
                    )
                  ]),
                ),
              ),
          ]),
          isAwait: true,
        ),
      ),
      StatementFinal(
        variableName: 'error',
        expr: ExprGet(
          expr: ExprGet(expr: ExprVariable('response'), fieldName: 'errors'),
          fieldName: 'firstOrNull',
        ),
      ),
      StatementIf(
        condition: const ExprOperator(
            ExprVariable('error'), Operator.notEqual, ExprNull()),
        thenStatement: IList([
          StatementThrow(ExprVariable('error')),
        ]),
      ),
      StatementFinal(
        variableName: 'data',
        expr: ExprGet(expr: ExprVariable('response'), fieldName: 'data'),
      ),
      StatementIf(
        condition: const ExprOperator(
            ExprVariable('data'), Operator.equal, ExprNull()),
        thenStatement: IList([
          StatementThrow(wellknown_expr.Exception(
            ExprStringLiteral(
              IList(
                  [StringLiteralItemNormal(apiName + ' response data empty')]),
            ),
          )),
        ]),
      ),
      StatementReturn(
        _graphQLObjectTypeToFromJsonValueExpr(
          objectType.getTypeName(),
          const ExprVariable('data'),
        ),
      ),
    ]),
  );
}

IList<ClassDeclaration> _objectTypeClassDeclaration(
  GraphQLObjectType objectType,
  IList<GraphQLObjectType> allObjectType,
) {
  final fieldOrList = objectType.toFieldList();
  final onList = fieldOrListRemoveField(fieldOrList);
  if (onList.isEmpty) {
    final fieldList =
        fieldOrList.mapAndRemoveNull((fieldOrOn) => switch (fieldOrOn) {
              QueryFieldField() && final field => field,
              QueryFieldOn() => null,
            });
    final implementTypes = allObjectType.mapAndRemoveNull((o) {
      final oPossibleType = fieldOrListRemoveField(o.toFieldList());
      if (oPossibleType.isEmpty) {
        return null;
      }
      for (final element in oPossibleType) {
        if (element.return_.getTypeName() == objectType.getTypeName()) {
          return o;
        }
      }
      return null;
    });
    return IList([
      ClassDeclaration(
        name: objectType.getTypeName(),
        documentationComments: objectType.getDescription(),
        implementsClassList: IList(implementTypes.map((t) => t.getTypeName())),
        modifier: ClassModifier.final_,
        fields: IList(fieldList.map(
          (field) => Field(
            name: field.fieldName,
            documentationComments: field.description,
            type: _graphQLOutputTypeToStringToDartTypeConsiderListNull(
                field.return_),
            parameterPattern: const ParameterPatternNamed(),
          ),
        )),
        methods: IList([
          _fromJsonValueMethodObject(objectType.getTypeName(), fieldList),
        ]),
      )
    ]);
  }
  return IList([
    ClassDeclaration(
      name: objectType.getTypeName(),
      documentationComments: objectType.getDescription(),
      modifier: ClassModifier.sealed,
      fields: const IListConst([]),
      methods: IList([
        _fromJsonValueMethodUnion(objectType.getTypeName(), onList),
      ]),
    )
  ]);
}

IList<QueryFieldOn> fieldOrListRemoveField(IList<QueryField> fieldOrOnList) {
  return fieldOrOnList.mapAndRemoveNull<QueryFieldOn>(
    (fieldOrOn) => switch (fieldOrOn) {
      QueryFieldOn() && final on => on,
      QueryFieldField() => null,
    },
  );
}

Method _fromJsonValueMethodObject(
    String typeName, IList<QueryFieldField> fieldList) {
  return _fromJsonValueMethod(
    typeName,
    IList([
      StatementReturn(
        ExprConstructor(
          className: typeName,
          isConst: true,
          namedArguments: IList(fieldList.map(
            (field) => (
              name: field.fieldName,
              argument: _graphQLOutputTypeToFromJsonValueExprConsiderListNull(
                field.return_,
                ExprMethodCall(
                  variable: const ExprVariable('value'),
                  methodName: 'getObjectValueOrThrow',
                  positionalArguments: IList([
                    ExprStringLiteral(
                      IList([StringLiteralItemNormal(field.fieldName)]),
                    )
                  ]),
                ),
              ),
            ),
          )),
        ),
      )
    ]),
  );
}

Method _fromJsonValueMethodUnion(String typeName, IList<QueryFieldOn> onList) {
  return _fromJsonValueMethod(
    typeName,
    IList([
      const StatementFinal(
        variableName: 'typeName',
        expr: ExprMethodCall(
          variable: ExprMethodCall(
            variable: ExprVariable('value'),
            methodName: 'getObjectValueOrThrow',
            positionalArguments: IListConst([
              ExprStringLiteral(
                IListConst([StringLiteralItemNormal('__typename')]),
              )
            ]),
          ),
          methodName: 'asStringOrThrow',
        ),
      ),
      StatementSwitch(
        const ExprVariable('typeName'),
        IList(
          onList.map(
            (pattern) => (
              case_: ExprStringLiteral(
                IList([StringLiteralItemNormal(pattern.typeName)]),
              ),
              statements: IList([
                StatementReturn(
                  _graphQLObjectTypeToFromJsonValueExpr(
                    pattern.return_.getTypeName(),
                    const ExprVariable('value'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
      StatementThrow(wellknown_expr.Exception(
        ExprStringLiteral(IList([
          StringLiteralItemNormal(
              'invalid __typename in ' + typeName + '. __typename='),
          const StringLiteralItemInterpolation(ExprVariable('typeName')),
        ])),
      ))
    ]),
  );
}

Method _fromJsonValueMethod(String typeName, IList<Statement> statementList) {
  return Method(
    name: 'fromJsonValue',
    methodType: MethodType.static,
    documentationComments:
        'JsonValue から ' + typeName + 'を生成する. 失敗した場合はエラーが発生する',
    useResultAnnotation: false,
    parameters: const IListConst([
      Parameter(
        name: 'value',
        type: TypeNormal(name: 'narumincho_json.JsonValue'),
        parameterPattern: ParameterPatternPositional(),
      )
    ]),
    returnType: TypeNormal(name: typeName),
    statements: statementList,
  );
}

Type _graphQLOutputTypeToStringToDartTypeConsiderListNull(
  GraphQLOutputTypeConsiderListNull outputType,
) {
  switch (outputType.listType) {
    case ListType.list:
      return wellknown_type.IList(
        _graphQLOutputTypeToStringToDartType(
          outputType.type,
        ).setIsNullable(false),
      ).setIsNullable(outputType.isNullable);
    case ListType.listItemNullable:
      return wellknown_type.IList(
        _graphQLOutputTypeToStringToDartType(
          outputType.type,
        ).setIsNullable(true),
      ).setIsNullable(outputType.isNullable);
    case ListType.notList:
      return _graphQLOutputTypeToStringToDartType(
        outputType.type,
      ).setIsNullable(outputType.isNullable);
  }
}

Type _graphQLOutputTypeToStringToDartType(GraphQLOutputType outputType) {
  return switch (outputType) {
    GraphQLOutputTypeNotObject(:final typeName) =>
      TypeNormal(name: 'type.' + typeName),
    GraphQLOutputTypeString() => wellknown_type.String,
    GraphQLOutputTypeBoolean() => wellknown_type.bool,
    GraphQLOutputTypeDateTime() => wellknown_type.DateTime,
    GraphQLOutputTypeUrl() => wellknown_type.Uri,
    // Dart 3.0.2 bug https://github.com/dart-lang/sdk/issues/52151
    // ignore: unreachable_switch_case
    GraphQLOutputTypeObject(:final objectType) =>
      TypeNormal(name: objectType.getTypeName()),
    GraphQLOutputTypeFloat() => wellknown_type.double,
    GraphQLOutputTypeInt() => wellknown_type.int,
  };
}

Expr _graphQLOutputTypeToFromJsonValueExprConsiderListNull(
  GraphQLOutputTypeConsiderListNull outputType,
  Expr jsonValueExpr,
) {
  switch (outputType.listType) {
    case ListType.list:
      return ExprMethodCall(
        variable: jsonValueExpr,
        methodName: 'asArrayOrThrow',
        positionalArguments: IList([
          ExprLambda(
            parameterNames: const IListConst(['v']),
            statements: IList([
              StatementReturn(_graphQLOutputTypeToFromJsonValueExprConsiderNull(
                outputType.type,
                false,
                const ExprVariable('v'),
              ))
            ]),
          )
        ]),
      );
    case ListType.listItemNullable:
      return ExprMethodCall(
        variable: jsonValueExpr,
        methodName: 'asArrayOrThrow',
        positionalArguments: IList([
          ExprLambda(
            parameterNames: const IListConst(['v']),
            statements: IList([
              StatementReturn(_graphQLOutputTypeToFromJsonValueExprConsiderNull(
                outputType.type,
                true,
                const ExprVariable('v'),
              ))
            ]),
          )
        ]),
      );
    case ListType.notList:
      return _graphQLOutputTypeToFromJsonValueExprConsiderNull(
        outputType.type,
        outputType.isNullable,
        jsonValueExpr,
      );
  }
}

Expr _graphQLOutputTypeToFromJsonValueExprConsiderNull(
  GraphQLOutputType outputType,
  bool isNull,
  Expr jsonValueExpr,
) {
  if (isNull) {
    return ExprConditionalOperator(
      ExprMethodCall(variable: jsonValueExpr, methodName: 'isNull'),
      const ExprNull(),
      _graphQLOutputTypeToFromJsonValueExpr(outputType, jsonValueExpr),
    );
  }
  return _graphQLOutputTypeToFromJsonValueExpr(outputType, jsonValueExpr);
}

Expr _graphQLOutputTypeToFromJsonValueExpr(
  GraphQLOutputType outputType,
  Expr jsonValueExpr,
) {
  return switch (outputType) {
    GraphQLOutputTypeNotObject(:final typeName) => ExprCall(
        functionName: 'type.' + typeName + '.fromJsonValue',
        positionalArguments: IList([jsonValueExpr]),
      ),
    GraphQLOutputTypeBoolean() => ExprMethodCall(
        variable: jsonValueExpr,
        methodName: 'asBoolOrThrow',
      ),
    GraphQLOutputTypeString() => ExprMethodCall(
        variable: jsonValueExpr,
        methodName: 'asStringOrThrow',
      ),
    GraphQLOutputTypeDateTime() => ExprConstructor(
        className: 'DateTime.fromMillisecondsSinceEpoch',
        isConst: false,
        positionalArguments: IList([
          ExprMethodCall(
            variable: ExprMethodCall(
              variable: jsonValueExpr,
              methodName: 'asDoubleOrThrow',
            ),
            methodName: 'floor',
          )
        ]),
      ),
    GraphQLOutputTypeUrl() => ExprConstructor(
        className: 'Uri.parse',
        isConst: false,
        positionalArguments: IList([
          ExprMethodCall(
            variable: jsonValueExpr,
            methodName: 'asStringOrThrow',
          ),
        ]),
      ),
    // Dart 3.0.2 bug https://github.com/dart-lang/sdk/issues/52151
    // ignore: unreachable_switch_case
    GraphQLOutputTypeObject(:final objectType) =>
      _graphQLObjectTypeToFromJsonValueExpr(
        objectType.getTypeName(),
        jsonValueExpr,
      ),
    GraphQLOutputTypeFloat() => ExprMethodCall(
        variable: jsonValueExpr,
        methodName: 'asDoubleOrThrow',
      ),
    GraphQLOutputTypeInt() => ExprMethodCall(
        variable: ExprMethodCall(
          variable: jsonValueExpr,
          methodName: 'asDoubleOrThrow',
        ),
        methodName: 'toInt',
      ),
  };
}

Expr _graphQLObjectTypeToFromJsonValueExpr(
  String objectTypeName,
  Expr jsonValueExpr,
) {
  return ExprCall(
    functionName: objectTypeName + '.fromJsonValue',
    positionalArguments: IList([jsonValueExpr]),
  );
}
