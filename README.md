# narumincho's dart-packages

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io#https://github.com/narumincho/dart-packages)

## [narumincho_util](https://github.com/narumincho/dart-packages/tree/main/packages/narumincho_util)

[![pub package](https://img.shields.io/pub/v/narumincho_util.svg)](https://pub.dev/packages/narumincho_util)

## [narumincho_json](https://github.com/narumincho/dart-packages/tree/main/packages/narumincho_json)

[![pub package](https://img.shields.io/pub/v/narumincho_json.svg)](https://pub.dev/packages/narumincho_json)

## [simple_dart_code_gen](https://github.com/narumincho/dart-packages/tree/main/packages/simple_dart_code_gen)

[![pub package](https://img.shields.io/pub/v/simple_dart_code_gen.svg)](https://pub.dev/packages/simple_dart_code_gen)

## [simple_graphql_client_gen](https://github.com/narumincho/dart-packages/tree/main/packages/simple_graphql_client_gen)

[![pub package](https://img.shields.io/pub/v/simple_graphql_client_gen.svg)](https://pub.dev/packages/simple_graphql_client_gen)

```mermaid
graph TD
narumincho_util(narumincho_util)
narumincho_json(narumincho_json)
simple_dart_code_gen(simple_dart_code_gen)
simple_graphql_client_gen(simple_graphql_client_gen)

narumincho_json --> simple_dart_code_gen --> simple_graphql_client_gen
narumincho_util --> simple_dart_code_gen
narumincho_util --> simple_graphql_client_gen

click narumincho_util "https://github.com/narumincho/dart-packages/tree/main/packages/narumincho_util"
click narumincho_json "https://github.com/narumincho/dart-packages/tree/main/packages/narumincho_json"
click simple_dart_code_gen "https://github.com/narumincho/dart-packages/tree/main/packages/simple_dart_code_gen"
click simple_graphql_client_gen "https://github.com/narumincho/dart-packages/tree/main/packages/simple_graphql_client_gen"
```

## Development

```sh
deno run ./packages/simple_graphql_client_gen_test_server/main.ts
```

### lint

```sh
dart fix --apply
```
