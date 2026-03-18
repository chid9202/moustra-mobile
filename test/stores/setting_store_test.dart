import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/setting_dto.dart';
import 'package:moustra/stores/setting_store.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    settingStore.value = null;
  });

  tearDown(() {
    settingStore.value = null;
  });

  SettingDto _makeSetting({
    bool useEid = false,
    int defaultWeanDate = 21,
  }) {
    return SettingDto(
      accountSetting: AccountSettingDto(
        enableDailyReport: false,
        onboardingTour: false,
        animalCreationTour: false,
        useComment: true,
        enableCustomWeanDate: true,
      ),
      labSetting: LabSettingStoreDto(
        defaultRackWidth: 18,
        defaultRackHeight: 12,
        defaultWeanDate: defaultWeanDate,
        useEid: useEid,
      ),
    );
  }

  group('useSettingStore', () {
    test('returns existing setting when store is populated', () async {
      settingStore.value = _makeSetting();

      final result = await useSettingStore();
      expect(result, isNotNull);
      expect(result!.labSetting.defaultWeanDate, 21);
    });

    // Note: testing with null store is not feasible because useSettingStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });

  group('getSettingHook', () {
    test('returns setting when store is populated', () async {
      settingStore.value = _makeSetting(useEid: true);

      final result = await getSettingHook();
      expect(result, isNotNull);
      expect(result!.labSetting.useEid, isTrue);
    });

    // Note: testing with null store is not feasible because useSettingStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });

  group('getLabSettingHook', () {
    test('returns lab setting when store is populated', () async {
      settingStore.value = _makeSetting(defaultWeanDate: 28);

      final result = await getLabSettingHook();
      expect(result, isNotNull);
      expect(result!.defaultWeanDate, 28);
      expect(result.defaultRackWidth, 18);
      expect(result.defaultRackHeight, 12);
    });

    // Note: testing with null store is not feasible because useSettingStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });

  group('settingStore value', () {
    test('can be set and read', () {
      settingStore.value = _makeSetting();

      expect(settingStore.value, isNotNull);
      expect(settingStore.value!.accountSetting.useComment, isTrue);
    });

    test('defaults to null', () {
      expect(settingStore.value, isNull);
    });
  });
}
