import 'package:moustra/services/clients/dio_api_client.dart';

class OnboardingApi {
  Future<void> putLabName(String labName) async {
    await dioApiClient.put('/lab', body: {'labName': labName});
  }

  Future<void> putAccountOnboarded(
    String accountUuid, {
    String? position,
    String? firstName,
    String? lastName,
  }) async {
    await dioApiClient.put('/lab/user/$accountUuid', body: {
      'accountUuid': accountUuid,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'onboarded': true,
    });
  }

  Future<void> inviteUser(String email) async {
    await dioApiClient.post('/lab/user', body: {
      'firstName': '',
      'lastName': '',
      'email': email,
      'role': 'USER',
      'isActive': true,
      'accountUuid': '',
    });
  }

  Future<void> postSampleData() async {
    await dioApiClient.post('/sample-data', body: {});
  }
}

final onboardingApi = OnboardingApi();
