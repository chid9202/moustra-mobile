import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/task_api.dart';
import 'package:moustra/services/dtos/task_dto.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/event_api.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _taskType = 'custom';
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final dto = PostTaskDto(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        taskType: _taskType,
        priority: _priority,
        dueDate: _dueDate != null
            ? DateFormat('yyyy-MM-dd').format(_dueDate!)
            : null,
      );
      await taskService.createTask(dto);
      eventApi.trackEvent('create_task');
      if (mounted) {
        showAppSnackBar(context, 'Task created', isSuccess: true);
        context.go('/task');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Task',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Task Type
            DropdownButtonFormField<String>(
              value: _taskType,
              decoration: const InputDecoration(
                labelText: 'Task Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
                DropdownMenuItem(value: 'wean', child: Text('Wean')),
                DropdownMenuItem(value: 'tag', child: Text('Tag')),
                DropdownMenuItem(value: 'genotype', child: Text('Genotype')),
                DropdownMenuItem(
                    value: 'mating_check', child: Text('Mating Check')),
              ],
              onChanged: (v) => setState(() => _taskType = v ?? 'custom'),
            ),
            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? 'medium'),
            ),
            const SizedBox(height: 16),

            // Due Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _dueDate != null
                    ? 'Due: ${DateFormat('MMM d, yyyy').format(_dueDate!)}'
                    : 'No due date',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _pickDueDate,
                    child: Text(_dueDate != null ? 'Change' : 'Set Date'),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
