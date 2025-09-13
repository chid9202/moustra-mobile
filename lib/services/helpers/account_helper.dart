import 'package:moustra/services/dtos/account_dto.dart';

class AccountHelper {
  static String getOwnerName(AccountDto? account) {
    if (account == null) return '';
    if (account.user.firstName.isNotEmpty && account.user.lastName.isNotEmpty) {
      return '${account.user.firstName} ${account.user.lastName}';
    }
    return account.user.email;
  }
}
