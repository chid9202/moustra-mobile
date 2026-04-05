// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostNoteDto _$PostNoteDtoFromJson(Map<String, dynamic> json) => PostNoteDto(
  content: json['content'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PostNoteDtoToJson(PostNoteDto instance) =>
    <String, dynamic>{
      'content': instance.content,
      'metadata': ?instance.metadata,
    };
