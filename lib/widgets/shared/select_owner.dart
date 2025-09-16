import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';

class SelectOwner extends StatefulWidget {
  const SelectOwner({
    super.key,
    required this.selectedOwner,
    required this.onChanged,
  });
  final AccountStoreDto? selectedOwner;
  final Function(AccountStoreDto?) onChanged;

  @override
  State<SelectOwner> createState() => _SelectOwnerState();
}

class _SelectOwnerState extends State<SelectOwner> {
  List<AccountStoreDto>? accounts;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    if (accounts == null && mounted) {
      final loadedAccounts = await getAccountsHook();
      setState(() {
        accounts = loadedAccounts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find the matching account from accountStore by UUID
    AccountStoreDto? matchingOwner;
    if (widget.selectedOwner != null) {
      try {
        matchingOwner = accounts?.firstWhere(
          (account) => account.accountUuid == widget.selectedOwner!.accountUuid,
        );
      } catch (e) {
        // Account not found in store, leave as null
        matchingOwner = null;
      }
    }

    return DropdownButtonFormField<AccountStoreDto>(
      initialValue: matchingOwner,
      decoration: InputDecoration(
        labelText: 'Owner',
        border: OutlineInputBorder(),
      ),
      items: accounts?.map((account) {
        return DropdownMenuItem<AccountStoreDto>(
          value: account,
          child: Text('${account.user.firstName} ${account.user.lastName}'),
        );
      }).toList(),
      onChanged: (value) {
        widget.onChanged(value);
      },
    );
  }
}
