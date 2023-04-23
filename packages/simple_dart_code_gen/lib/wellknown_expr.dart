// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    as ic;
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';

Expr IList(Expr expr) {
  return ExprConstructor(
    className: 'IList',
    positionalArguments: ic.IList([expr]),
    isConst: false,
  );
}

Expr iterableMap({
  required Expr iterable,
  required String itemVariableName,
  required ic.IList<Statement> lambdaStatements,
}) {
  return ExprMethodCall(
    variable: iterable,
    methodName: 'map',
    positionalArguments: ic.IList([
      ExprLambda(
        parameterNames: ic.IList([itemVariableName]),
        statements: lambdaStatements,
      )
    ]),
  );
}

Expr Exception(Expr expr) {
  return ExprConstructor(
    className: 'Exception',
    isConst: false,
    positionalArguments: ic.IList([expr]),
  );
}

Expr toStringMethod(Expr value) {
  return ExprMethodCall(variable: value, methodName: 'toString');
}
