import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

class LocalStorage {
  static SharedPreferences? _prefs;

  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _lastSyncKey = 'last_sync';

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await _instance;
    await prefs.setString(_themeModeKey, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_themeModeKey);
  }

  Future<void> setLocale(String locale) async {
    final prefs = await _instance;
    await prefs.setString(_localeKey, locale);
  }

  Future<String?> getLocale() async {
    final prefs = await _instance;
    return prefs.getString(_localeKey);
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await _instance;
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await _instance;
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _instance;
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await _instance;
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setLastSync(DateTime dateTime) async {
    final prefs = await _instance;
    await prefs.setString(_lastSyncKey, dateTime.toIso8601String());
  }

  Future<DateTime?> getLastSync() async {
    final prefs = await _instance;
    final value = prefs.getString(_lastSyncKey);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
