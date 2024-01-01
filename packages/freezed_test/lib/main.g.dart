// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => _$PersonImpl(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      age: json['age'] as int,
      tags: IList<String>.fromJson(json['tags'], (value) => value as String),
      mTags: (json['mTags'] as List<dynamic>).map((e) => e as String).toList(),
      set: ISet<String>.fromJson(json['set'], (value) => value as String),
    );

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'age': instance.age,
      'tags': instance.tags.toJson(
        (value) => value,
      ),
      'mTags': instance.mTags,
      'set': instance.set.toJson(
        (value) => value,
      ),
    };
