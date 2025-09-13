class DashboardResponseDto {
  final Map<String, AccountSummaryDto> accounts;
  final List<AnimalsByAgeDto> animalByAge;
  final List<SexRatioDto> animalsSexRatio;
  final List<AnimalToWeanDto> animalsToWean;

  DashboardResponseDto({
    required this.accounts,
    required this.animalByAge,
    required this.animalsSexRatio,
    required this.animalsToWean,
  });

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) {
    final accountsJson = (json['accounts'] as Map<String, dynamic>? ?? {});
    final accounts = accountsJson.map(
      (k, v) => MapEntry(k, AccountSummaryDto.fromJson(v)),
    );
    return DashboardResponseDto(
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
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accounts': accounts.map((k, v) => MapEntry(k, v.toJson())),
    'animalByAge': animalByAge.map((e) => e.toJson()).toList(),
    'animalsSexRatio': animalsSexRatio.map((e) => e.toJson()).toList(),
    'animalsToWean': animalsToWean.map((e) => e.toJson()).toList(),
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
  final int ageInWeeks;
  final int count;

  AgeDataPointDto({required this.ageInWeeks, required this.count});

  factory AgeDataPointDto.fromJson(Map<String, dynamic> json) {
    return AgeDataPointDto(
      ageInWeeks: (json['ageInWeeks'] as int?) ?? 0,
      count: (json['count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ageInWeeks': ageInWeeks,
    'count': count,
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
