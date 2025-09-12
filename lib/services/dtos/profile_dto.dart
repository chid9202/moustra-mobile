class ProfileRequestDto {
  final String email;
  final String firstName;
  final String lastName;

  ProfileRequestDto({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
  };
}

class ProfileResponseDto {
  final String accountUuid;
  final String firstName;
  final String lastName;
  final String email;
  final String labName;
  final String labUuid;
  final bool onboarded;
  final DateTime? onboardedDate;
  final String? position;
  final String role;
  final String plan;

  ProfileResponseDto({
    required this.accountUuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.labName,
    required this.labUuid,
    required this.onboarded,
    required this.onboardedDate,
    required this.position,
    required this.role,
    required this.plan,
  });

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return ProfileResponseDto(
      accountUuid: json['accountUuid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      labName: json['labName'] as String,
      labUuid: json['labUuid'] as String,
      onboarded: json['onboarded'] as bool,
      onboardedDate: json['onboardedDate'] != null
          ? DateTime.tryParse(json['onboardedDate'] as String)
          : null,
      position: json['position'] as String?,
      role: json['role'] as String,
      plan: json['plan'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accountUuid': accountUuid,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'labName': labName,
    'labUuid': labUuid,
    'onboarded': onboarded,
    'onboardedDate': onboardedDate?.toIso8601String(),
    'position': position,
    'role': role,
    'plan': plan,
  };
}
