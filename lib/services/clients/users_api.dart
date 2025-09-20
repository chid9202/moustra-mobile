import 'dart:convert';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';

class UsersApi {
  final ApiClient apiClient;

  UsersApi(this.apiClient);

  Future<List<UserListDto>> getUsers() async {
    final res = await apiClient.get('/lab/user');
    if (res.statusCode != 200) {
      throw Exception('Failed to get users: ${res.body}');
    }
    final List<dynamic> jsonList = jsonDecode(res.body);
    return jsonList
        .map((json) => UserListDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
