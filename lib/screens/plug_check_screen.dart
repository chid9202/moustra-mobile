import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/dtos/post_plug_check_dto.dart';

class PlugCheckScreen extends StatefulWidget {
  const PlugCheckScreen({super.key});

  @override
  State<PlugCheckScreen> createState() => _PlugCheckScreenState();
}

class _PlugCheckScreenState extends State<PlugCheckScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  List<PlugEventDto> _activeEvents = [];

  // Track check results per plug event UUID
  final Map<String, String> _checkResults = {};
  final Map<String, String> _checkNotes = {};

  @override
  void initState() {
    super.initState();
    _loadActiveEvents();
  }

  void _loadActiveEvents() async {
    try {
      final response = await plugService.getActivePlugEvents(pageSize: 100);
      if (mounted) {
        setState(() {
          _activeEvents = response.results.cast<PlugEventDto>();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active plug events: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _setResult(String eventUuid, String result) {
    setState(() {
      if (_checkResults[eventUuid] == result) {
        _checkResults.remove(eventUuid);
      } else {
        _checkResults[eventUuid] = result;
      }
    });

    // If plug_found, prompt for notes
    if (result == 'plug_found' && _checkResults[eventUuid] == 'plug_found') {
      _showNotesDialog(eventUuid);
    }
  }

  void _showNotesDialog(String eventUuid) {
    final controller = TextEditingController(
      text: _checkNotes[eventUuid] ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notes (optional)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add notes for this plug check...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _checkNotes[eventUuid] = controller.text;
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_checkResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No checks recorded yet')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final checks = <PostPlugCheckDto>[];
      for (final entry in _checkResults.entries) {
        final event = _activeEvents.firstWhere(
          (e) => e.plugEventUuid == entry.key,
        );
        checks.add(PostPlugCheckDto(
          female: event.female!.animalUuid,
          mating: event.mating?.matingUuid,
          checkDate: DateTime.now(),
          result: entry.value,
          notes: _checkNotes[entry.key],
        ));
      }

      await plugService.batchCreatePlugChecks(checks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${checks.length} plug check(s) submitted'),
          ),
        );
        context.go('/plug-event');
      }
    } catch (e) {
      debugPrint('Error submitting plug checks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting checks: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

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
        title: const Text('Record Plug Checks'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _activeEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No active pregnancies to check',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _activeEvents.length,
                    itemBuilder: (context, index) {
                      final event = _activeEvents[index];
                      return _buildCheckCard(event);
                    },
                  ),
          ),
          if (_activeEvents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Submit ${_checkResults.length} Check(s)',
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckCard(PlugEventDto event) {
    final currentResult = _checkResults[event.plugEventUuid];
    final femaleTag = event.female?.physicalTag ?? 'Unknown';
    final matingTag = event.mating?.matingTag ?? '';
    final eday = event.currentEday;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: currentResult != null
              ? _resultColor(currentResult).withValues(alpha: 0.5)
              : Colors.grey.shade300,
          width: currentResult != null ? 2 : 1,
        ),
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
                  femaleTag,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (eday != null)
                  Chip(
                    label: Text(
                      'E${eday.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (matingTag.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Mating: $matingTag',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                _resultToggle(
                  event.plugEventUuid,
                  'plug_found',
                  'Plug Found',
                  currentResult,
                ),
                const SizedBox(width: 8),
                _resultToggle(
                  event.plugEventUuid,
                  'no_plug',
                  'No Plug',
                  currentResult,
                ),
                const SizedBox(width: 8),
                _resultToggle(
                  event.plugEventUuid,
                  'inconclusive',
                  'Inconclusive',
                  currentResult,
                ),
              ],
            ),
            if (_checkNotes[event.plugEventUuid] != null &&
                _checkNotes[event.plugEventUuid]!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notes: ${_checkNotes[event.plugEventUuid]}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _resultToggle(
    String eventUuid,
    String value,
    String label,
    String? currentResult,
  ) {
    final isSelected = currentResult == value;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? _resultColor(value).withValues(alpha: 0.15) : null,
          side: BorderSide(
            color: isSelected ? _resultColor(value) : Colors.grey.shade400,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        onPressed: () => _setResult(eventUuid, value),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? _resultColor(value) : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _resultColor(String result) {
    switch (result) {
      case 'plug_found':
        return Colors.green;
      case 'no_plug':
        return Colors.red;
      case 'inconclusive':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
