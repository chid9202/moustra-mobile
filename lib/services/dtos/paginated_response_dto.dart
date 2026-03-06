import 'package:flutter/widgets.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class PaginatedResponseDto<T> {
  final int count;
  final List<T> results;
  final String? next;
  final String? previous;

  PaginatedResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory PaginatedResponseDto.fromJson(
    Map<String, dynamic> json,
    FromJson<T> itemFromJson,
  ) {
    final List<dynamic> raw = (json['results'] as List<dynamic>? ?? []);
    final List<T> items = <T>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        try {
          items.add(itemFromJson(e));
        } catch (err, stack) {
          debugPrint('PaginatedResponse: Error parsing $T item: $err');
          debugPrint('PaginatedResponse: Raw JSON keys: ${e.keys.toList()}');
          debugPrint('PaginatedResponse: Stack: $stack');
        }
      }
    }
    return PaginatedResponseDto<T>(
      count: (json['count'] as int?) ?? 0,
      results: items,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) itemToJson) =>
      <String, dynamic>{
        'count': count,
        'results': results.map(itemToJson).toList(),
        'next': next,
        'previous': previous,
      };
}
