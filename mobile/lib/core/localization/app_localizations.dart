import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/storage/local_storage.dart';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return LocaleNotifier(localStorage);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final LocalStorage _localStorage;

  LocaleNotifier(this._localStorage) : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await _localStorage.getLocale();
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _localStorage.setLocale(languageCode);
  }

  void toggleLanguage() {
    if (state.languageCode == 'ar') {
      setLocale('en');
    } else {
      setLocale('ar');
    }
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  String get appName => _translate('app_name');
  String get appTitle => _translate('app_title');
  String get ok => _translate('ok');
  String get cancel => _translate('cancel');
  String get confirm => _translate('confirm');
  String get save => _translate('save');
  String get delete => _translate('delete');
  String get edit => _translate('edit');
  String get update => _translate('update');
  String get submit => _translate('submit');
  String get retry => _translate('retry');
  String get loading => _translate('loading');
  String get noData => _translate('no_data');
  String get search => _translate('search');
  String get filter => _translate('filter');
  String get sort => _translate('sort');
  String get more => _translate('more');
  String get close => _translate('close');
  String get back => _translate('back');
  String get next => _translate('next');
  String get skip => _translate('skip');
  String get done => _translate('done');
  String get error => _translate('error');
  String get success => _translate('success');
  String get warning => _translate('warning');
  String get info => _translate('info');
  String get confirmAction => _translate('confirm_action');
  String get yes => _translate('yes');
  String get no => _translate('no');
  String get tryAgain => _translate('try_again');
  String get login => _translate('login');
  String get logout => _translate('logout');
  String get register => _translate('register');
  String get email => _translate('email');
  String get password => _translate('password');
  String get notificationSettings => _translate('notification_settings');
  String get confirmPassword => _translate('confirm_password');
  String get forgotPassword => _translate('forgot_password');
  String get resetPassword => _translate('reset_password');
  String get nationalId => _translate('national_id');
  String get phoneNumber => _translate('phone_number');
  String get firstName => _translate('first_name');
  String get lastName => _translate('last_name');
  String get dateOfBirth => _translate('date_of_birth');
  String get rolePatient => _translate('role_patient');
  String get roleGuardian => _translate('role_guardian');
  String get loginAsPatient => _translate('login_as_patient');
  String get loginAsGuardian => _translate('login_as_guardian');
  String get registerAsPatient => _translate('register_as_patient');
  String get registerAsGuardian => _translate('register_as_guardian');
  String get dontHaveAccount => _translate('dont_have_account');
  String get alreadyHaveAccount => _translate('already_have_account');
  String get loginError => _translate('login_error');
  String get loginSuccess => _translate('login_success');
  String get registerSuccess => _translate('register_success');
  String get logoutConfirm => _translate('logout_confirm');
  String get passwordRequirements => _translate('password_requirements');
  String get home => _translate('home');
  String get welcomeBack => _translate('welcome_back');
  String get todayHealthSummary => _translate('today_health_summary');
  String get nationalIdLabel => _translate('national_id_label');
  String get profileCompleteMsg => _translate('profile_complete_msg');
  String get completeProfileButtonLabel => _translate('complete_profile_button');
  String get profileIncompleteMsg => _translate('profile_incomplete_msg');
  String get healthStatus => _translate('health_status');
  String get quickActions => _translate('quick_actions');
  String get recentActivity => _translate('recent_activity');
  String get viewAll => _translate('view_all');
  String get healthCard => _translate('health_card');
  String get myHealthCard => _translate('my_health_card');
  String get patientHealthCard => _translate('patient_health_card');
  String get cardNumber => _translate('card_number');
  String get cardHolder => _translate('card_holder');
  String get bloodType => _translate('blood_type');
  String get allergies => _translate('allergies');
  String get chronicDiseases => _translate('chronic_diseases');
  String get emergencyContact => _translate('emergency_contact');
  String get validUntil => _translate('valid_until');
  String get issuedBy => _translate('issued_by');
  String get ministryOfHealth => _translate('ministry_of_health');
  String get qrCode => _translate('qr_code');
  String get scanQr => _translate('scan_qr');
  String get shareCard => _translate('share_card');
  String get downloadCard => _translate('download_card');
  String get medicalRecord => _translate('medical_record');
  String get medicalHistory => _translate('medical_history');
  String get diagnosis => _translate('diagnosis');
  String get medications => _translate('medications');
  String get vaccinations => _translate('vaccinations');
  String get labResults => _translate('lab_results');
  String get vitalSigns => _translate('vital_signs');
  String get doctorNotes => _translate('doctor_notes');
  String get prescriptions => _translate('prescriptions');
  String get surgeries => _translate('surgeries');
  String get familyHistory => _translate('family_history');
  String get sos => _translate('sos');
  String get emergency => _translate('emergency');
  String get sosTitle => _translate('sos_title');
  String get sosDescription => _translate('sos_description');
  String get sosActivated => _translate('sos_activated');
  String get sosCancelled => _translate('sos_cancelled');
  String get sosSending => _translate('sos_sending');
  String get emergencyMode => _translate('emergency_mode');
  String get emergencyContacts => _translate('emergency_contacts');
  String get emergencyHistory => _translate('emergency_history');
  String get cancelSos => _translate('cancel_sos');
  String get gpsEnabled => _translate('gps_enabled');
  String get gpsDisabled => _translate('gps_disabled');
  String get guardiansNotified => _translate('guardians_notified');
  String get nearbyHospitals => _translate('nearby_hospitals');
  String get hospitals => _translate('hospitals');
  String get call => _translate('call');
  String get navigate => _translate('navigate');
  String get distance => _translate('distance');
  String get openNow => _translate('open_now');
  String get closed => _translate('closed');
  String get notifications => _translate('notifications');
  String get settings => _translate('settings');
  String get language => _translate('language');
  String get arabic => _translate('arabic');
  String get english => _translate('english');
  String get darkMode => _translate('dark_mode');
  String get lightMode => _translate('light_mode');
  String get theme => _translate('theme');
  String get about => _translate('about');
  String get appVersion => _translate('app_version');
  String get privacyPolicy => _translate('privacy_policy');
  String get termsOfService => _translate('terms_of_service');
  String get contactUs => _translate('contact_us');
  String get rateApp => _translate('rate_app');
  String get shareApp => _translate('share_app');
  String get deleteAccount => _translate('delete_account');
  String get deleteAccountConfirm => _translate('delete_account_confirm');
  String get fieldRequired => _translate('field_required');
  String get invalidEmail => _translate('invalid_email');
  String get invalidPhone => _translate('invalid_phone');
  String get invalidNationalId => _translate('invalid_national_id');
  String get passwordTooShort => _translate('password_too_short');
  String get passwordsDoNotMatch => _translate('passwords_do_not_match');
  String get invalidPassword => _translate('invalid_password');
  String get serverError => _translate('server_error');
  String get networkError => _translate('network_error');
  String get unauthorized => _translate('unauthorized');
  String get notFound => _translate('not_found');
  String get timeoutError => _translate('timeout_error');
  String get unknownError => _translate('unknown_error');
  String get onboardingTitle1 => _translate('onboarding_title_1');
  String get onboardingSubtitle1 => _translate('onboarding_subtitle_1');
  String get onboardingTitle2 => _translate('onboarding_title_2');
  String get onboardingSubtitle2 => _translate('onboarding_subtitle_2');
  String get onboardingTitle3 => _translate('onboarding_title_3');
  String get onboardingSubtitle3 => _translate('onboarding_subtitle_3');
  String get getStarted => _translate('get_started');
  String get files => _translate('files');
  String get myFiles => _translate('my_files');
  String get uploadFile => _translate('upload_file');
  String get noFiles => _translate('no_files');
  String get profile => _translate('profile');
  String get editProfile => _translate('edit_profile');
  String get guardianCode => _translate('guardian_code');
  String get patientCode => _translate('patient_code');
  String get relationship => _translate('relationship');
  String get linkPatient => _translate('link_patient');
  String get myPatients => _translate('my_patients');
  String get selectPatient => _translate('select_patient');
  String get patientCodeHint => _translate('patient_code_hint');
  String get noNotifications => _translate('no_notifications');
  String get noHospitalsFound => _translate('no_hospitals_found');
  String get noEmergencyHistory => _translate('no_emergency_history');
  String get hospitalDetails => _translate('hospital_details');

  String _translate(String key) {
    final translations = locale.languageCode == 'ar' ? _arTranslations : _enTranslations;
    return translations[key] ?? key;
  }

  static const Map<String, String> _enTranslations = {
    'app_name': 'Bitaqati As-Sihiya',
    'app_title': 'My Health Card',
    'ok': 'OK',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'update': 'Update',
    'submit': 'Submit',
    'retry': 'Retry',
    'loading': 'Loading...',
    'no_data': 'No data available',
    'search': 'Search',
    'filter': 'Filter',
    'sort': 'Sort',
    'more': 'More',
    'close': 'Close',
    'back': 'Back',
    'next': 'Next',
    'skip': 'Skip',
    'done': 'Done',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Information',
    'confirm_action': 'Are you sure?',
    'yes': 'Yes',
    'no': 'No',
    'try_again': 'Try Again',
    'login': 'Login',
    'logout': 'Logout',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'forgot_password': 'Forgot Password?',
    'reset_password': 'Reset Password',
    'national_id': 'National ID',
    'phone_number': 'Phone Number',
    'first_name': 'First Name',
    'last_name': 'Last Name',
    'date_of_birth': 'Date of Birth',
    'role_patient': 'Patient',
    'role_guardian': 'Guardian',
    'login_as_patient': 'Login as Patient',
    'login_as_guardian': 'Login as Guardian',
    'register_as_patient': 'Register as Patient',
    'register_as_guardian': 'Register as Guardian',
    'dont_have_account': 'Don\'t have an account?',
    'already_have_account': 'Already have an account?',
    'login_error': 'Invalid credentials. Please try again.',
    'login_success': 'Login successful!',
    'register_success': 'Registration successful!',
    'logout_confirm': 'Are you sure you want to logout?',
    'password_requirements': 'Password must be at least 8 characters',
    'home': 'Home',
    'welcome_back': 'Welcome back,',
    'health_status': 'Health Status',
    'quick_actions': 'Quick Actions',
    'recent_activity': 'Recent Activity',
    'view_all': 'View All',
    'health_card': 'Health Card',
    'my_health_card': 'My Health Card',
    'patient_health_card': 'Patient Health Card',
    'card_number': 'Card Number',
    'card_holder': 'Card Holder',
    'blood_type': 'Blood Type',
    'allergies': 'Allergies',
    'chronic_diseases': 'Chronic Diseases',
    'emergency_contact': 'Emergency Contact',
    'valid_until': 'Valid Until',
    'issued_by': 'Issued By',
    'ministry_of_health': 'Ministry of Health',
    'qr_code': 'QR Code',
    'scan_qr': 'Scan QR to view patient info',
    'share_card': 'Share Card',
    'download_card': 'Download Card',
    'medical_record': 'Medical Record',
    'medical_history': 'Medical History',
    'diagnosis': 'Diagnosis',
    'medications': 'Medications',
    'vaccinations': 'Vaccinations',
    'lab_results': 'Lab Results',
    'vital_signs': 'Vital Signs',
    'doctor_notes': 'Doctor Notes',
    'prescriptions': 'Prescriptions',
    'surgeries': 'Surgeries',
    'family_history': 'Family History',
    'sos': 'SOS',
    'emergency': 'Emergency',
    'sos_title': 'SOS Emergency',
    'sos_description': 'Press the button below to send an emergency alert to your guardians and nearby hospitals.',
    'sos_activated': 'SOS Alert Activated!',
    'sos_cancelled': 'SOS Alert Cancelled',
    'sos_sending': 'Sending emergency alert...',
    'emergency_mode': 'Emergency Mode Active',
    'emergency_contacts': 'Emergency Contacts',
    'emergency_history': 'Emergency History',
    'cancel_sos': 'Cancel SOS',
    'gps_enabled': 'GPS Enabled',
    'gps_disabled': 'GPS Disabled',
    'guardians_notified': 'Guardians notified',
    'nearby_hospitals': 'Nearby Hospitals',
    'hospitals': 'Hospitals',
    'call': 'Call',
    'navigate': 'Navigate',
    'distance': 'Distance',
    'open_now': 'Open Now',
    'closed': 'Closed',
    'notifications': 'Notifications',
    'settings': 'Settings',
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'theme': 'Theme',
    'about': 'About',
    'app_version': 'App Version',
    'privacy_policy': 'Privacy Policy',
    'terms_of_service': 'Terms of Service',
    'contact_us': 'Contact Us',
    'rate_app': 'Rate App',
    'share_app': 'Share App',
    'delete_account': 'Delete Account',
    'delete_account_confirm': 'Are you sure you want to delete your account? This action cannot be undone.',
    'field_required': 'This field is required',
    'invalid_email': 'Please enter a valid email address',
    'invalid_phone': 'Please enter a valid phone number',
    'invalid_national_id': 'Please enter a valid National ID (10 digits)',
    'password_too_short': 'Password must be at least 8 characters',
    'passwords_do_not_match': 'Passwords do not match',
    'invalid_password': 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
    'server_error': 'Server error occurred. Please try again later.',
    'network_error': 'No internet connection. Please check your connection.',
    'unauthorized': 'Session expired. Please login again.',
    'not_found': 'Resource not found.',
    'timeout_error': 'Request timed out. Please try again.',
    'unknown_error': 'Something went wrong. Please try again.',
    'onboarding_title_1': 'Welcome to Bitaqati As-Sihiya',
    'onboarding_subtitle_1': 'Your digital health card, always with you.',
    'onboarding_title_2': 'Instant Emergency Alerts',
    'onboarding_subtitle_2': 'Send your location to guardians and hospitals with one tap.',
    'onboarding_title_3': 'Complete Medical History',
    'onboarding_subtitle_3': 'Access your medical records anytime, anywhere.',
    'get_started': 'Get Started',
    'files': 'Files',
    'my_files': 'My Files',
    'upload_file': 'Upload File',
    'no_files': 'No files uploaded yet',
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'guardian_code': 'Guardian Code',
    'patient_code': 'Patient Code',
    'relationship': 'Relationship',
    'link_patient': 'Link Patient',
    'my_patients': 'My Patients',
    'select_patient': 'Select Patient',
    'patient_code_hint': 'Enter the patient\'s code',
    'no_notifications': 'No notifications',
    'no_hospitals_found': 'No hospitals found nearby',
    'no_emergency_history': 'No emergency history',
    'hospital_details': 'Hospital Details',
        'today_health_summary': 'Here is a summary of your health status today',
    'national_id_label': 'National ID',
    'profile_complete_msg':
        'Your medical profile is complete. You can use the SOS button and health card with confidence.',
    'profile_incomplete_msg':
        'Once your medical profile is complete, additional information and the SOS button will appear here.',
    'notification_settings': 'Notification Settings',
    'complete_profile_button': 'Complete medical profile',
  };

  static const Map<String, String> _arTranslations = {
    'app_name': 'بطاقتي الصحية',
    'app_title': 'بطاقتي الصحية',
    'ok': 'موافق',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'update': 'تحديث',
    'submit': 'إرسال',
    'retry': 'إعادة المحاولة',
    'loading': 'جار التحميل...',
    'no_data': 'لا توجد بيانات',
    'search': 'بحث',
    'filter': 'تصفية',
    'sort': 'ترتيب',
    'more': 'المزيد',
    'close': 'إغلاق',
    'back': 'رجوع',
    'next': 'التالي',
    'skip': 'تخطي',
    'done': 'تم',
    'error': 'خطأ',
    'success': 'نجاح',
    'warning': 'تحذير',
    'info': 'معلومات',
    'confirm_action': 'هل أنت متأكد؟',
    'yes': 'نعم',
    'no': 'لا',
    'try_again': 'حاول مرة أخرى',
    'login': 'تسجيل الدخول',
    'logout': 'تسجيل الخروج',
    'register': 'تسجيل',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'confirm_password': 'تأكيد كلمة المرور',
    'forgot_password': 'نسيت كلمة المرور؟',
    'reset_password': 'إعادة تعيين كلمة المرور',
    'national_id': 'الرقم الوطني',
    'phone_number': 'رقم الهاتف',
    'first_name': 'الاسم الأول',
    'last_name': 'اسم العائلة',
    'date_of_birth': 'تاريخ الميلاد',
    'role_patient': 'مريض',
    'role_guardian': 'ولي أمر',
    'login_as_patient': 'تسجيل دخول كمريض',
    'login_as_guardian': 'تسجيل دخول كولي أمر',
    'register_as_patient': 'تسجيل كمريض',
    'register_as_guardian': 'تسجيل كولي أمر',
    'dont_have_account': 'ليس لديك حساب؟',
    'already_have_account': 'لديك حساب بالفعل؟',
    'login_error': 'بيانات الدخول غير صحيحة. حاول مرة أخرى.',
    'login_success': 'تم تسجيل الدخول بنجاح!',
    'register_success': 'تم التسجيل بنجاح!',
    'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
    'password_requirements': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
    'home': 'الرئيسية',
    'welcome_back': 'مرحباً بعودتك،',
    'health_status': 'الحالة الصحية',
    'quick_actions': 'إجراءات سريعة',
    'recent_activity': 'النشاط الأخير',
    'view_all': 'عرض الكل',
    'health_card': 'البطاقة الصحية',
    'my_health_card': 'بطاقتي الصحية',
    'patient_health_card': 'البطاقة الصحية للمريض',
    'card_number': 'رقم البطاقة',
    'card_holder': 'حامل البطاقة',
    'blood_type': 'فصيلة الدم',
    'allergies': 'الحساسية',
    'chronic_diseases': 'الأمراض المزمنة',
    'emergency_contact': 'جهة اتصال طارئة',
    'valid_until': 'صالحة حتى',
    'issued_by': 'صادرة عن',
    'ministry_of_health': 'وزارة الصحة',
    'qr_code': 'رمز QR',
    'scan_qr': 'امسح QR لعرض معلومات المريض',
    'share_card': 'مشاركة البطاقة',
    'download_card': 'تحميل البطاقة',
    'medical_record': 'السجل الطبي',
    'medical_history': 'التاريخ الطبي',
    'diagnosis': 'التشخيص',
    'medications': 'الأدوية',
    'vaccinations': 'التطعيمات',
    'lab_results': 'نتائج المختبر',
    'vital_signs': 'العلامات الحيوية',
    'doctor_notes': 'ملاحظات الطبيب',
    'prescriptions': 'الوصفات الطبية',
    'surgeries': 'العمليات الجراحية',
    'family_history': 'التاريخ العائلي',
    'sos': 'SOS',
    'emergency': 'طوارئ',
    'sos_title': 'تنبيه طارئ',
    'sos_description': 'اضغط على الزر أدناه لإرسال تنبيه طارئ إلى أولياء أمورك والمستشفيات القريبة.',
    'sos_activated': 'تم تفعيل التنبيه الطارئ!',
    'sos_cancelled': 'تم إلغاء التنبيه الطارئ',
    'sos_sending': 'جار إرسال التنبيه الطارئ...',
    'emergency_mode': 'وضع الطوارئ نشط',
    'emergency_contacts': 'جهات الاتصال الطارئة',
    'emergency_history': 'سجل الطوارئ',
    'cancel_sos': 'إلغاء SOS',
    'gps_enabled': 'GPS مفعل',
    'gps_disabled': 'GPS معطل',
    'guardians_notified': 'تم إبلاغ أولياء الأمور',
    'nearby_hospitals': 'المستشفيات القريبة',
    'hospitals': 'المستشفيات',
    'call': 'اتصال',
    'navigate': 'تنقل',
    'distance': 'المسافة',
    'open_now': 'مفتوح الآن',
    'closed': 'مغلق',
    'notifications': 'الإشعارات',
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'dark_mode': 'الوضع الداكن',
    'light_mode': 'الوضع الفاتح',
    'theme': 'المظهر',
    'about': 'حول',
    'app_version': 'إصدار التطبيق',
    'privacy_policy': 'سياسة الخصوصية',
    'terms_of_service': 'شروط الخدمة',
    'contact_us': 'اتصل بنا',
    'rate_app': 'تقييم التطبيق',
    'share_app': 'مشاركة التطبيق',
    'delete_account': 'حذف الحساب',
    'delete_account_confirm': 'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
    'field_required': 'هذا الحقل مطلوب',
    'invalid_email': 'يرجى إدخال بريد إلكتروني صحيح',
    'invalid_phone': 'يرجى إدخال رقم هاتف صحيح',
    'invalid_national_id': 'يرجى إدخال رقم وطني صحيح (10 أرقام)',
    'password_too_short': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',
    'passwords_do_not_match': 'كلمتا المرور غير متطابقتين',
    'invalid_password': 'يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير ورقم واحد على الأقل',
    'server_error': 'حدث خطأ في الخادم. حاول مرة أخرى لاحقاً.',
    'network_error': 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك.',
    'unauthorized': 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
    'not_found': 'المورد غير موجود.',
    'timeout_error': 'انتهت مهلة الطلب. حاول مرة أخرى.',
    'unknown_error': 'حدث خطأ ما. حاول مرة أخرى.',
    'onboarding_title_1': 'مرحباً بك في بطاقتي الصحية',
    'onboarding_subtitle_1': 'بطاقتك الصحية الرقمية، دائماً معك.',
    'onboarding_title_2': 'تنبيهات طارئة فورية',
    'onboarding_subtitle_2': 'أرسل موقعك إلى أولياء الأمور والمستشفيات بنقرة واحدة.',
    'onboarding_title_3': 'سجل طبي كامل',
    'onboarding_subtitle_3': 'اطلع على سجلاتك الطبية في أي وقت ومن أي مكان.',
    'get_started': 'ابدأ الآن',
    'files': 'الملفات',
    'my_files': 'ملفاتي',
    'upload_file': 'رفع ملف',
    'no_files': 'لم يتم رفع أي ملفات بعد',
    'profile': 'الملف الشخصي',
    'edit_profile': 'تعديل الملف الشخصي',
    'guardian_code': 'رمز ولي الأمر',
    'patient_code': 'رمز المريض',
    'relationship': 'صلة القرابة',
    'link_patient': 'ربط مريض',
    'my_patients': 'مرضاي',
    'select_patient': 'اختر مريض',
    'patient_code_hint': 'أدخل رمز المريض',
    'no_notifications': 'لا توجد إشعارات',
    'no_hospitals_found': 'لا توجد مستشفيات قريبة',
    'no_emergency_history': 'لا يوجد سجل طوارئ',
    'hospital_details': 'تفاصيل المستشفى',
        'today_health_summary': 'هذا ملخص حالتك الصحية اليوم',
    'national_id_label': 'الرقم الوطني',
    'profile_complete_msg':
        'ملفك الطبي مكتمل، يمكنك استخدام زر SOS والبطاقة الصحية بثقة.',
    'profile_incomplete_msg':
        'عند استكمال ملفك الطبي ستظهر هنا معلومات إضافية وزر SOS.',
    'notification_settings': 'إعدادات الإشعارات',
    'complete_profile_button': 'استكمال الملف الطبي',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
