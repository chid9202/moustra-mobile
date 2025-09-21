import 'dart:convert';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';
import 'package:moustra/services/dtos/user_detail_dto.dart';

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

  Future<UserDetailDto> getUser(String accountUuid) async {
    final res = await apiClient.get('/lab/user/$accountUuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get user: ${res.body}');
    }
    return UserDetailDto.fromJson(jsonDecode(res.body));
  }

  Future updateUser(String accountUuid, PutUserDetailDto userData) async {
    final res = await apiClient.put('/lab/user/$accountUuid', body: userData);
    if (res.statusCode != 200) {
      throw Exception('Failed to update user: ${res.body}');
    }
    return;
  }

  Future createUser(String accountUuid, PostUserDetailDto userData) async {
    final res = await apiClient.post('/lab/user', body: userData);
    if (res.statusCode != 201) {
      throw Exception('Failed to create user: ${res.body}');
    }
    return;
  }
}
