import 'package:json_annotation/json_annotation.dart';

part 'put_note_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class PutNoteDto {
  final String content;
  final Map<String, dynamic>? metadata;

  PutNoteDto({required this.content, this.metadata});

  factory PutNoteDto.fromJson(Map<String, dynamic> json) =>
      _$PutNoteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutNoteDtoToJson(this);
}

