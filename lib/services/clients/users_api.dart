import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';
import 'package:moustra/services/dtos/user_detail_dto.dart';
import 'package:moustra/services/utils/safe_json_converter.dart';

class UsersApi {
  final DioApiClient apiClient;

  UsersApi(this.apiClient);

  Future<List<UserListDto>> getUsers() async {
    final res = await apiClient.get('/lab/user');
    if (res.statusCode != 200) {
      throw Exception('Failed to get users: ${res.data}');
    }
    final List<dynamic> jsonList = res.data as List<dynamic>;
    return jsonList
        .map(
          (json) => safeFromJson<UserListDto>(
            json: json as Map<String, dynamic>,
            fromJson: UserListDto.fromJson,
            dtoName: 'UserListDto',
          ),
        )
        .toList();
  }

  Future<UserDetailDto> getUser(String accountUuid) async {
    final res = await apiClient.get('/lab/user/$accountUuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get user: ${res.data}');
    }
    return UserDetailDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future updateUser(String accountUuid, PutUserDetailDto userData) async {
    final res = await apiClient.put('/lab/user/$accountUuid', body: userData);
    if (res.statusCode != 200) {
      throw Exception('Failed to update user: ${res.data}');
    }
    return;
  }

  Future createUser(String accountUuid, PostUserDetailDto userData) async {
    final res = await apiClient.post('/lab/user', body: userData);
    if (res.statusCode != 201) {
      throw Exception('Failed to create user: ${res.data}');
    }
    return;
  }
}
