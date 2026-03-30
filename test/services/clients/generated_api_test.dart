import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/clients/generated_api.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

void main() {
  setUpAll(() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      await dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  group('GeneratedApi', () {
    late ProfileResponseDto? previous;

    setUp(() {
      previous = profileState.value;
    });

    tearDown(() {
      profileState.value = previous;
    });

    test('accountUuid is empty when profile is null', () {
      profileState.value = null;
      final api = GeneratedApi();
      expect(api.accountUuid, '');
    });

    test('accountUuid reads profile store', () {
      profileState.value = ProfileResponseDto(
        accountUuid: 'acc-test-uuid',
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        labName: 'Lab',
        labUuid: 'lab-1',
        onboarded: true,
        onboardedDate: null,
        position: null,
        role: 'User',
        plan: 'free',
      );
      final api = GeneratedApi();
      expect(api.accountUuid, 'acc-test-uuid');
    });
  });
}
