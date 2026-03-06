import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moustra/constants/calendar_constants.dart';
import 'package:moustra/services/clients/calendar_api.dart';
import 'package:moustra/services/dtos/calendar_event_dto.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEventDto> _events = [];
  Map<DateTime, List<CalendarEventDto>> _eventsByDate = {};
  bool _isLoading = false;
  final Set<String> _selectedEventTypes = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(DateTime.now());
    _fetchEvents(_focusedDay);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _fetchEvents(DateTime month) async {
    setState(() => _isLoading = true);

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startDate = DateFormat('yyyy-MM-dd').format(firstDay);
    final endDate = DateFormat('yyyy-MM-dd').format(lastDay);

    try {
      final response = await calendarService.getCalendarEvents(
        startDate: startDate,
        endDate: endDate,
        eventTypes:
            _selectedEventTypes.isNotEmpty ? _selectedEventTypes.toList() : null,
      );

      final grouped = <DateTime, List<CalendarEventDto>>{};
      for (final event in response.events) {
        final date = _normalizeDate(DateTime.parse(event.date));
        grouped.putIfAbsent(date, () => []).add(event);
      }

      setState(() {
        _events = response.events;
        _eventsByDate = grouped;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching calendar events: $e');
      setState(() {
        _events = [];
        _eventsByDate = {};
        _isLoading = false;
      });
    }
  }

  List<CalendarEventDto> _getEventsForDay(DateTime day) {
    return _eventsByDate[_normalizeDate(day)] ?? [];
  }

  List<CalendarEventDto> get _displayedEvents {
    if (_selectedDay != null) {
      return _getEventsForDay(_selectedDay!);
    }
    return _events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = _normalizeDate(selectedDay);
      _focusedDay = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _fetchEvents(focusedDay);
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedDay = now;
      _selectedDay = null;
    });
    _fetchEvents(now);
  }

  void _goToPreviousMonth() {
    final prev = DateTime(_focusedDay.year, _focusedDay.month - 1);
    setState(() {
      _focusedDay = prev;
      _selectedDay = null;
    });
    _fetchEvents(prev);
  }

  void _goToNextMonth() {
    final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
    setState(() {
      _focusedDay = next;
      _selectedDay = null;
    });
    _fetchEvents(next);
  }

  void _toggleEventType(String eventType) {
    setState(() {
      if (_selectedEventTypes.contains(eventType)) {
        _selectedEventTypes.remove(eventType);
      } else {
        _selectedEventTypes.add(eventType);
      }
    });
    _fetchEvents(_focusedDay);
  }

  void _onEventTap(CalendarEventDto event) {
    final route = CalendarConstants.entityRoutes[event.entityType];
    if (route == null) return;

    if (event.entityType == 'task') {
      context.go(route);
    } else {
      context.go('$route/${event.entityUuid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom header row
        _buildMonthHeader(theme),

        // Event type filter chips
        _buildFilterChips(theme),

        // Calendar
        TableCalendar<CalendarEventDto>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) =>
              _selectedDay != null && isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerVisible: false,
          onDaySelected: _onDaySelected,
          onPageChanged: _onPageChanged,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return _buildMarkers(events);
            },
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
            markersMaxCount: 0,
          ),
        ),

        const Divider(height: 1),

        // Event list header
        _buildEventListHeader(theme),

        // Event list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _displayedEvents.isEmpty
                  ? Center(
                      child: Text(
                        _selectedDay != null
                            ? 'No events on this day'
                            : 'No events this month',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _displayedEvents.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final event = _displayedEvents[index];
                        return _buildEventTile(event, theme);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(ThemeData theme) {
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('prev_month'),
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousMonth,
          ),
          Expanded(
            child: Text(
              monthLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            key: const Key('next_month'),
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextMonth,
          ),
          ActionChip(
            key: const Key('today_button'),
            label: const Text('Today'),
            onPressed: _goToToday,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: CalendarConstants.eventTypes.map((type) {
          final selected = _selectedEventTypes.contains(type.value);
          return FilterChip(
            label: Text(type.label),
            avatar: CircleAvatar(
              backgroundColor: type.color,
              radius: 6,
            ),
            selected: selected,
            onSelected: (_) => _toggleEventType(type.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarkers(List<CalendarEventDto> events) {
    final maxDots = events.length > 4 ? 4 : events.length;
    final dots = <Widget>[];

    for (var i = 0; i < maxDots; i++) {
      if (i == 3 && events.length > 4) {
        dots.add(Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        ));
      } else {
        final color = CalendarConstants.getEventColor(events[i].eventType);
        dots.add(Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ));
      }
    }

    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: dots,
      ),
    );
  }

  Widget _buildEventListHeader(ThemeData theme) {
    final displayed = _displayedEvents;
    final count = displayed.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedDay != null
                  ? '${DateFormat('E, MMM d').format(_selectedDay!)} ($count)'
                  : 'All Events ($count)',
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (_selectedDay != null)
            ActionChip(
              label: const Text('Clear'),
              onPressed: () => setState(() => _selectedDay = null),
            ),
        ],
      ),
    );
  }

  Widget _buildEventTile(CalendarEventDto event, ThemeData theme) {
    final color = CalendarConstants.getEventColor(event.eventType);
    final label = CalendarConstants.getEventLabel(event.eventType);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      title: Text(
        event.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('$label \u00B7 ${event.date}'),
      onTap: () => _onEventTap(event),
    );
  }
}
