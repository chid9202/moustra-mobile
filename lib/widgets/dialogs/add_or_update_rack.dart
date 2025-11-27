import 'package:flutter/material.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/post_rack_dto.dart';
import 'package:moustra/services/dtos/put_rack_dto.dart';

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

  bool get _isEdit => widget.rackData != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _isEdit ? widget.rackData!.rackName : '',
    );
    _widthController = TextEditingController(
      text: _isEdit ? (widget.rackData!.rackWidth ?? 5).toString() : '5',
    );
    _heightController = TextEditingController(
      text: _isEdit ? (widget.rackData!.rackHeight ?? 1).toString() : '1',
    );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rack updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rack created successfully'),
              backgroundColor: Colors.green,
            ),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Rack' : 'Add Rack'),
      content: Form(
        key: _formKey,
        child: _isLoading
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
