class AppConstants {
  AppConstants._();

  static const String appName = 'Bitaqati As-Sihiya';
  static const String appNameArabic = 'بطاقتي الصحية';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String packageName = 'com.bitaqati.sihiya';

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration sosTimeout = Duration(seconds: 5);
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  static const int maxLoginAttempts = 5;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int nearbyHospitalRadiusKm = 10;
  static const int sosAutoCancelMinutes = 30;

  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm';
  static const String arabicDateFormat = 'yyyy/MM/dd';

  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  static const int animationDurationMs = 300;
  static const int debounceMilliseconds = 500;
}
