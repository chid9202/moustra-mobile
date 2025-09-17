import 'package:moustra/app/router.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';

class AccountHelper {
  static String getOwnerName(AccountDto? account) {
    if (account == null) return '';
    if (account.user.firstName.isNotEmpty && account.user.lastName.isNotEmpty) {
      return '${account.user.firstName} ${account.user.lastName}';
    }
    return account.user.email;
  }

  static Future<AccountStoreDto> getDefaultOwner() async {
    final profile = profileState.value;

    if (profile == null) {
      throw Exception('Profile not found');
    }

    final account = await getAccountHook(profile.accountUuid);
    if (account == null) {
      throw Exception('Default owner not found');
    }
    return account;
  }
}
