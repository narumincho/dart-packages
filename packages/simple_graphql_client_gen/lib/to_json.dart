import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';
import 'package:simple_dart_code_gen/wellknown_expr.dart' as wellknown_expr;
import 'package:simple_graphql_client_gen/graphql_type.dart';

/// ```dart
/// narumincho_json.JsonArray(IList(expr.map((v) => v.toJsonValue())))
/// ```
Expr toJsonValueExpr(GraphQLType type, Expr variable) {
  if (type.listType == ListType.notList) {
    return _toJsonValueExprConsiderNull(
      type.isNullable,
      variable,
      _toJsonValueExprNoArray(
        type.name,
        variable,
      ),
    );
  }
  return _toJsonValueExprConsiderNull(
    type.isNullable,
    variable,
    ExprConstructor(
      className: 'narumincho_json.JsonArray',
      isConst: true,
      positionalArguments: IList([
        wellknown_expr.IList(
          wellknown_expr.iterableMap(
            iterable: variable,
            itemVariableName: 'v',
            lambdaStatements: IList([
              StatementReturn(_toJsonValueExprConsiderNull(
                type.listType == ListType.listItemNullable,
                const ExprVariable('v'),
                _toJsonValueExprNoArray(
                  type.name,
                  const ExprVariable('v'),
                ),
              )),
            ]),
          ),
        )
      ]),
    ),
  );
}

Expr _toJsonValueExprConsiderNull(
  bool isNullable,
  Expr variable,
  Expr notNullExpr,
) {
  if (isNullable) {
    return ExprConditionalOperator(
      ExprOperator(variable, Operator.equal, const ExprNull()),
      const ExprConstructor(
        className: 'narumincho_json.JsonNull',
        isConst: true,
      ),
      notNullExpr,
    );
  }
  return notNullExpr;
}

Expr _toJsonValueExprNoArray(String typeName, Expr variable) {
  if (typeName == 'String') {
    return ExprConstructor(
      className: 'narumincho_json.JsonString',
      isConst: true,
      positionalArguments: IList([variable]),
    );
  }

  if (typeName == 'Boolean') {
    return ExprConstructor(
      className: 'narumincho_json.JsonBoolean',
      isConst: true,
      positionalArguments: IList([variable]),
    );
  }

  if (typeName == 'Float') {
    return ExprConstructor(
      className: 'narumincho_json.Json64bitFloat',
      isConst: true,
      positionalArguments: IList([variable]),
    );
  }

  if (typeName == 'Int') {
    return ExprConstructor(
      className: 'narumincho_json.Json64bitFloat',
      isConst: true,
      positionalArguments:
          IList([ExprMethodCall(variable: variable, methodName: 'toDouble')]),
    );
  }

  if (typeName == 'DateTime') {
    return ExprConstructor(
      className: 'narumincho_json.Json64bitFloat',
      isConst: true,
      positionalArguments: IList([
        ExprMethodCall(
          variable:
              ExprGet(expr: variable, fieldName: 'millisecondsSinceEpoch'),
          methodName: 'toDouble',
        )
      ]),
    );
  }

  return ExprMethodCall(
    variable: variable,
    methodName: 'toJsonValue',
  );
}
