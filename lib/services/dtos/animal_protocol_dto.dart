import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

part 'animal_protocol_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnimalProtocolDto {
  final int? id;
  final String? animalProtocolUuid;
  final AnimalSummaryDto? animal;
  final String? animalUuid;
  final String? physicalTag;
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
    this.animalUuid,
    this.physicalTag,
    this.role,
    required this.assignedDate,
    this.removedDate,
    this.removalReason,
    this.assignedBy,
    this.notes,
  });

  /// Resolved animal UUID (prefers nested animal, falls back to top-level)
  String? get resolvedAnimalUuid => animal?.animalUuid ?? animalUuid;

  /// Resolved physical tag (prefers top-level, falls back to nested animal)
  String? get resolvedPhysicalTag => physicalTag ?? animal?.physicalTag;

  factory AnimalProtocolDto.fromJson(Map<String, dynamic> json) =>
      _$AnimalProtocolDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalProtocolDtoToJson(this);
}
