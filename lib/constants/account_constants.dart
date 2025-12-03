enum AccountPlan {
  professional('Professional'),
  free('Free'),
  freeTrial('FreeTrial');

  final String value;
  const AccountPlan(this.value);
}

enum AccountRole {
  admin('Admin'),
  user('User');

  final String value;
  const AccountRole(this.value);
}
