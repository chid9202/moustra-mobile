import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grid_view/models/login_response.dart';

class SessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final ValueNotifier<bool> onboardedNotifier = ValueNotifier<bool>(false);

  String? accountUuid;
  String? labUuid;
  String? labName;
  bool onboarded = false;
  String? firstName;
  String? lastName;
  String? email;
  String? position;
  String? role;

  Future<void> saveLoginResponse(LoginResponse response) async {
    accountUuid = response.accountUuid;
    labUuid = response.labUuid;
    labName = response.labName;
    onboarded = response.onboarded;
    firstName = response.firstName;
    lastName = response.lastName;
    email = response.email;
    position = response.position;
    role = response.role;

    onboardedNotifier.value = onboarded;

    await _storage.write(key: 'accountUuid', value: response.accountUuid);
    await _storage.write(key: 'labUuid', value: response.labUuid);
    await _storage.write(key: 'labName', value: response.labName);
    await _storage.write(
        key: 'onboarded', value: response.onboarded.toString());
    await _storage.write(key: 'firstName', value: response.firstName);
    await _storage.write(key: 'lastName', value: response.lastName);
    await _storage.write(key: 'email', value: response.email);
    await _storage.write(key: 'position', value: response.position);
    await _storage.write(key: 'role', value: response.role);
  }

  Future<bool> loadSession() async {
    accountUuid = await _storage.read(key: 'accountUuid');
    if (accountUuid == null) return false;

    labUuid = await _storage.read(key: 'labUuid');
    labName = await _storage.read(key: 'labName');
    final onboardedStr = await _storage.read(key: 'onboarded');
    onboarded = onboardedStr == 'true';
    firstName = await _storage.read(key: 'firstName');
    lastName = await _storage.read(key: 'lastName');
    email = await _storage.read(key: 'email');
    position = await _storage.read(key: 'position');
    role = await _storage.read(key: 'role');

    onboardedNotifier.value = onboarded;
    return true;
  }

  Future<void> clearSession() async {
    accountUuid = null;
    labUuid = null;
    labName = null;
    onboarded = false;
    firstName = null;
    lastName = null;
    email = null;
    position = null;
    role = null;

    onboardedNotifier.value = false;

    await _storage.deleteAll();
  }

  Future<void> setOnboarded(bool value) async {
    onboarded = value;
    onboardedNotifier.value = value;
    await _storage.write(key: 'onboarded', value: value.toString());
  }
}

final SessionService sessionService = SessionService();
