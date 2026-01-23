import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moustra/services/clients/lab_setting_api.dart';
import 'package:moustra/services/dtos/lab_setting_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/setting_store.dart';
import 'package:moustra/widgets/shared/button.dart';

class LabSettingsTab extends StatefulWidget {
  const LabSettingsTab({super.key});

  @override
  State<LabSettingsTab> createState() => _LabSettingsTabState();
}

class _LabSettingsTabState extends State<LabSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _labNameController = TextEditingController();
  final _rackWidthController = TextEditingController();
  final _rackHeightController = TextEditingController();
  final _weanDateController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _useEid = false;
  LabSettingDto? _labSetting;
  AccountStoreDto? _selectedOwner;
  List<AccountStoreDto>? _accounts;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _rackWidthController.dispose();
    _rackHeightController.dispose();
    _weanDateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load accounts and lab settings in parallel
      final results = await Future.wait([
        getAccountsHook(),
        labSettingApi.getLabSetting(),
      ]);

      final accounts = results[0] as List<AccountStoreDto>;
      final labSetting = results[1] as LabSettingDto;

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _labSetting = labSetting;
          _labNameController.text = labSetting.labName;
          _rackWidthController.text =
              labSetting.defaultRackWidth?.toString() ?? '';
          _rackHeightController.text =
              labSetting.defaultRackHeight?.toString() ?? '';
          _weanDateController.text =
              labSetting.defaultWeanDate?.toString() ?? '';
          _useEid = labSetting.useEid;

          // Find the selected owner from the accounts list
          if (labSetting.owner != null) {
            _selectedOwner = accounts.cast<AccountStoreDto?>().firstWhere(
              (a) => a?.accountUuid == labSetting.owner!.accountUuid,
              orElse: () => null,
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading lab settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Build the owner DTO from selected account
      LabSettingOwnerDto? ownerDto;
      if (_selectedOwner != null) {
        // We need to construct the owner DTO from the selected account
        // Use the existing owner data as base if available, or create minimal required data
        final existingOwner = _labSetting?.owner;
        ownerDto = LabSettingOwnerDto(
          accountId: _selectedOwner!.accountId,
          accountUuid: _selectedOwner!.accountUuid,
          user: LabSettingUserDto(
            email: _selectedOwner!.user.email,
            firstName: _selectedOwner!.user.firstName,
            lastName: _selectedOwner!.user.lastName,
            isActive: _selectedOwner!.isActive ?? true,
          ),
          status: existingOwner?.status ?? 'Active',
          role: existingOwner?.role ?? 'User',
          isActive: _selectedOwner!.isActive ?? true,
          position: existingOwner?.position,
          accountSetting:
              existingOwner?.accountSetting ??
              LabSettingAccountSettingDto(
                enableDailyReport: true,
                onboardingTour: false,
                animalCreationTour: false,
              ),
          onboarded: existingOwner?.onboarded ?? false,
          lab:
              existingOwner?.lab ??
              LabSettingLabDto(
                labId: 0,
                labUuid: '',
                labName: _labNameController.text.trim(),
              ),
        );
      }

      final updatedSetting = LabSettingDto(
        defaultRackWidth: int.tryParse(_rackWidthController.text.trim()),
        defaultRackHeight: int.tryParse(_rackHeightController.text.trim()),
        defaultWeanDate: int.tryParse(_weanDateController.text.trim()),
        useEid: _useEid,
        owner: ownerDto,
        labName: _labNameController.text.trim(),
      );

      await labSettingApi.updateLabSetting(updatedSetting);

      // Refresh the setting store so other parts of the app get the updated values
      await refreshSettingStore();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving lab settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lab Name
                    TextFormField(
                      controller: _labNameController,
                      decoration: const InputDecoration(
                        labelText: 'Lab Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lab name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Lab Owner
                    DropdownButtonFormField<AccountStoreDto>(
                      value: _selectedOwner,
                      decoration: const InputDecoration(
                        labelText: 'Lab Owner',
                        border: OutlineInputBorder(),
                      ),
                      items: _accounts?.map((account) {
                        return DropdownMenuItem<AccountStoreDto>(
                          value: account,
                          child: Text(
                            '${account.user.firstName} ${account.user.lastName}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedOwner = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Default Rack Width and Height in a row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rackWidthController,
                            decoration: const InputDecoration(
                              labelText: 'Default Rack Width',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _rackHeightController,
                            decoration: const InputDecoration(
                              labelText: 'Default Rack Height',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Default Wean Date
                    TextFormField(
                      controller: _weanDateController,
                      decoration: const InputDecoration(
                        labelText: 'Default Wean Date (days)',
                        border: OutlineInputBorder(),
                        helperText: 'Number of days after birth',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),

                    // Use EID Switch
                    SwitchListTile(
                      title: const Text('Use EID'),
                      subtitle: const Text(
                        'Enable Electronic Identification tracking',
                      ),
                      value: _useEid,
                      onChanged: (value) {
                        setState(() => _useEid = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            MoustraButton(
              label: 'Save Settings',
              variant: ButtonVariant.success,
              icon: Icons.save,
              fullWidth: true,
              isLoading: _isSaving,
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
}
