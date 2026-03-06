import 'package:flutter/material.dart';

class CalendarEventTypeDef {
  final String value;
  final String label;
  final Color color;
  final String category;

  const CalendarEventTypeDef({
    required this.value,
    required this.label,
    required this.color,
    required this.category,
  });
}

class CalendarConstants {
  static const List<CalendarEventTypeDef> eventTypes = [
    // Animals
    CalendarEventTypeDef(
      value: 'animal_wean',
      label: 'Animal Wean',
      color: Color(0xFF2196F3),
      category: 'Animals',
    ),
    CalendarEventTypeDef(
      value: 'animal_birth',
      label: 'Animal Birth',
      color: Color(0xFF4CAF50),
      category: 'Animals',
    ),
    CalendarEventTypeDef(
      value: 'animal_procedure',
      label: 'Animal Procedure',
      color: Color(0xFFFF9800),
      category: 'Animals',
    ),

    // Litters
    CalendarEventTypeDef(
      value: 'litter_birth',
      label: 'Litter Birth',
      color: Color(0xFF8BC34A),
      category: 'Litters',
    ),
    CalendarEventTypeDef(
      value: 'litter_wean',
      label: 'Litter Wean',
      color: Color(0xFF00BCD4),
      category: 'Litters',
    ),

    // Breeding
    CalendarEventTypeDef(
      value: 'mating_setup',
      label: 'Mating Setup',
      color: Color(0xFFE91E63),
      category: 'Breeding',
    ),
    CalendarEventTypeDef(
      value: 'mating_pregnancy',
      label: 'Mating Pregnancy',
      color: Color(0xFF9C27B0),
      category: 'Breeding',
    ),
    CalendarEventTypeDef(
      value: 'plug_date',
      label: 'Plug Date',
      color: Color(0xFFF44336),
      category: 'Breeding',
    ),
    CalendarEventTypeDef(
      value: 'plug_target',
      label: 'Plug Target',
      color: Color(0xFFFF5722),
      category: 'Breeding',
    ),
    CalendarEventTypeDef(
      value: 'plug_delivery_start',
      label: 'Delivery Start',
      color: Color(0xFF795548),
      category: 'Breeding',
    ),
    CalendarEventTypeDef(
      value: 'plug_delivery_end',
      label: 'Delivery End',
      color: Color(0xFF607D8B),
      category: 'Breeding',
    ),

    // Protocols
    CalendarEventTypeDef(
      value: 'protocol_expiration',
      label: 'Protocol Expiration',
      color: Color(0xFFF44336),
      category: 'Protocols',
    ),
    CalendarEventTypeDef(
      value: 'protocol_approval',
      label: 'Protocol Approval',
      color: Color(0xFF4CAF50),
      category: 'Protocols',
    ),
    CalendarEventTypeDef(
      value: 'amendment_effective',
      label: 'Amendment Effective',
      color: Color(0xFFFF9800),
      category: 'Protocols',
    ),

    // Tasks
    CalendarEventTypeDef(
      value: 'task_due',
      label: 'Task Due',
      color: Color(0xFFFF5722),
      category: 'Tasks',
    ),
  ];

  static Color getEventColor(String eventType) {
    for (final type in eventTypes) {
      if (type.value == eventType) return type.color;
    }
    return Colors.grey;
  }

  static String getEventLabel(String eventType) {
    for (final type in eventTypes) {
      if (type.value == eventType) return type.label;
    }
    return eventType;
  }

  static const Map<String, String> entityRoutes = {
    'animal': '/animal',
    'litter': '/litter',
    'mating': '/mating',
    'plug_event': '/plug-event',
    'protocol': '/protocol',
    'task': '/task',
  };
}
