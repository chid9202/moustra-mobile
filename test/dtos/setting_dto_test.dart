import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/setting_dto.dart';

void main() {
  group('LabSettingStoreDto', () {
    test('should parse useEid as true from JSON', () {
      final json = {
        'defaultRackWidth': 18,
        'defaultRackHeight': 12,
        'defaultWeanDate': 21,
        'useEid': true,
      };

      final dto = LabSettingStoreDto.fromJson(json);

      expect(dto.useEid, true);
    });

    test('should parse useEid as false from JSON', () {
      final json = {
        'defaultRackWidth': 18,
        'defaultRackHeight': 12,
        'defaultWeanDate': 21,
        'useEid': false,
      };

      final dto = LabSettingStoreDto.fromJson(json);

      expect(dto.useEid, false);
    });

    test('should default useEid to false when missing from JSON', () {
      final json = {
        'defaultRackWidth': 18,
        'defaultRackHeight': 12,
        'defaultWeanDate': 21,
      };

      final dto = LabSettingStoreDto.fromJson(json);

      expect(dto.useEid, false);
    });

    test('should default useEid to false when null in JSON', () {
      final json = {
        'defaultRackWidth': 18,
        'defaultRackHeight': 12,
        'defaultWeanDate': 21,
        'useEid': null,
      };

      final dto = LabSettingStoreDto.fromJson(json);

      expect(dto.useEid, false);
    });

    test('should serialize useEid to JSON', () {
      final dto = LabSettingStoreDto(
        defaultRackWidth: 18,
        defaultRackHeight: 12,
        defaultWeanDate: 21,
        useEid: true,
      );

      final json = dto.toJson();

      expect(json['useEid'], true);
    });
  });

  group('SettingDto', () {
    test('should parse labSetting with useEid from JSON', () {
      final json = {
        'accountSetting': {
          'enableDailyReport': false,
          'onboardingTour': false,
          'animalCreationTour': false,
          'useComment': true,
          'enableCustomWeanDate': true,
        },
        'labSetting': {
          'defaultRackWidth': 18,
          'defaultRackHeight': 12,
          'defaultWeanDate': 21,
          'useEid': true,
        },
      };

      final dto = SettingDto.fromJson(json);

      expect(dto.labSetting.useEid, true);
    });

    test('should default labSetting useEid to false when labSetting is null', () {
      final json = {
        'accountSetting': null,
        'labSetting': null,
      };

      final dto = SettingDto.fromJson(json);

      expect(dto.labSetting.useEid, false);
    });
  });
}
