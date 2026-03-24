import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/dtos/put_plug_event_dto.dart';
import 'package:moustra/widgets/dialogs/plug_event_outcome_dialog.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/event_api.dart';

class PlugEventDetailScreen extends StatefulWidget {
  const PlugEventDetailScreen({super.key});

  @override
  State<PlugEventDetailScreen> createState() => _PlugEventDetailScreenState();
}

class _PlugEventDetailScreenState extends State<PlugEventDetailScreen> {
  PlugEventDto? _plugEvent;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Editable fields
  DateTime? _editPlugDate;
  final _targetEdayController = TextEditingController();
  final _commentController = TextEditingController();

  String? get _plugEventUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['plugEventUuid'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      eventApi.trackEvent('view_plug_event');
      _loadData();
    }
  }

  void _loadData() async {
    final uuid = _plugEventUuid;
    if (uuid == null) {
      setState(() {
        _isLoading = false;
        _error = 'No plug event UUID provided';
      });
      return;
    }
    try {
      final event = await plugService.getPlugEvent(uuid);
      if (mounted) {
        setState(() {
          _plugEvent = event;
          _isLoading = false;
          _editPlugDate = DateTime.tryParse(event.plugDate);
          _targetEdayController.text =
              event.targetEday?.toStringAsFixed(0) ?? '';
          _commentController.text = event.comment ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading plug event: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _save() async {
    final uuid = _plugEventUuid;
    if (uuid == null) return;

    setState(() => _isSaving = true);

    try {
      final dto = PutPlugEventDto(
        plugDate: _editPlugDate != null
            ? DateFormat('yyyy-MM-dd').format(_editPlugDate!)
            : null,
        targetEday: _targetEdayController.text.isNotEmpty
            ? int.tryParse(_targetEdayController.text)
            : null,
        comment:
            _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      final updated = await plugService.updatePlugEvent(uuid, dto);
      eventApi.trackEvent('update_plug_event');
      if (mounted) {
        setState(() {
          _plugEvent = updated;
          _editPlugDate = DateTime.tryParse(updated.plugDate);
          _targetEdayController.text =
              updated.targetEday?.toStringAsFixed(0) ?? '';
          _commentController.text = updated.comment ?? '';
          _isSaving = false;
        });
        showAppSnackBar(context, 'Plug event updated successfully', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showAppSnackBar(context, 'Error updating plug event: $e', isError: true);
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plug Event'),
        content: const Text(
          'Are you sure you want to delete this plug event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final uuid = _plugEventUuid;
    if (uuid == null) return;

    try {
      await plugService.deletePlugEvent(uuid);
      eventApi.trackEvent('delete_plug_event');
      if (mounted) {
        showAppSnackBar(context, 'Plug event deleted');
        context.go('/plug-event');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error deleting plug event: $e', isError: true);
      }
    }
  }

  Future<void> _recordOutcome() async {
    final event = _plugEvent;
    if (event == null) return;

    final result = await showDialog<PlugEventDto>(
      context: context,
      builder: (context) => PlugEventOutcomeDialog(plugEvent: event),
    );

    if (result != null && mounted) {
      setState(() {
        _plugEvent = result;
        _editPlugDate = DateTime.tryParse(result.plugDate);
        _targetEdayController.text =
            result.targetEday?.toStringAsFixed(0) ?? '';
        _commentController.text = result.comment ?? '';
      });
      showAppSnackBar(context, 'Outcome recorded successfully', isSuccess: true);

      // Prompt to create litter on live_birth
      if (result.outcome == 'live_birth' && result.mating != null) {
        final createLitter = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Create Litter?'),
            content: const Text(
              'Would you like to create a litter for this pregnancy?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (createLitter == true && mounted) {
          context.go('/litter/new?matingUuid=${result.mating!.matingUuid}');
        }
      }
    }
  }

  @override
  void dispose() {
    _targetEdayController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    final event = _plugEvent!;
    final bool isActive = event.outcome == null || event.outcome!.isEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/plug-event');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Pregnancy: ${event.female?.physicalTag ?? 'Unknown'}',
        ),
        actions: [
          Semantics(
            label: 'Save Plug Event',
            button: true,
            child: IconButton(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save),
              tooltip: 'Save',
            ),
          ),
          Semantics(
            label: 'Delete Plug Event',
            button: true,
            child: IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // E-Day display card
            _buildEdayCard(event),
            const SizedBox(height: 16),

            // Record Outcome button (only when active)
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _recordOutcome,
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Record Outcome'),
                  ),
                ),
              ),

            // Female info card
            if (event.female != null)
              InkWell(
                onTap: () => context.go('/animal/${event.female!.animalUuid}'),
                borderRadius: BorderRadius.circular(8),
                child: _buildInfoCard(
                  'Female',
                  [
                    _infoRow('Tag', event.female?.physicalTag ?? 'N/A'),
                    _infoRow('Sex', event.female?.sex ?? 'N/A'),
                  ],
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              )
            else
              _buildInfoCard(
                'Female',
                [
                  _infoRow('Tag', 'N/A'),
                  _infoRow('Sex', 'N/A'),
                ],
              ),
            const SizedBox(height: 12),

            // Male info card
            if (event.male != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => context.go('/animal/${event.male!.animalUuid}'),
                  borderRadius: BorderRadius.circular(8),
                  child: _buildInfoCard(
                    'Male',
                    [
                      _infoRow('Tag', event.male?.physicalTag ?? 'N/A'),
                    ],
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              ),

            // Mating info card
            if (event.mating != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => context.go('/mating/${event.mating!.matingUuid}'),
                  borderRadius: BorderRadius.circular(8),
                  child: _buildInfoCard(
                    'Mating',
                    [
                      _infoRow('Tag', event.mating?.matingTag ?? 'N/A'),
                    ],
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              ),

            // Dates section
            _buildInfoCard(
              'Dates',
              [
                _infoRow('Plug Date', DateTimeHelper.parseIsoToDate(event.plugDate)),
                if (event.plugTime != null)
                  _infoRow('Plug Time', event.plugTime!),
                _infoRow(
                  'Target Date',
                  DateTimeHelper.parseIsoToDate(event.targetDate),
                ),
                _infoRow(
                  'Expected Delivery Start',
                  DateTimeHelper.parseIsoToDate(event.expectedDeliveryStart),
                ),
                _infoRow(
                  'Expected Delivery End',
                  DateTimeHelper.parseIsoToDate(event.expectedDeliveryEnd),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Outcome section
            if (event.outcome != null && event.outcome!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildInfoCard(
                  'Outcome',
                  [
                    _infoRow('Outcome', _formatOutcome(event.outcome)),
                    _infoRow(
                      'Outcome Date',
                      DateTimeHelper.parseIsoToDate(event.outcomeDate),
                    ),
                    if (event.outcomeEday != null)
                      _infoRow(
                        'Outcome E-Day',
                        event.outcomeEday!.toStringAsFixed(1),
                      ),
                    if (event.embryosCollected != null)
                      _infoRow(
                        'Embryos Collected',
                        event.embryosCollected.toString(),
                      ),
                  ],
                ),
              ),

            // Editable fields
            _buildInfoCard(
              'Edit',
              [
                SelectDate(
                  selectedDate: _editPlugDate,
                  onChanged: (date) {
                    setState(() => _editPlugDate = date);
                  },
                  labelText: 'Plug Date',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetEdayController,
                  decoration: const InputDecoration(
                    labelText: 'Target E-Day',
                    hintText: 'e.g. 18',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    hintText: 'Enter any additional comments',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metadata
            _buildInfoCard(
              'Details',
              [
                _infoRow(
                  'Checked By',
                  event.checkedBy?.user != null
                      ? '${event.checkedBy!.user!.firstName} ${event.checkedBy!.user!.lastName}'
                      : 'N/A',
                ),
                _infoRow(
                  'Owner',
                  event.owner?.user != null
                      ? '${event.owner!.user!.firstName} ${event.owner!.user!.lastName}'
                      : 'N/A',
                ),
                _infoRow(
                  'Created',
                  DateTimeHelper.parseIsoToDateTime(event.createdDate),
                ),
                _infoRow(
                  'Updated',
                  DateTimeHelper.parseIsoToDateTime(event.updatedDate),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes Section
            if (_plugEventUuid != null)
              NoteList(
                entityUuid: _plugEventUuid,
                entityType: NoteEntityType.plugEvent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdayCard(PlugEventDto event) {
    final current = event.currentEday;
    final target = event.targetEday;

    Color edayColor = Colors.grey;
    if (current != null && target != null) {
      if (current > target) {
        edayColor = Colors.red;
      } else if (current >= target - 1) {
        edayColor = Colors.orange;
      } else {
        edayColor = Colors.green;
      }
    }

    final bool isActive = event.outcome == null || event.outcome!.isEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              isActive ? 'Current E-Day' : 'Final E-Day',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              current != null ? 'E${current.toStringAsFixed(1)}' : 'N/A',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: edayColor,
              ),
            ),
            if (target != null)
              Text(
                'Target: E${target.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                isActive ? 'Active' : _formatOutcome(event.outcome),
                style: TextStyle(
                  color: isActive ? Colors.green.shade800 : Colors.grey.shade800,
                ),
              ),
              backgroundColor:
                  isActive ? Colors.green.shade50 : Colors.grey.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, {Widget? trailing}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'N/A' : value),
          ),
        ],
      ),
    );
  }

  String _formatOutcome(String? outcome) {
    if (outcome == null || outcome.isEmpty) return 'Active';
    return outcome
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
