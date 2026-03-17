class AccountUser {
  final String email;
  final String? firstName;
  final String? lastName;

  AccountUser({
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    return AccountUser(
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }
}

class AccountLab {
  final String? labUuid;
  final String? labName;

  AccountLab({this.labUuid, this.labName});

  factory AccountLab.fromJson(Map<String, dynamic> json) {
    return AccountLab(
      labUuid: json['labUuid'] as String?,
      labName: json['labName'] as String?,
    );
  }
}

class Account {
  final String accountUuid;
  final AccountUser user;
  final String? role;
  final String? position;
  final bool onboarded;
  final AccountLab? lab;

  Account({
    required this.accountUuid,
    required this.user,
    this.role,
    this.position,
    required this.onboarded,
    this.lab,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountUuid: json['accountUuid'] as String,
      user: AccountUser.fromJson(json['user'] as Map<String, dynamic>),
      role: json['role'] as String?,
      position: json['position'] as String?,
      onboarded: json['onboarded'] as bool? ?? false,
      lab: json['lab'] != null
          ? AccountLab.fromJson(json['lab'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AccountDetail extends Account {
  final bool hasInvited;

  AccountDetail({
    required super.accountUuid,
    required super.user,
    super.role,
    super.position,
    required super.onboarded,
    super.lab,
    required this.hasInvited,
  });

  factory AccountDetail.fromJson(Map<String, dynamic> json) {
    return AccountDetail(
      accountUuid: json['accountUuid'] as String,
      user: AccountUser.fromJson(json['user'] as Map<String, dynamic>),
      role: json['role'] as String?,
      position: json['position'] as String?,
      onboarded: json['onboarded'] as bool? ?? false,
      lab: json['lab'] != null
          ? AccountLab.fromJson(json['lab'] as Map<String, dynamic>)
          : null,
      hasInvited: json['hasInvited'] as bool? ?? false,
    );
  }
}
