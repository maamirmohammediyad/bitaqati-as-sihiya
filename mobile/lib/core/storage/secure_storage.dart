import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _loginTimestampKey = 'login_timestamp';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  Future<void> saveLoginTimestamp(DateTime time) async {
    await _storage.write(
      key: _loginTimestampKey,
      value: time.toIso8601String(),
    );
  }

  Future<DateTime?> getLoginTimestamp() async {
    final value = await _storage.read(key: _loginTimestampKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> deleteLoginTimestamp() async {
    await _storage.delete(key: _loginTimestampKey);
  }
    static const _userJsonKey = 'user_json';

  Future<void> saveUserJson(String userJson) async {
    await _storage.write(key: _userJsonKey, value: userJson);
  }

  Future<String?> getUserJson() async {
    return await _storage.read(key: _userJsonKey);
  }

  Future<void> deleteUserJson() async {
    await _storage.delete(key: _userJsonKey);
  }
}