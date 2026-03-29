import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/services/clients/table_setting_service.dart';
import 'package:moustra/stores/table_setting_store.dart';

import '../robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env.test');
    await authService.init();
  });

  testWidgets('Debug: fetch table setting and print response', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Login
    final loginRobot = LoginRobot(tester);
    await loginRobot.verifyLoginScreenDisplayed();
    await loginRobot.enterEmail(dotenv.env['TEST_EMAIL']!);
    await loginRobot.enterPassword(dotenv.env['TEST_PASSWORD']!);
    await loginRobot.tapSignIn();
    await tester.pumpAndSettle(const Duration(seconds: 15));

    debugPrint('=== LOGGED IN ===');
    debugPrint('Account UUID: ${profileState.value?.accountUuid}');

    // Try raw API call first
    try {
      debugPrint('=== RAW API CALL ===');
      final res = await dioApiClient.get('/table-setting/Mobile_AnimalList');
      debugPrint('Status: ${res.statusCode}');
      debugPrint('Data type: ${res.data?.runtimeType}');
      debugPrint('Data: ${res.data}');
      
      if (res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        debugPrint('Keys: ${data.keys.toList()}');
        final fields = data['table_setting_fields'];
        debugPrint('Fields type: ${fields?.runtimeType}');
        if (fields is List && fields.isNotEmpty) {
          debugPrint('First field: ${fields[0]}');
          final f = fields[0] as Map<String, dynamic>;
          debugPrint('First field keys: ${f.keys.toList()}');
          for (final key in f.keys) {
            debugPrint('  $key: ${f[key]} (${f[key]?.runtimeType})');
          }
        }
      }
    } catch (e, stack) {
      debugPrint('RAW API ERROR: $e');
      debugPrint('Stack: $stack');
    }

    // Try the service
    try {
      debugPrint('=== SERVICE CALL ===');
      final setting = await tableSettingService.getTableSetting('AnimalList');
      debugPrint('Setting loaded: ${setting.tableSettingName}');
      debugPrint('Fields count: ${setting.tableSettingFields.length}');
    } catch (e, stack) {
      debugPrint('SERVICE ERROR: $e');
      debugPrint('Stack: $stack');
    }

    // Try the store
    try {
      debugPrint('=== STORE CALL ===');
      final setting = await getTableSetting('AnimalList');
      debugPrint('Store result: ${setting?.tableSettingName ?? "NULL"}');
      debugPrint('Fields: ${setting?.tableSettingFields.length ?? "N/A"}');
    } catch (e) {
      debugPrint('STORE ERROR: $e');
    }

    debugPrint('=== DONE ===');
  });
}
