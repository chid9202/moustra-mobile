import 'dart:convert';

import 'package:grid_view/models/account.dart';
import 'package:grid_view/services/api_client.dart';

class AccountService {
  Future<AccountDetail> getAccount(String accountUuid) async {
    final response = await apiClient.get('/lab/user/$accountUuid');
    if (response.statusCode != 200) {
      throw Exception('Failed to get account: ${response.statusCode}');
    }
    return AccountDetail.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> putAccount(String accountUuid, Map<String, dynamic> body) async {
    final response = await apiClient.put('/lab/user/$accountUuid', body: body);
    if (response.statusCode != 200) {
      throw Exception('Failed to update account: ${response.statusCode}');
    }
  }

  Future<void> putLab(String labName) async {
    final response = await apiClient.put('/lab', body: {'labName': labName});
    if (response.statusCode != 200) {
      throw Exception('Failed to update lab: ${response.statusCode}');
    }
  }

  Future<void> postInviteUser(String email) async {
    final response = await apiClient.post('/lab/user', body: {
      'firstName': '',
      'lastName': '',
      'email': email,
      'role': 'USER',
      'isActive': true,
    });
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to invite user: ${response.statusCode}');
    }
  }
}

final AccountService accountService = AccountService();
