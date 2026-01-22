// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteDto _$NoteDtoFromJson(Map<String, dynamic> json) => NoteDto(
  noteUuid: json['noteUuid'] as String,
  content: json['content'] as String,
  createdDate: DateTime.parse(json['createdDate'] as String),
  createdBy: json['createdBy'] == null
      ? null
      : AccountDto.fromJson(json['createdBy'] as Map<String, dynamic>),
  updatedDate: json['updatedDate'] == null
      ? null
      : DateTime.parse(json['updatedDate'] as String),
);

Map<String, dynamic> _$NoteDtoToJson(NoteDto instance) => <String, dynamic>{
  'noteUuid': instance.noteUuid,
  'content': instance.content,
  'createdDate': instance.createdDate.toIso8601String(),
  'createdBy': instance.createdBy?.toJson(),
  'updatedDate': instance.updatedDate?.toIso8601String(),
};
