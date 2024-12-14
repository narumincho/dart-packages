## 0.8.1

- In this simple_dart_code_gen, do not use dart_style code formatting.

## 0.8.0

- allow fast_immutable_collections v11. ">=10.0.0 <11.0.0" → ">=10.0.0 <12.0.0"
- update dart_style v3

## 0.7.0

- update fast_immutable_collections v9 → v10

## 0.6.1

- add IMap in wellknown

## 0.6.0

- add List spread

## 0.5.4

- add PatternObject

## 0.5.3

-

## 0.5.2

- fix switch expr output
- SimpleDartCode.toCodeString add format parameter for debug

## 0.5.1

- copyWith method use record if type is nullable `type? Function()` →
  `(type?, )?`

## 0.5.0

- add ExprSwitch
- add Pattern Type
- change type StatementSwitch Expr to Pattern

## 0.4.0

- add ExprRecord
- add TypeRecord

## 0.3.0

- support sealed class, final class (Require Dart 3)

## 0.2.2

- remove
  `ignore_for_file: prefer_interpolation_to_compose_strings, always_use_package_imports, unnecessary_parenthesis`
  (Have the user run dart fix --apply)

## 0.2.1

- fix string literal interpolation (`'$varNameNotVarName'`) →
  (`'${varName}NotVarName'`)

## 0.2.0

- fix toString() method output
- support string literal interpolation

## 0.1.0

- support function parameter name

## 0.0.2

- add output toString method

## 0.0.1

- initial release
