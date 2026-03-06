import 'package:flutter/material.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/setting_api.dart';
import 'package:moustra/services/dtos/setting_dto.dart';
import 'package:moustra/stores/setting_store.dart';

class AccountSettingsTab extends StatefulWidget {
  const AccountSettingsTab({super.key});

  @override
  State<AccountSettingsTab> createState() => _AccountSettingsTabState();
}

class _AccountSettingsTabState extends State<AccountSettingsTab> {
  bool _isLoading = true;
  bool _isSaving = false;
  AccountSettingDto? _accountSetting;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await settingApi.getSetting();
      if (mounted) {
        setState(() {
          _accountSetting = settings.accountSetting;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppSnackBar(context, 'Error loading account settings: $e', isError: true);
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_accountSetting == null) return;

    final previous = _accountSetting!;
    final updated = previous.copyWith(enableItemUpdateNotifications: value);

    // Optimistic update
    setState(() {
      _accountSetting = updated;
      _isSaving = true;
    });

    try {
      await settingApi.updateAccountSetting(updated);
      await refreshSettingStore();
      if (mounted) {
        showAppSnackBar(context, 'Account settings updated successfully', isSuccess: true);
      }
    } catch (e) {
      // Rollback
      if (mounted) {
        setState(() => _accountSetting = previous);
        showAppSnackBar(context, 'Failed to update account settings: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwitchListTile(
                title: const Text('Enable Item Update Notifications'),
                subtitle: const Text(
                  'Enable notifications when items (animals, cages, matings, litters) are updated by others',
                ),
                value:
                    _accountSetting?.enableItemUpdateNotifications ?? false,
                onChanged: _isSaving ? null : _toggleNotifications,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
