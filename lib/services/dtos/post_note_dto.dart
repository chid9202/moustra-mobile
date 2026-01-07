import 'package:json_annotation/json_annotation.dart';

part 'post_note_dto.g.dart';

@JsonSerializable()
class PostNoteDto {
  final String content;

  PostNoteDto({required this.content});

  factory PostNoteDto.fromJson(Map<String, dynamic> json) =>
      _$PostNoteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostNoteDtoToJson(this);
}

