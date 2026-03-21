import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/clients/generated_api.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:built_collection/built_collection.dart';

class TableSettingService {
  Timer? _debounceTimer;

  String _mobileName(String baseName) => 'Mobile_$baseName';

  /// Parse a TableSettingSLR from a raw JSON map.
  /// Supports both camelCase (Dio default) and snake_case keys.
  TableSettingSLR _parseTableSetting(Map<String, dynamic> json) {
    final fields = (json['tableSettingFields'] ?? json['table_setting_fields'] ?? []) as List<dynamic>;
    final parsedFields = fields
        .map((f) => _parseField(f as Map<String, dynamic>))
        .toList();

    return (TableSettingSLRBuilder()
          ..tableSettingId = (json['tableSettingId'] ?? json['table_setting_id']) as int
          ..tableSettingUuid = (json['tableSettingUuid'] ?? json['table_setting_uuid']) as String
          ..tableSettingName = (json['tableSettingName'] ?? json['table_setting_name']) as String
          ..owner = (json['owner']) as int?
          ..updatedDate = DateTime.parse((json['updatedDate'] ?? json['updated_date']) as String)
          ..tableSettingFields = ListBuilder<TableSettingFieldSLR>(parsedFields)
          ..pageSize = (json['pageSize'] ?? json['page_size']) as int?)
        .build();
  }

  TableSettingFieldSLR _parseField(Map<String, dynamic> f) {
    return (TableSettingFieldSLRBuilder()
          ..tableSettingFieldId = (f['tableSettingFieldId'] ?? f['table_setting_field_id']) as int
          ..tableSettingFieldUuid = (f['tableSettingFieldUuid'] ?? f['table_setting_field_uuid']) as String
          ..fieldName = (f['fieldName'] ?? f['field_name']) as String
          ..fieldLabel = (f['fieldLabel'] ?? f['field_label']) as String
          ..fieldType = (f['fieldType'] ?? f['field_type']) as String
          ..fieldOrder = (f['fieldOrder'] ?? f['field_order']) as int
          ..fieldVisible = (f['fieldVisible'] ?? f['field_visible']) as bool
          ..fieldFilterable = (f['fieldFilterable'] ?? f['field_filterable'])?.toString()
          ..fieldSortable = (f['fieldSortable'] ?? f['field_sortable'])?.toString()
          ..fieldWidth = (f['fieldWidth'] ?? f['field_width'])?.toString()
          ..updatedDate = DateTime.parse((f['updatedDate'] ?? f['updated_date']) as String)
          ..fieldEditable = (f['fieldEditable'] ?? f['field_editable'])?.toString()
          ..fieldValueOptions = _encodeValueOptions(f['fieldValueOptions'] ?? f['field_value_options']))
        .build();
  }

  /// Encode field_value_options: could be null, a list, or a string. Store as JSON string.
  String _encodeValueOptions(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return jsonEncode(value);
  }

  /// GET table setting via dioApiClient. On 404, auto-refreshes to create defaults.
  Future<TableSettingSLR> getTableSetting(String baseName) async {
    final name = _mobileName(baseName);
    try {
      final res = await dioApiClient.get('/table-setting/$name');
      debugPrint('[TableSetting] GET $name → ${res.statusCode}, data type: ${res.data?.runtimeType}');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        debugPrint('[TableSetting] Keys: ${data.keys.toList()}');
        final fields = data['table_setting_fields'];
        debugPrint('[TableSetting] fields type: ${fields?.runtimeType}, count: ${fields is List ? fields.length : "N/A"}');
        if (fields is List && fields.isNotEmpty) {
          debugPrint('[TableSetting] first field keys: ${(fields[0] as Map).keys.toList()}');
          debugPrint('[TableSetting] first field: ${fields[0]}');
        }
        return _parseTableSetting(data);
      }
      debugPrint('[TableSetting] GET $name → ${res.statusCode}, falling back to refresh');
      return await _refreshAndGet(baseName);
    } catch (e, stack) {
      debugPrint('[TableSetting] GET $name failed: $e');
      debugPrint('[TableSetting] Stack: $stack');
      return await _refreshAndGet(baseName);
    }
  }

  /// Refresh table setting (creates defaults on backend), then GET.
  Future<TableSettingSLR> refreshTableSetting(String baseName) async {
    return await _refreshAndGet(baseName);
  }

  Future<TableSettingSLR> _refreshAndGet(String baseName) async {
    final name = _mobileName(baseName);
    try {
      final refreshRes = await dioApiClient.post('/table-setting/$name/refresh');
      if (refreshRes.statusCode == 200 && refreshRes.data is Map<String, dynamic>) {
        debugPrint('[TableSetting] REFRESH $name → 200');
        return _parseTableSetting(refreshRes.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[TableSetting] REFRESH $name failed: $e');
    }
    // Fallback: GET after refresh
    final res = await dioApiClient.get('/table-setting/$name');
    return _parseTableSetting(res.data as Map<String, dynamic>);
  }

  /// PUT table setting using Dio directly with JSON body.
  Future<TableSettingSLR?> updateTableSetting(
    String baseName,
    TableSettingSLR setting,
  ) async {
    final name = _mobileName(baseName);
    final fieldsJson = setting.tableSettingFields.map((f) => {
      'table_setting_field_id': f.tableSettingFieldId,
      'table_setting_field_uuid': f.tableSettingFieldUuid,
      'field_name': f.fieldName,
      'field_label': f.fieldLabel,
      'field_type': f.fieldType,
      'field_order': f.fieldOrder,
      'field_visible': f.fieldVisible,
      'field_filterable': f.fieldFilterable,
      'field_sortable': f.fieldSortable,
      'field_width': f.fieldWidth,
      'updated_date': f.updatedDate.toIso8601String(),
      'field_editable': f.fieldEditable,
      'field_value_options': f.fieldValueOptions,
    }).toList();

    final body = {
      'table_setting_id': setting.tableSettingId,
      'table_setting_uuid': setting.tableSettingUuid,
      'table_setting_name': setting.tableSettingName,
      if (setting.owner != null) 'owner': setting.owner,
      'updated_date': setting.updatedDate.toIso8601String(),
      'table_setting_fields': fieldsJson,
      if (setting.pageSize != null) 'page_size': setting.pageSize,
    };

    final res = await dioApiClient.put(
      '/table-setting/$name',
      body: body,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update table setting: ${res.data}');
    }
    // Re-fetch to get the canonical response
    return await getTableSetting(baseName);
  }

  /// Debounced update — cancels previous timer, waits 500ms, then saves.
  void debouncedUpdate(
    String baseName,
    TableSettingSLR setting, {
    void Function(TableSettingSLR)? onSuccess,
    void Function(Object)? onError,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final result = await updateTableSetting(baseName, setting);
        if (result != null) {
          onSuccess?.call(result);
        }
      } catch (e) {
        onError?.call(e);
      }
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

final tableSettingService = TableSettingService();
