class ColonySummaryDto {
  final int totalAnimals;
  final int activeCages;
  final int activeMatings;
  final int totalLitters;

  ColonySummaryDto({
    required this.totalAnimals,
    required this.activeCages,
    required this.activeMatings,
    required this.totalLitters,
  });

  factory ColonySummaryDto.fromJson(Map<String, dynamic> json) {
    return ColonySummaryDto(
      totalAnimals: (json['totalAnimals'] as int?) ?? 0,
      activeCages: (json['activeCages'] as int?) ?? 0,
      activeMatings: (json['activeMatings'] as int?) ?? 0,
      totalLitters: (json['totalLitters'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalAnimals': totalAnimals,
    'activeCages': activeCages,
    'activeMatings': activeMatings,
    'totalLitters': totalLitters,
  };
}

class LittersPerMonthDto {
  final String month;
  final int count;

  LittersPerMonthDto({required this.month, required this.count});

  factory LittersPerMonthDto.fromJson(Map<String, dynamic> json) {
    return LittersPerMonthDto(
      month: (json['month'] as String?) ?? '',
      count: (json['count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'month': month,
    'count': count,
  };
}

class BreedingPerformanceDto {
  final double? averageLitterSize;
  final double? matingSuccessRate;
  final double? medianTimeToFirstLitter;
  final double? pupSurvivalRate;
  final int activeBreedingPairs;
  final List<LittersPerMonthDto> littersPerMonth;

  BreedingPerformanceDto({
    this.averageLitterSize,
    this.matingSuccessRate,
    this.medianTimeToFirstLitter,
    this.pupSurvivalRate,
    required this.activeBreedingPairs,
    required this.littersPerMonth,
  });

  factory BreedingPerformanceDto.fromJson(Map<String, dynamic> json) {
    return BreedingPerformanceDto(
      averageLitterSize: (json['averageLitterSize'] as num?)?.toDouble(),
      matingSuccessRate: (json['matingSuccessRate'] as num?)?.toDouble(),
      medianTimeToFirstLitter:
          (json['medianTimeToFirstLitter'] as num?)?.toDouble(),
      pupSurvivalRate: (json['pupSurvivalRate'] as num?)?.toDouble(),
      activeBreedingPairs: (json['activeBreedingPairs'] as int?) ?? 0,
      littersPerMonth: (json['littersPerMonth'] as List<dynamic>? ?? [])
          .map((e) => LittersPerMonthDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'averageLitterSize': averageLitterSize,
    'matingSuccessRate': matingSuccessRate,
    'medianTimeToFirstLitter': medianTimeToFirstLitter,
    'pupSurvivalRate': pupSurvivalRate,
    'activeBreedingPairs': activeBreedingPairs,
    'littersPerMonth': littersPerMonth.map((e) => e.toJson()).toList(),
  };
}

class RecentActivityDto {
  final String type;
  final String date;
  final String description;
  final String? detail;
  final String? linkUuid;

  RecentActivityDto({
    required this.type,
    required this.date,
    required this.description,
    this.detail,
    this.linkUuid,
  });

  factory RecentActivityDto.fromJson(Map<String, dynamic> json) {
    return RecentActivityDto(
      type: (json['type'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      detail: json['detail'] as String?,
      linkUuid: json['linkUuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'date': date,
    'description': description,
    'detail': detail,
    'linkUuid': linkUuid,
  };
}

class DashboardResponseDto {
  final ColonySummaryDto? colonySummary;
  final Map<String, AccountSummaryDto> accounts;
  final List<AnimalsByAgeDto> animalByAge;
  final List<SexRatioDto> animalsSexRatio;
  final List<AnimalToWeanDto> animalsToWean;
  final BreedingPerformanceDto? breedingPerformance;
  final List<RecentActivityDto> recentActivity;

  DashboardResponseDto({
    this.colonySummary,
    required this.accounts,
    required this.animalByAge,
    required this.animalsSexRatio,
    required this.animalsToWean,
    this.breedingPerformance,
    required this.recentActivity,
  });

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) {
    final accountsJson = (json['accounts'] as Map<String, dynamic>? ?? {});
    final accounts = accountsJson.map(
      (k, v) => MapEntry(k, AccountSummaryDto.fromJson(v)),
    );
    final colonySummaryJson = json['colonySummary'] as Map<String, dynamic>?;
    final bpJson = json['breedingPerformance'] as Map<String, dynamic>?;
    return DashboardResponseDto(
      colonySummary: colonySummaryJson != null
          ? ColonySummaryDto.fromJson(colonySummaryJson)
          : null,
      accounts: accounts,
      animalByAge: (json['animalByAge'] as List<dynamic>? ?? [])
          .map((e) => AnimalsByAgeDto.fromJson(e))
          .toList(),
      animalsSexRatio: (json['animalsSexRatio'] as List<dynamic>? ?? [])
          .map((e) => SexRatioDto.fromJson(e))
          .toList(),
      animalsToWean: (json['animalsToWean'] as List<dynamic>? ?? [])
          .map((e) => AnimalToWeanDto.fromJson(e))
          .toList(),
      breedingPerformance:
          bpJson != null ? BreedingPerformanceDto.fromJson(bpJson) : null,
      recentActivity: (json['recentActivity'] as List<dynamic>? ?? [])
          .map((e) => RecentActivityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (colonySummary != null) 'colonySummary': colonySummary!.toJson(),
    'accounts': accounts.map((k, v) => MapEntry(k, v.toJson())),
    'animalByAge': animalByAge.map((e) => e.toJson()).toList(),
    'animalsSexRatio': animalsSexRatio.map((e) => e.toJson()).toList(),
    'animalsToWean': animalsToWean.map((e) => e.toJson()).toList(),
    if (breedingPerformance != null)
      'breedingPerformance': breedingPerformance!.toJson(),
    'recentActivity': recentActivity.map((e) => e.toJson()).toList(),
  };
}

class AccountSummaryDto {
  final int animalsCount;
  final int cagesCount;
  final int matingsCount;
  final int littersCount;
  final String? name;

  AccountSummaryDto({
    required this.animalsCount,
    required this.cagesCount,
    required this.matingsCount,
    required this.littersCount,
    required this.name,
  });

  factory AccountSummaryDto.fromJson(Map<String, dynamic> json) {
    return AccountSummaryDto(
      animalsCount: (json['animalsCount'] as int?) ?? 0,
      cagesCount: (json['cagesCount'] as int?) ?? 0,
      matingsCount: (json['matingsCount'] as int?) ?? 0,
      littersCount: (json['littersCount'] as int?) ?? 0,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'animalsCount': animalsCount,
    'cagesCount': cagesCount,
    'matingsCount': matingsCount,
    'littersCount': littersCount,
    'name': name,
  };
}

class AnimalsByAgeDto {
  final String strainUuid;
  final String strainName;
  final List<AgeDataPointDto> ageData;

  AnimalsByAgeDto({
    required this.strainUuid,
    required this.strainName,
    required this.ageData,
  });

  factory AnimalsByAgeDto.fromJson(Map<String, dynamic> json) {
    return AnimalsByAgeDto(
      strainUuid: (json['strainUuid'] ?? '').toString(),
      strainName: (json['strainName'] ?? '').toString(),
      ageData: (json['ageData'] as List<dynamic>? ?? [])
          .map((e) => AgeDataPointDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'strainUuid': strainUuid,
    'strainName': strainName,
    'ageData': ageData.map((e) => e.toJson()).toList(),
  };
}

class AgeDataPointDto {
  final String ageBucket;
  final int count;
  final int sortOrder;

  AgeDataPointDto({
    required this.ageBucket,
    required this.count,
    required this.sortOrder,
  });

  factory AgeDataPointDto.fromJson(Map<String, dynamic> json) {
    return AgeDataPointDto(
      ageBucket: (json['ageBucket'] as String?) ?? '',
      count: (json['count'] as int?) ?? 0,
      sortOrder: (json['sortOrder'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ageBucket': ageBucket,
    'count': count,
    'sortOrder': sortOrder,
  };
}

class SexRatioDto {
  final String? sex;
  final int count;

  SexRatioDto({required this.sex, required this.count});

  factory SexRatioDto.fromJson(Map<String, dynamic> json) {
    return SexRatioDto(
      sex: json['sex']?.toString(),
      count: (json['count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sex': sex,
    'count': count,
  };
}

class AnimalToWeanDto {
  final String physicalTag;
  final String weanDate;
  final String cageTag;

  AnimalToWeanDto({
    required this.physicalTag,
    required this.weanDate,
    required this.cageTag,
  });

  factory AnimalToWeanDto.fromJson(Map<String, dynamic> json) {
    return AnimalToWeanDto(
      physicalTag: (json['physicalTag'] ?? '').toString(),
      weanDate: (json['weanDate'] ?? '').toString(),
      cageTag: (json['cage']?['cageTag'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'physicalTag': physicalTag,
    'weanDate': weanDate,
    'cageTag': cageTag,
  };
}
