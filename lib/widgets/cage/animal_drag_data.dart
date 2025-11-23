/// Data class for drag and drop operations when moving animals between cages
class AnimalDragData {
  final String animalUuid;
  final String sourceCageUuid;

  const AnimalDragData({
    required this.animalUuid,
    required this.sourceCageUuid,
  });
}

