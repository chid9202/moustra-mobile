/// DTO for lab settings API (GET/PUT /lab/setting)

class LabSettingDto {
  final int? defaultRackWidth;
  final int? defaultRackHeight;
  final int? defaultWeanDate;
  final bool useEid;
  final LabSettingOwnerDto? owner;
  final String labName;

  LabSettingDto({
    this.defaultRackWidth,
    this.defaultRackHeight,
    this.defaultWeanDate,
    required this.useEid,
    this.owner,
    required this.labName,
  });

  factory LabSettingDto.fromJson(Map<String, dynamic> json) {
    return LabSettingDto(
      defaultRackWidth: json['defaultRackWidth'] as int?,
      defaultRackHeight: json['defaultRackHeight'] as int?,
      defaultWeanDate: json['defaultWeanDate'] as int?,
      useEid: json['useEid'] as bool? ?? false,
      owner: json['owner'] != null
          ? LabSettingOwnerDto.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      labName: json['labName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'defaultRackWidth': defaultRackWidth,
    'defaultRackHeight': defaultRackHeight,
    'defaultWeanDate': defaultWeanDate,
    'useEid': useEid,
    'owner': owner?.toJson(),
    'labName': labName,
  };
}

class LabSettingOwnerDto {
  final int accountId;
  final String accountUuid;
  final String accountName;
  final LabSettingUserDto user;
  final String status;
  final String role;
  final bool isActive;
  final String? position;
  final LabSettingAccountSettingDto? accountSetting;
  final bool onboarded;
  final LabSettingLabDto? lab;

  LabSettingOwnerDto({
    required this.accountId,
    required this.accountUuid,
    required this.accountName,
    required this.user,
    required this.status,
    required this.role,
    required this.isActive,
    this.position,
    this.accountSetting,
    required this.onboarded,
    this.lab,
  });

  factory LabSettingOwnerDto.fromJson(Map<String, dynamic> json) {
    return LabSettingOwnerDto(
      accountId: json['accountId'] as int? ?? 0,
      accountUuid: json['accountUuid'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      user: json['user'] != null
          ? LabSettingUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : LabSettingUserDto(
              email: '',
              firstName: '',
              lastName: '',
              isActive: true,
            ),
      status: json['status'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      position: json['position'] as String?,
      accountSetting: json['accountSetting'] != null
          ? LabSettingAccountSettingDto.fromJson(
              json['accountSetting'] as Map<String, dynamic>,
            )
          : null,
      onboarded: json['onboarded'] as bool? ?? false,
      lab: json['lab'] != null
          ? LabSettingLabDto.fromJson(json['lab'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accountId': accountId,
    'accountUuid': accountUuid,
    'accountName': accountName,
    'user': user.toJson(),
    'status': status,
    'role': role,
    'isActive': isActive,
    'position': position,
    'accountSetting': accountSetting?.toJson(),
    'onboarded': onboarded,
    'lab': lab?.toJson(),
  };
}

class LabSettingUserDto {
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  LabSettingUserDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  factory LabSettingUserDto.fromJson(Map<String, dynamic> json) {
    return LabSettingUserDto(
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'isActive': isActive,
  };
}

class LabSettingAccountSettingDto {
  final bool enableDailyReport;
  final bool onboardingTour;
  final bool animalCreationTour;
  final bool? useComment;
  final bool? enableCustomWeanDate;

  LabSettingAccountSettingDto({
    required this.enableDailyReport,
    required this.onboardingTour,
    required this.animalCreationTour,
    this.useComment,
    this.enableCustomWeanDate,
  });

  factory LabSettingAccountSettingDto.fromJson(Map<String, dynamic> json) {
    return LabSettingAccountSettingDto(
      enableDailyReport: json['enableDailyReport'] as bool? ?? false,
      onboardingTour: json['onboardingTour'] as bool? ?? false,
      animalCreationTour: json['animalCreationTour'] as bool? ?? false,
      useComment: json['useComment'] as bool?,
      enableCustomWeanDate: json['enableCustomWeanDate'] as bool?,
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

class LabSettingLabDto {
  final int labId;
  final String labUuid;
  final String labName;

  LabSettingLabDto({
    required this.labId,
    required this.labUuid,
    required this.labName,
  });

  factory LabSettingLabDto.fromJson(Map<String, dynamic> json) {
    return LabSettingLabDto(
      labId: json['labId'] as int? ?? 0,
      labUuid: json['labUuid'] as String? ?? '',
      labName: json['labName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'labId': labId,
    'labUuid': labUuid,
    'labName': labName,
  };
}
