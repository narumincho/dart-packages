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
