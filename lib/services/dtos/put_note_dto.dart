import 'package:json_annotation/json_annotation.dart';

part 'put_note_dto.g.dart';

@JsonSerializable()
class PutNoteDto {
  final String content;

  PutNoteDto({required this.content});

  factory PutNoteDto.fromJson(Map<String, dynamic> json) =>
      _$PutNoteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutNoteDtoToJson(this);
}

