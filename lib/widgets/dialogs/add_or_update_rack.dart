import 'package:flutter/material.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/post_rack_dto.dart';
import 'package:moustra/services/dtos/put_rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/stores/setting_store.dart';

class AddOrUpdateRackDialog extends StatefulWidget {
  final RackDto? rackData;
  final Future<void> Function({String? rackUuid})? onSuccess;

  const AddOrUpdateRackDialog({super.key, this.rackData, this.onSuccess});

  @override
  State<AddOrUpdateRackDialog> createState() => _AddOrUpdateRackDialogState();
}

class _AddOrUpdateRackDialogState extends State<AddOrUpdateRackDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  bool _isLoading = false;
  bool _isLoadingDefaults = false;

  bool get _isEdit => widget.rackData != null;

  String _getDefaultRackName() {
    final existingRacks = rackStore.value?.rackData.racks ?? [];
    // Find max order-like number from existing rack names
    int maxOrder = 0;
    for (final rack in existingRacks) {
      final name = rack.rackName ?? '';
      // Try to extract number from "R{n}" pattern
      final match = RegExp(r'^R(\d+)$').firstMatch(name);
      if (match != null) {
        final num = int.tryParse(match.group(1)!) ?? 0;
        if (num > maxOrder) maxOrder = num;
      }
    }
    if (maxOrder > 0) return 'R${maxOrder + 1}';
    return 'R${existingRacks.length + 1}';
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _isEdit ? widget.rackData!.rackName : _getDefaultRackName(),
    );
    _widthController = TextEditingController(
      text: _isEdit ? (widget.rackData!.rackWidth ?? 5).toString() : '',
    );
    _heightController = TextEditingController(
      text: _isEdit ? (widget.rackData!.rackHeight ?? 1).toString() : '',
    );

    // Load default values from lab settings for new racks
    if (!_isEdit) {
      _loadDefaults();
    }
  }

  Future<void> _loadDefaults() async {
    setState(() => _isLoadingDefaults = true);
    try {
      final labSetting = await getLabSettingHook();
      if (mounted && labSetting != null) {
        setState(() {
          _widthController.text = labSetting.defaultRackWidth.toString();
          _heightController.text = labSetting.defaultRackHeight.toString();
          _isLoadingDefaults = false;
        });
      } else if (mounted) {
        // Fallback to defaults if settings not available
        setState(() {
          _widthController.text = '8';
          _heightController.text = '10';
          _isLoadingDefaults = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback to defaults on error
        setState(() {
          _widthController.text = '8';
          _heightController.text = '10';
          _isLoadingDefaults = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEdit) {
        final rackUuid = widget.rackData!.rackUuid;
        if (rackUuid == null) {
          throw Exception('Rack UUID is required for editing');
        }
        await rackApi.updateRack(
          rackUuid,
          PutRackDto(
            rackName: _nameController.text.trim(),
            rackWidth: int.parse(_widthController.text),
            rackHeight: int.parse(_heightController.text),
          ),
        );
        if (mounted) {
          Navigator.of(context).pop();
          showAppSnackBar(context, 'Rack updated successfully', isSuccess: true);
          // Call onSuccess callback if provided
          if (widget.onSuccess != null) {
            await widget.onSuccess!(rackUuid: rackUuid);
          }
        }
      } else {
        await rackApi.createRack(
          PostRackDto(
            rackName: _nameController.text.trim(),
            rackWidth: int.parse(_widthController.text),
            rackHeight: int.parse(_heightController.text),
          ),
        );
        if (mounted) {
          Navigator.of(context).pop();
          showAppSnackBar(context, 'Rack created successfully', isSuccess: true);
          // Call onSuccess callback if provided
          if (widget.onSuccess != null) {
            await widget.onSuccess!(rackUuid: null);
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showAppSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Rack' : 'Add Rack'),
      content: Form(
        key: _formKey,
        child: _isLoading || _isLoadingDefaults
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Rack Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a rack name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'Rack Width',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter rack width';
                        }
                        final width = int.tryParse(value);
                        if (width == null || width < 1) {
                          return 'Width must be at least 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Rack Height',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter rack height';
                        }
                        final height = int.tryParse(value);
                        if (height == null || height < 1) {
                          return 'Height must be at least 1';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: Text(_isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
