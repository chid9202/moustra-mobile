/// DTO for combined settings API (GET /setting)
/// Contains both account and lab settings

class SettingDto {
  final AccountSettingDto accountSetting;
  final LabSettingStoreDto labSetting;

  SettingDto({
    required this.accountSetting,
    required this.labSetting,
  });

  factory SettingDto.fromJson(Map<String, dynamic> json) {
    return SettingDto(
      accountSetting: json['accountSetting'] != null
          ? AccountSettingDto.fromJson(
              json['accountSetting'] as Map<String, dynamic>)
          : AccountSettingDto(
              enableDailyReport: false,
              onboardingTour: false,
              animalCreationTour: false,
              useComment: true,
              enableCustomWeanDate: true,
            ),
      labSetting: json['labSetting'] != null
          ? LabSettingStoreDto.fromJson(
              json['labSetting'] as Map<String, dynamic>)
          : LabSettingStoreDto(
              defaultRackWidth: 18,
              defaultRackHeight: 12,
              defaultWeanDate: 21,
              useEid: false,
            ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'accountSetting': accountSetting.toJson(),
        'labSetting': labSetting.toJson(),
      };
}

class AccountSettingDto {
  final bool enableDailyReport;
  final bool onboardingTour;
  final bool animalCreationTour;
  final bool useComment;
  final bool enableCustomWeanDate;

  AccountSettingDto({
    required this.enableDailyReport,
    required this.onboardingTour,
    required this.animalCreationTour,
    required this.useComment,
    required this.enableCustomWeanDate,
  });

  factory AccountSettingDto.fromJson(Map<String, dynamic> json) {
    return AccountSettingDto(
      enableDailyReport: json['enableDailyReport'] as bool? ?? false,
      onboardingTour: json['onboardingTour'] as bool? ?? false,
      animalCreationTour: json['animalCreationTour'] as bool? ?? false,
      useComment: json['useComment'] as bool? ?? true,
      enableCustomWeanDate: json['enableCustomWeanDate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'enableDailyReport': enableDailyReport,
        'onboardingTour': onboardingTour,
        'animalCreationTour': animalCreationTour,
        'useComment': useComment,
        'enableCustomWeanDate': enableCustomWeanDate,
      };
}

class LabSettingStoreDto {
  final int defaultRackWidth;
  final int defaultRackHeight;
  final int defaultWeanDate;
  final bool useEid;

  LabSettingStoreDto({
    required this.defaultRackWidth,
    required this.defaultRackHeight,
    required this.defaultWeanDate,
    required this.useEid,
  });

  factory LabSettingStoreDto.fromJson(Map<String, dynamic> json) {
    return LabSettingStoreDto(
      defaultRackWidth: json['defaultRackWidth'] as int? ?? 18,
      defaultRackHeight: json['defaultRackHeight'] as int? ?? 12,
      defaultWeanDate: json['defaultWeanDate'] as int? ?? 21,
      useEid: json['useEid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'defaultRackWidth': defaultRackWidth,
        'defaultRackHeight': defaultRackHeight,
        'defaultWeanDate': defaultWeanDate,
        'useEid': useEid,
      };
}








