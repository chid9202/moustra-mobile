import 'package:flutter/foundation.dart';
import 'package:moustra/services/clients/table_setting_service.dart';
import 'package:moustra_api/moustra_api.dart';

final tableSettingStore = ValueNotifier<Map<String, TableSettingSLR>>({});

/// Get a table setting by baseName, using cache first.
Future<TableSettingSLR?> getTableSetting(String baseName) async {
  final cached = tableSettingStore.value[baseName];
  if (cached != null) return cached;

  try {
    final setting = await tableSettingService.getTableSetting(baseName);
    debugPrint('[TableSetting] Loaded $baseName: ${setting.tableSettingFields.length} fields');
    final updated = Map<String, TableSettingSLR>.from(tableSettingStore.value);
    updated[baseName] = setting;
    tableSettingStore.value = updated;
    return setting;
  } catch (e) {
    debugPrint('[TableSetting] Failed to load $baseName: $e');
    return null;
  }
}

/// Update cache immediately, then debounced PUT to backend.
void updateTableSetting(String baseName, TableSettingSLR setting) {
  final updated = Map<String, TableSettingSLR>.from(tableSettingStore.value);
  updated[baseName] = setting;
  tableSettingStore.value = updated;

  tableSettingService.debouncedUpdate(
    baseName,
    setting,
    onSuccess: (result) {
      final refreshed = Map<String, TableSettingSLR>.from(tableSettingStore.value);
      refreshed[baseName] = result;
      tableSettingStore.value = refreshed;
    },
  );
}

/// Refresh from backend (resets to defaults).
Future<TableSettingSLR?> refreshTableSetting(String baseName) async {
  try {
    final setting = await tableSettingService.refreshTableSetting(baseName);
    final updated = Map<String, TableSettingSLR>.from(tableSettingStore.value);
    updated[baseName] = setting;
    tableSettingStore.value = updated;
    return setting;
  } catch (e) {
    debugPrint('Failed to refresh table setting for $baseName: $e');
    return null;
  }
}

/// Clear all cached table settings (call on logout).
void clearTableSettingStore() {
  tableSettingStore.value = {};
}
