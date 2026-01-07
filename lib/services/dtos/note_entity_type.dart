enum NoteEntityType {
  animal,
  cage,
  mating,
  litter;

  String get value {
    switch (this) {
      case NoteEntityType.animal:
        return 'animal';
      case NoteEntityType.cage:
        return 'cage';
      case NoteEntityType.mating:
        return 'mating';
      case NoteEntityType.litter:
        return 'litter';
    }
  }
}

