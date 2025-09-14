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
  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    if (accountStore.value.isEmpty) {
      final value = await StoreApi<AccountStoreDto>().getStore(
        StoreKeys.account,
      );
      if (mounted) {
        setState(() {
          accountStore.value = value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AccountStoreDto>(
      initialValue:
          widget.selectedOwner != null &&
              accountStore.value.any(
                (account) =>
                    account.accountUuid == widget.selectedOwner!.accountUuid,
              )
          ? widget.selectedOwner
          : null,
      decoration: InputDecoration(
        labelText: 'Owner',
        border: OutlineInputBorder(),
      ),
      items: accountStore.value.map((account) {
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
