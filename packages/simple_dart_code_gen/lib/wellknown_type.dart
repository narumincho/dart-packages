// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:fast_immutable_collections/fast_immutable_collections.dart' as ic;
import 'package:simple_dart_code_gen/simple_dart_code_gen.dart';

const Type String = TypeNormal(name: 'String');

const Type bool = TypeNormal(name: 'bool');

const Type double = TypeNormal(name: 'double');

const Type int = TypeNormal(name: 'int');

const Type DateTime = TypeNormal(name: 'DateTime');

const Type Uri = TypeNormal(name: 'Uri');

Type IList(Type itemType) {
  return TypeNormal(name: 'IList', arguments: ic.IList([itemType]));
}
