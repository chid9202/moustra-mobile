import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/protocol_api.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';
import 'package:moustra/stores/protocol_store.dart';
import 'package:moustra/widgets/shared/button.dart';

class ProtocolFormScreen extends StatefulWidget {
  const ProtocolFormScreen({super.key});

  @override
  State<ProtocolFormScreen> createState() => _ProtocolFormScreenState();
}

class _ProtocolFormScreenState extends State<ProtocolFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _protocolNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fundingSourceController = TextEditingController();
  final _speciesController = TextEditingController(text: 'Mus musculus');
  final _maxAnimalCountController = TextEditingController();

  String _painCategory = 'B';
  DateTime? _approvalDate;
  DateTime? _effectiveDate;
  DateTime? _expirationDate;
  double _alertThreshold = 80;

  ProtocolDto? _existingProtocol;
  bool _isLoading = false;
  bool _dataLoaded = false;

  String? get _protocolUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['protocolUuid'];
  }

  bool get _isEditing => _protocolUuid != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded && _isEditing) {
      _loadProtocol();
    }
    _dataLoaded = true;
  }

  @override
  void dispose() {
    _protocolNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _fundingSourceController.dispose();
    _speciesController.dispose();
    _maxAnimalCountController.dispose();
    super.dispose();
  }

  Future<void> _loadProtocol() async {
    final uuid = _protocolUuid;
    if (uuid == null) return;
    setState(() => _isLoading = true);

    try {
      final protocol = await protocolApi.getProtocol(uuid);
      if (mounted) {
        setState(() {
          _existingProtocol = protocol;
          _protocolNumberController.text = protocol.protocolNumber;
          _titleController.text = protocol.title;
          _descriptionController.text = protocol.description ?? '';
          _fundingSourceController.text = protocol.fundingSource ?? '';
          _speciesController.text = protocol.species ?? 'Mus musculus';
          _maxAnimalCountController.text =
              protocol.maxAnimalCount.toString();
          _painCategory = protocol.painCategory;
          _alertThreshold =
              (protocol.alertThresholdPct ?? 80).toDouble();
          if (protocol.approvalDate != null) {
            _approvalDate = DateTime.tryParse(protocol.approvalDate!);
          }
          if (protocol.effectiveDate != null) {
            _effectiveDate = DateTime.tryParse(protocol.effectiveDate!);
          }
          _expirationDate = DateTime.tryParse(protocol.expirationDate);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading protocol: $e')),
        );
      }
    }
  }

  Future<void> _pickDate({
    required DateTime? currentDate,
    required void Function(DateTime) onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveProtocol() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set an expiration date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'protocolNumber': _protocolNumberController.text.trim(),
      'title': _titleController.text.trim(),
      'expirationDate': _formatDate(_expirationDate),
      'painCategory': _painCategory,
      'maxAnimalCount': int.tryParse(_maxAnimalCountController.text) ?? 0,
      'species': _speciesController.text.trim(),
      'alertThresholdPct': _alertThreshold.round(),
    };

    if (_approvalDate != null) {
      data['approvalDate'] = _formatDate(_approvalDate);
    }
    if (_effectiveDate != null) {
      data['effectiveDate'] = _formatDate(_effectiveDate);
    }
    if (_descriptionController.text.trim().isNotEmpty) {
      data['description'] = _descriptionController.text.trim();
    }
    if (_fundingSourceController.text.trim().isNotEmpty) {
      data['fundingSource'] = _fundingSourceController.text.trim();
    }

    try {
      if (_isEditing) {
        await protocolApi.updateProtocol(_protocolUuid!, data);
      } else {
        await protocolApi.createProtocol(data);
      }
      await refreshProtocolStore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Protocol updated successfully!'
                  : 'Protocol created successfully!',
            ),
          ),
        );
        context.go('/protocol');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving protocol: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isEditing && _existingProtocol == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/protocol'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/protocol'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(_isEditing ? 'Edit Protocol' : 'New Protocol'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Protocol Number
              TextFormField(
                controller: _protocolNumberController,
                decoration: const InputDecoration(
                  labelText: 'Protocol Number *',
                  hintText: 'e.g., IACUC-2026-0042',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Protocol title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Species
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Max Animal Count
              TextFormField(
                controller: _maxAnimalCountController,
                decoration: const InputDecoration(
                  labelText: 'Max Animal Count *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Pain Category
              Text(
                'Pain Category *',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['B', 'C', 'D', 'E'].map((cat) {
                  final selected = _painCategory == cat;
                  return ChoiceChip(
                    label: Text('Category $cat'),
                    selected: selected,
                    selectedColor: _painCategoryColor(cat).withValues(
                      alpha: 0.2,
                    ),
                    onSelected: (_) {
                      setState(() => _painCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _painCategoryDescription(_painCategory),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 24),

              // Dates
              Text(
                'Dates',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildDateField(
                label: 'Approval Date',
                value: _approvalDate,
                onTap: () => _pickDate(
                  currentDate: _approvalDate,
                  onPicked: (d) => _approvalDate = d,
                ),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Effective Date',
                value: _effectiveDate,
                onTap: () => _pickDate(
                  currentDate: _effectiveDate,
                  onPicked: (d) => _effectiveDate = d,
                ),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Expiration Date *',
                value: _expirationDate,
                onTap: () => _pickDate(
                  currentDate: _expirationDate,
                  onPicked: (d) => _expirationDate = d,
                ),
                isRequired: true,
              ),
              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Protocol description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Funding Source
              TextFormField(
                controller: _fundingSourceController,
                decoration: const InputDecoration(
                  labelText: 'Funding Source',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Alert Threshold Slider
              Text(
                'Alert Threshold: ${_alertThreshold.round()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _alertThreshold,
                min: 50,
                max: 100,
                divisions: 50,
                label: '${_alertThreshold.round()}%',
                onChanged: (v) => setState(() => _alertThreshold = v),
              ),
              Text(
                'Warning triggers at ${_alertThreshold.round()}% of max animal count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  onPressed: _isLoading ? null : _saveProtocol,
                  label:
                      _isLoading ? 'Saving...' : (_isEditing ? 'Update Protocol' : 'Create Protocol'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null ? _formatDate(value) : 'Select date',
          style: TextStyle(
            color: value != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Color _painCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'B':
        return Colors.green;
      case 'C':
        return Colors.blue;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _painCategoryDescription(String category) {
    switch (category.toUpperCase()) {
      case 'B':
        return 'Category B: Animals bred, conditioned, or held but not yet used';
      case 'C':
        return 'Category C: No pain or distress, or pain relieved by immediate euthanasia';
      case 'D':
        return 'Category D: Pain or distress appropriately relieved with anesthetics/analgesics';
      case 'E':
        return 'Category E: Pain or distress NOT relieved (scientific justification required)';
      default:
        return '';
    }
  }
}
