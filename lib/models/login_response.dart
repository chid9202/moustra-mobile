class LoginResponse {
  final String accountUuid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? labName;
  final String? labUuid;
  final String token;
  final bool onboarded;
  final String? onboardedDate;
  final String? position;
  final String? role;
  final String? plan;

  LoginResponse({
    required this.accountUuid,
    required this.email,
    this.firstName,
    this.lastName,
    this.labName,
    this.labUuid,
    required this.token,
    required this.onboarded,
    this.onboardedDate,
    this.position,
    this.role,
    this.plan,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accountUuid: json['accountUuid'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      labName: json['labName'] as String?,
      labUuid: json['labUuid'] as String?,
      token: json['token'] as String,
      onboarded: json['onboarded'] as bool? ?? false,
      onboardedDate: json['onboardedDate'] as String?,
      position: json['position'] as String?,
      role: json['role'] as String?,
      plan: json['plan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountUuid': accountUuid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'labName': labName,
      'labUuid': labUuid,
      'token': token,
      'onboarded': onboarded,
      'onboardedDate': onboardedDate,
      'position': position,
      'role': role,
      'plan': plan,
    };
  }
}
