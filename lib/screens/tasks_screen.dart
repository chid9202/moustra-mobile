import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/task_api.dart';
import 'package:moustra/services/dtos/task_dto.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

/// Status/priority color maps matching web
const Map<String, Color> _statusColors = {
  'pending': Color(0xFFFFC107),
  'due': Color(0xFFFF9800),
  'overdue': Color(0xFFF44336),
  'completed': Color(0xFF4CAF50),
  'dismissed': Color(0xFF9E9E9E),
  'snoozed': Color(0xFF2196F3),
};

const Map<String, String> _statusLabels = {
  'pending': 'Pending',
  'due': 'Due',
  'overdue': 'Overdue',
  'completed': 'Completed',
  'dismissed': 'Dismissed',
  'snoozed': 'Snoozed',
};

const Map<String, Color> _priorityColors = {
  'low': Color(0xFF4CAF50),
  'medium': Color(0xFFFFC107),
  'high': Color(0xFFFF9800),
  'urgent': Color(0xFFF44336),
};

const Map<String, String> _taskTypeLabels = {
  'wean': 'Wean',
  'tag': 'Tag',
  'genotype': 'Genotype',
  'mating_check': 'Mating Check',
  'custom': 'Custom',
};

const Map<String, IconData> _taskTypeIcons = {
  'wean': Icons.content_cut,
  'tag': Icons.label,
  'genotype': Icons.biotech,
  'mating_check': Icons.refresh,
  'custom': Icons.assignment,
};

const Map<String, String> _entityRoutes = {
  'litter': '/litter',
  'mating': '/mating',
  'animal': '/animal',
  'cage': '/cage',
  'protocol': '/protocol',
};

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskDto> _tasks = [];
  TaskSummaryDto? _summary;
  bool _isLoading = true;
  String? _error;

  // Filters
  String? _statusFilter;
  String? _typeFilter;
  String? _priorityFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        taskService.getTasks(
          status: _statusFilter,
          taskType: _typeFilter,
          priority: _priorityFilter,
        ),
        taskService.getTaskSummary(),
      ]);
      if (mounted) {
        setState(() {
          _tasks = (results[0] as TaskListResponseDto).tasks;
          _summary = results[1] as TaskSummaryDto;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<TaskDto> _filterByStatus(List<String> statuses) {
    return _tasks.where((t) => statuses.contains(t.status)).toList();
  }

  Future<void> _completeTask(TaskDto task) async {
    try {
      await taskService.completeTask(task.taskUuid);
      _loadData();
      if (mounted) {
        showAppSnackBar(context, 'Task completed', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _dismissTask(TaskDto task) async {
    try {
      await taskService.dismissTask(task.taskUuid);
      _loadData();
      if (mounted) {
        showAppSnackBar(context, 'Task dismissed');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _snoozeTask(TaskDto task) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final formatted = DateFormat('yyyy-MM-dd').format(tomorrow);
    try {
      await taskService.snoozeTask(task.taskUuid, formatted);
      _loadData();
      if (mounted) {
        showAppSnackBar(context, 'Task snoozed until tomorrow');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  String _getDueDateText(TaskDto task) {
    if (task.dueDate == null) return '';
    final due = task.dueDate!;
    final today = DateUtils.dateOnly(DateTime.now());
    final dueDay = DateUtils.dateOnly(due);
    final diff = dueDay.difference(today).inDays;

    if (task.status == 'overdue' || diff < 0) {
      return '${diff.abs()} day${diff.abs() != 1 ? 's' : ''} overdue';
    }
    if (diff == 0) return 'Due today';
    return 'Due in $diff day${diff != 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary chips
        if (_summary != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                if (_summary!.overdue > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(
                        '${_summary!.overdue} overdue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _statusColors['overdue'],
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (_summary!.due > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(
                        '${_summary!.due} due today',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _statusColors['due'],
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (_summary!.pending > 0)
                  Chip(
                    label: Text(
                      '${_summary!.pending} upcoming',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _statusColors['pending'],
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ),

        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterDropdown(
                  label: 'Status',
                  value: _statusFilter,
                  items: _statusLabels,
                  onChanged: (v) {
                    setState(() => _statusFilter = v);
                    _loadData();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  label: 'Type',
                  value: _typeFilter,
                  items: _taskTypeLabels,
                  onChanged: (v) {
                    setState(() => _typeFilter = v);
                    _loadData();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  label: 'Priority',
                  value: _priorityFilter,
                  items: const {
                    'low': 'Low',
                    'medium': 'Medium',
                    'high': 'High',
                    'urgent': 'Urgent',
                  },
                  onChanged: (v) {
                    setState(() => _priorityFilter = v);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),

        // Content
        Expanded(
          child: Stack(
            children: [
              _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error loading tasks',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _tasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks found',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: _buildTaskSections(),
                        ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'tasks-fab',
                  onPressed: () => context.go('/task/new'),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 130,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text('All')),
          ...items.entries.map(
            (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTaskSections() {
    final overdue = _filterByStatus(['overdue']);
    final due = _filterByStatus(['due']);
    final upcoming = _filterByStatus(['pending', 'snoozed']);
    final completed = _filterByStatus(['completed', 'dismissed']);

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (overdue.isNotEmpty)
          _buildSection('Overdue', overdue, _statusColors['overdue']!),
        if (due.isNotEmpty)
          _buildSection('Due Today', due, _statusColors['due']!),
        if (upcoming.isNotEmpty)
          _buildSection('Upcoming', upcoming, _statusColors['pending']!),
        if (completed.isNotEmpty)
          _buildSection('Completed', completed, _statusColors['completed']!),
      ],
    );
  }

  Widget _buildSection(String title, List<TaskDto> tasks, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title (${tasks.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(TaskDto task) {
    final isResolved =
        task.status == 'completed' || task.status == 'dismissed';
    final dueDateText = _getDueDateText(task);
    final typeLabel = _taskTypeLabels[task.taskType] ?? task.taskType;
    final typeIcon = _taskTypeIcons[task.taskType] ?? Icons.assignment;
    final statusColor = _statusColors[task.status] ?? Colors.grey;
    final priorityColor = _priorityColors[task.priority] ?? Colors.grey;

    return Opacity(
      opacity: isResolved ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with icon
              Row(
                children: [
                  Icon(typeIcon, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Chips row
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _smallChip(
                    task.priority.substring(0, 1).toUpperCase() +
                        task.priority.substring(1),
                    priorityColor,
                    textDark: task.priority == 'low' ||
                        task.priority == 'medium',
                  ),
                  _smallChip(
                    _statusLabels[task.status] ?? task.status,
                    statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Meta row
              Row(
                children: [
                  Text(
                    typeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (dueDateText.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Text(
                      dueDateText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: task.status == 'overdue'
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight: task.status == 'overdue'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                  if (task.assignedToName != null) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        task.assignedToName!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              // Actions
              if (!isResolved)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, size: 20),
                        tooltip: 'Complete',
                        color: Colors.green,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _completeTask(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.alarm, size: 20),
                        tooltip: 'Snooze',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _snoozeTask(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Dismiss',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _dismissTask(task),
                      ),
                      if (task.entityType != null &&
                          task.entityUuid != null &&
                          _entityRoutes.containsKey(task.entityType))
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20),
                          tooltip: 'Open ${task.entityType}',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final route = _entityRoutes[task.entityType]!;
                            context.go('$route/${task.entityUuid}');
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallChip(String label, Color color, {bool textDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
