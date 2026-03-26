import 'package:moustra/services/dtos/rack_dto.dart';

const double estimatedCageCostPerDay = 0.83;

class RackGridPosition {
  final int x;
  final int y;
  const RackGridPosition({required this.x, required this.y});
}

class RackCageWithPosition {
  final RackCageDto cage;
  final RackGridPosition? position;
  final String positionLabel;
  const RackCageWithPosition({
    required this.cage,
    required this.position,
    required this.positionLabel,
  });
}

class RackInsights {
  final int occupiedCages;
  final int totalAnimals;
  final int totalPositions;
  final int emptyPositions;
  final double utilizationPct;
  final double estimatedDailyCost;
  final double estimatedWeeklyCost;

  const RackInsights({
    required this.occupiedCages,
    required this.totalAnimals,
    required this.totalPositions,
    required this.emptyPositions,
    required this.utilizationPct,
    required this.estimatedDailyCost,
    required this.estimatedWeeklyCost,
  });
}

String getRackPositionLabel(RackGridPosition? position) {
  if (position == null) return '';

  // Convert row index to letter(s): 0→A, 25→Z, 26→AA, 27→AB, etc.
  var row = position.y;
  var letters = '';
  do {
    letters = String.fromCharCode(65 + (row % 26)) + letters;
    row = row ~/ 26 - 1;
  } while (row >= 0);

  return '$letters${position.x + 1}';
}

int getRackTotalPositions(int rackWidth, int rackHeight) {
  if (rackWidth <= 0 || rackHeight <= 0) return 0;
  return rackWidth * rackHeight;
}

RackGridPosition? _getFallbackPosition(int index, int rackWidth, int rackHeight) {
  final totalPositions = getRackTotalPositions(rackWidth, rackHeight);
  if (rackWidth <= 0 || index < 0 || index >= totalPositions) return null;
  return RackGridPosition(
    x: index % rackWidth,
    y: index ~/ rackWidth,
  );
}

List<RackCageWithPosition> getRackCagesWithPosition(
  List<RackCageDto> cages,
  int rackWidth,
  int rackHeight,
) {
  final hasPositionData = cages.any(
    (cage) => cage.xPosition != null && cage.yPosition != null,
  );

  final sortedCages = List<RackCageDto>.from(cages)
    ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

  return sortedCages.asMap().entries.map((entry) {
    final index = entry.key;
    final cage = entry.value;

    RackGridPosition? position;
    if (hasPositionData) {
      if (cage.xPosition != null && cage.yPosition != null) {
        position = RackGridPosition(x: cage.xPosition!, y: cage.yPosition!);
      }
    } else {
      position = _getFallbackPosition(index, rackWidth, rackHeight);
    }

    return RackCageWithPosition(
      cage: cage,
      position: position,
      positionLabel: getRackPositionLabel(position),
    );
  }).toList();
}

RackInsights getRackInsights(RackDto? rack) {
  final occupiedCages = rack?.cages?.length ?? 0;
  final totalAnimals = rack?.cages?.fold<int>(
        0,
        (sum, cage) => sum + (cage.animals?.length ?? 0),
      ) ??
      0;
  final totalPositions = getRackTotalPositions(
    rack?.rackWidth ?? 0,
    rack?.rackHeight ?? 0,
  );
  final emptyPositions = (totalPositions - occupiedCages).clamp(0, totalPositions);
  final utilizationPct =
      totalPositions > 0 ? (occupiedCages / totalPositions) * 100 : 0.0;
  final estimatedDailyCost = occupiedCages * estimatedCageCostPerDay;
  final estimatedWeeklyCost = estimatedDailyCost * 7;

  return RackInsights(
    occupiedCages: occupiedCages,
    totalAnimals: totalAnimals,
    totalPositions: totalPositions,
    emptyPositions: emptyPositions,
    utilizationPct: utilizationPct,
    estimatedDailyCost: estimatedDailyCost,
    estimatedWeeklyCost: estimatedWeeklyCost,
  );
}

/// Get owner display name from RackCageOwnerDto
String getOwnerName(RackCageOwnerDto? owner) {
  if (owner == null) return '-';
  final user = owner.user;
  if (user == null) return '-';
  final firstName = user['first_name'] ?? user['firstName'] ?? '';
  final lastName = user['last_name'] ?? user['lastName'] ?? '';
  final full = '$firstName $lastName'.trim();
  if (full.isNotEmpty) return full;
  final email = user['email'] ?? '';
  if (email is String && email.isNotEmpty) return email;
  return '-';
}
