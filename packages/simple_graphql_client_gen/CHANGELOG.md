## 0.9.2

- same type name error output structure in error message

## 0.9.1

- fix error in GraphQLError path include int

## 0.9.0

- query extra__ field Positional → Named
- Update fast_immutable_collections v10

## 0.8.0

- Delete id and token annotation support
- Easier to specify query
- Support Alias

## 0.7.9

- Fix regexp type fromString method. Returns null instead of throwing an error
  when the regular expression is not satisfied

## 0.7.8

- fix RegExp fromString method

## 0.7.7

- fix _annotationRegExpClassDeclaration

## 0.7.6

- rename regex → regexp

## 0.7.5

- add Regex type

## 0.7.4

- rename origin → url

## 0.7.3

- Object Type fromJson use switch expr

## 0.7.2

- fix collectVariableInQueryField
- Revert Union Type fromJsonValue use switch

## 0.7.1

- Union Type fromJsonValue use switch

## 0.7.0

- type_gen use switch expr
- update simple_dart_code_gen ^0.5.1

## 0.6.1

- use IMap in QueryInputObject

## 0.6.0

- override GraphqlError.toString(), GraphqlErrors.toString()

## 0.5.0

- to throw multiple errors instead of just one
- add path, extensionsCode in GraphQLError
- GraphQL API function auth parameter allow null

## 0.4.0

- Support Authorization Header

## 0.3.0

- Remove output of match method. Please use switch expressions from now on.

## 0.2.4

- fix `List<Type>?` toJsonValue method output

## 0.2.3

- fix. allow IntoGraphQLField, IntoQueryInput implements

## 0.2.2

- fix. allow GraphQLRootObject, GraphQLObjectType implements

## 0.2.1

- accept http 0.13.6 for google_sign_in

## 0.2.0

- update http to ^1.0.0

## 0.1.0

- output final class, sealed class (Require Dart 3)

## 0.0.3

- fix toString method output

## 0.0.2

- use function type parameter name

## 0.0.1

- initial release
