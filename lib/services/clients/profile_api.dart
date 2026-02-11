import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/profile_dto.dart';

class ProfileApi {
  Future<ProfileResponseDto> getProfile(ProfileRequestDto body) async {
    final res = await apiClient.post(
      'auth/callback',
      body: body,
      withoutAccountPrefix: true,
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Login failed. The server returned an error (${res.statusCode}). Please try again.',
      );
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return ProfileResponseDto.fromJson(data);
  }
}

final ProfileApi profileService = ProfileApi();
