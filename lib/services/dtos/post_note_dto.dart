import 'package:json_annotation/json_annotation.dart';

part 'post_note_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class PostNoteDto {
  final String content;
  final Map<String, dynamic>? metadata;

  PostNoteDto({required this.content, this.metadata});

  factory PostNoteDto.fromJson(Map<String, dynamic> json) =>
      _$PostNoteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostNoteDtoToJson(this);
}

