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
        isAbstract: true,
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
  final Map<String, GraphQLObjectType> children = Map.fromEntries(object
      .toFieldList()
      .expand((fieldOrOn) =>
          fieldOrOn.match<List<MapEntry<String, GraphQLObjectType>>>(
            field: (field) {
              return field.return_.type.match(
                scalar: (_) => [],
                boolean: (_) => [],
                dateTime: (_) => [],
                url: (_) => [],
                string: (_) => [],
                object: (object) =>
                    collectObjectType(object.objectType).toEntryList(),
                float: (_) => [],
                int: (_) => [],
              );
            },
            on: (on) {
              return collectObjectType(on.return_).toEntryList();
            },
          )));
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
            Tuple2('uri', ExprVariable('origin')),
            Tuple2('query', ExprStringLiteral(queryCode)),
            if (variableList.isNotEmpty)
              Tuple2(
                'variables',
                ExprConstructor(
                  className: 'IMap',
                  isConst: false,
                  positionalArguments: IList([
                    ExprMapLiteral(
                      IList(variableList.map(
                        (variable) => Tuple2(
                          ExprStringLiteral(variable.name),
                          toJsonValueExpr(
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
            ExprStringLiteral(apiName + ' response data empty'),
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
    final fieldList = fieldOrList.mapAndRemoveNull(
      (fieldOrOn) => fieldOrOn.match(
        field: (field) => field,
        on: (on) => null,
      ),
    );
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
        isAbstract: false,
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
          for (final t in implementTypes)
            _matchMethodImplement(
              objectType.getTypeName(),
              t,
            ),
        ]),
      )
    ]);
  }
  return IList([
    ClassDeclaration(
      name: objectType.getTypeName(),
      documentationComments: objectType.getDescription(),
      isAbstract: true,
      fields: const IListConst([]),
      methods: IList([
        _fromJsonValueMethodUnion(objectType.getTypeName(), onList),
        _matchMethodAbstract(objectType.getTypeName(), onList),
      ]),
    )
  ]);
}

IList<QueryFieldOn> fieldOrListRemoveField(IList<QueryField> fieldOrOnList) {
  return fieldOrOnList.mapAndRemoveNull(
    (fieldOrOn) => fieldOrOn.match(
      field: (_) => null,
      on: (on) => on,
    ),
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
            (field) => Tuple2(
              field.fieldName,
              _graphQLOutputTypeToFromJsonValueExprConsiderListNull(
                field.return_,
                ExprMethodCall(
                  variable: const ExprVariable('value'),
                  methodName: 'getObjectValueOrThrow',
                  positionalArguments:
                      IList([ExprStringLiteral(field.fieldName)]),
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
            positionalArguments: IListConst([ExprStringLiteral('__typename')]),
          ),
          methodName: 'asStringOrThrow',
        ),
      ),
      StatementSwitch(
        const ExprVariable('typeName'),
        IList(
          onList.map(
            (pattern) => Tuple2(
              ExprStringLiteral(pattern.typeName),
              IList([
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
        ExprOperator(
          ExprStringLiteral(
              'invalid __typename in ' + typeName + '. __typename='),
          Operator.add,
          const ExprVariable('typeName'),
        ),
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

Method _matchMethodAbstract(String typeName, IList<QueryFieldOn> onList) {
  return Method(
    name: 'match' + typeName,
    documentationComments: 'パターンマッチング. 分岐して処理をすることができる',
    useResultAnnotation: false,
    methodType: MethodType.normal,
    statements: const IListConst([]),
    typeParameters: const IListConst(['T']),
    returnType: const TypeNormal(name: 'T'),
    parameters: _matchMethodParameters(onList),
  );
}

Method _matchMethodImplement(String typeName, GraphQLObjectType objectType) {
  final fieldOnList = fieldOrListRemoveField(objectType.toFieldList());
  final originalTypeName = fieldOnList.mapFirstNotNull(
    (fieldOn) =>
        fieldOn.return_.getTypeName() == typeName ? fieldOn.typeName : null,
  );
  if (originalTypeName == null) {
    throw Exception(
        'oneOf で元の型の名前を取得できなかった $typeName in ${objectType.getTypeName()}');
  }
  return Method(
    name: 'match' + objectType.getTypeName(),
    documentationComments: 'パターンマッチング. 分岐して処理をすることができる',
    useResultAnnotation: false,
    methodType: MethodType.override,
    typeParameters: const IListConst(['T']),
    returnType: const TypeNormal(name: 'T'),
    parameters: _matchMethodParameters(fieldOnList),
    statements: IList([
      StatementReturn(ExprCall(
        functionName: toFirstLowercase(originalTypeName),
        positionalArguments: const IListConst([ExprVariable('this')]),
      ))
    ]),
  );
}

IList<Parameter> _matchMethodParameters(IList<QueryFieldOn> onList) {
  return IList(onList.map(
    (pattern) => Parameter(
      name: toFirstLowercase(pattern.typeName),
      type: TypeFunction(
        parameters: IList([
          Tuple2(
            toFirstLowercase(pattern.return_.getTypeName()),
            TypeNormal(name: pattern.return_.getTypeName()),
          )
        ]),
        returnType: const TypeNormal(name: 'T'),
      ),
      parameterPattern: const ParameterPatternNamed(),
    ),
  ));
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
  return outputType.match(
    scalar: (scalar) => TypeNormal(name: 'type.' + scalar.typeName),
    string: (_) => wellknown_type.String,
    boolean: (_) => wellknown_type.bool,
    dateTime: (_) => wellknown_type.DateTime,
    url: (_) => wellknown_type.Uri,
    object: (object) => TypeNormal(name: object.objectType.getTypeName()),
    float: (_) => wellknown_type.double,
    int: (_) => wellknown_type.int,
  );
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
  return outputType.match(
    scalar: (scalar) => ExprCall(
      functionName: 'type.' + scalar.typeName + '.fromJsonValue',
      positionalArguments: IList([jsonValueExpr]),
    ),
    boolean: (_) => ExprMethodCall(
      variable: jsonValueExpr,
      methodName: 'asBoolOrThrow',
    ),
    string: (_) => ExprMethodCall(
      variable: jsonValueExpr,
      methodName: 'asStringOrThrow',
    ),
    dateTime: (_) => ExprConstructor(
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
    url: (_) => ExprConstructor(
      className: 'Uri.parse',
      isConst: false,
      positionalArguments: IList([
        ExprMethodCall(
          variable: jsonValueExpr,
          methodName: 'asStringOrThrow',
        ),
      ]),
    ),
    object: (object) => _graphQLObjectTypeToFromJsonValueExpr(
      object.objectType.getTypeName(),
      jsonValueExpr,
    ),
    float: (_) => ExprMethodCall(
      variable: jsonValueExpr,
      methodName: 'asDoubleOrThrow',
    ),
    int: (_) => ExprMethodCall(
      variable: ExprMethodCall(
        variable: jsonValueExpr,
        methodName: 'asDoubleOrThrow',
      ),
      methodName: 'toInt',
    ),
  );
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
