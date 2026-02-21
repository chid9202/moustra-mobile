import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

part 'animal_protocol_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnimalProtocolDto {
  final int? id;
  final String? animalProtocolUuid;
  final AnimalSummaryDto? animal;
  final String? role;
  final String assignedDate;
  final String? removedDate;
  final String? removalReason;
  final AccountDto? assignedBy;
  final String? notes;

  AnimalProtocolDto({
    this.id,
    this.animalProtocolUuid,
    this.animal,
    this.role,
    required this.assignedDate,
    this.removedDate,
    this.removalReason,
    this.assignedBy,
    this.notes,
  });

  factory AnimalProtocolDto.fromJson(Map<String, dynamic> json) =>
      _$AnimalProtocolDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalProtocolDtoToJson(this);
}
