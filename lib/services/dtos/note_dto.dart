import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';

part 'note_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class NoteDto {
  final String noteUuid;
  final String content;
  final DateTime createdDate;
  final AccountDto? createdBy;
  final DateTime? updatedDate;

  NoteDto({
    required this.noteUuid,
    required this.content,
    required this.createdDate,
    this.createdBy,
    this.updatedDate,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDtoToJson(this);
}
