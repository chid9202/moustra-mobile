// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutNoteDto _$PutNoteDtoFromJson(Map<String, dynamic> json) => PutNoteDto(
  content: json['content'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PutNoteDtoToJson(PutNoteDto instance) =>
    <String, dynamic>{
      'content': instance.content,
      'metadata': ?instance.metadata,
    };
