# Flutter Architecture & Folder Structure

## State Management: Riverpod 2.x

**Why Riverpod over BLoC:**
- Compile-time safety (no runtime `context.read` errors)
- No `BuildContext` dependency — providers work anywhere
- Simpler boilerplate than BLoC (no separate Event/State classes for simple states)
- Built-in caching, auto-dispose, and dependency injection
- Easier testing (override providers directly)
- Better for a solo developer — less ceremony

## Folder Structure

```
mobile/
├── lib/
│   ├── main.dart                          # App entry, ProviderScope
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart         # Base URL, endpoints
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   └── asset_paths.dart
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart            # Dio instance, interceptors
│   │   │   ├── api_exceptions.dart        # Custom exception classes
│   │   │   └── network_info.dart          # Connectivity check
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage.dart        # Token storage
│   │   │   └── local_storage.dart         # SharedPreferences wrapper
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Light & dark themes
│   │   │   ├── app_colors.dart            # Color palette
│   │   │   ├── app_text_styles.dart       # Typography
│   │   │   └── glassmorphism.dart         # Glass card decoration
│   │   │
│   │   ├── localization/
│   │   │   ├── app_localizations.dart     # Generated l10n class
│   │   │   ├── app_localizations_en.dart  # English strings
│   │   │   ├── app_localizations_ar.dart  # Arabic strings
│   │   │   └── l10n/
│   │   │       ├── app_en.arb
│   │   │       └── app_ar.arb
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart            # Form validators
│   │   │   ├── date_formatter.dart
│   │   │   ├── permission_helper.dart     # GPS, camera permissions
│   │   │   └── qr_helper.dart
│   │   │
│   │   └── router/
│   │       └── app_router.dart            # GoRouter configuration
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── login_request.g.dart
│   │   │   │   │   ├── login_response.g.dart
│   │   │   │   │   ├── register_patient_request.g.dart
│   │   │   │   │   └── register_guardian_request.g.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart   # abstract
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── register_patient_usecase.dart
│   │   │   │       └── register_guardian_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── auth_provider.dart     # StateNotifierProvider
│   │   │       │   └── auth_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_patient_screen.dart
│   │   │       │   ├── register_guardian_screen.dart
│   │   │       │   └── onboarding_screen.dart
│   │   │       └── widgets/
│   │   │           ├── role_selector.dart
│   │   │           └── patient_code_field.dart
│   │   │
│   │   ├── patient/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── patient_profile_model.g.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── patient_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── patient_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── patient_profile.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── patient_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_profile_usecase.dart
│   │   │   │       ├── complete_profile_usecase.dart
│   │   │   │       └── update_profile_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── patient_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── patient_dashboard.dart
│   │   │       │   └── complete_profile_screen.dart
│   │   │       └── widgets/
│   │   │           ├── health_card.dart
│   │   │           └── profile_header.dart
│   │   │
│   │   ├── guardian/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── linked_patient_model.g.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── guardian_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── guardian_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── linked_patient.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── guardian_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── link_patient_usecase.dart
│   │   │   │       └── get_linked_patients_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── guardian_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── guardian_dashboard.dart
│   │   │       │   └── link_patient_screen.dart
│   │   │       └── widgets/
│   │   │           └── patient_selector_card.dart
│   │   │
│   │   ├── medical_files/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── medical_file_model.g.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── file_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── file_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── medical_file.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── file_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── upload_file_usecase.dart
│   │   │   │       ├── list_files_usecase.dart
│   │   │   │       └── delete_file_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── file_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── medical_files_screen.dart
│   │   │       │   └── file_preview_screen.dart
│   │   │       └── widgets/
│   │   │           ├── file_card.dart
│   │   │           └── upload_bottom_sheet.dart
│   │   │
│   │   ├── emergency/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── emergency_event_model.g.dart
│   │   │   │   │   └── sos_request_model.g.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── emergency_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── emergency_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── emergency_event.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── emergency_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── trigger_sos_usecase.dart
│   │   │   │       └── get_emergency_history_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── emergency_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── sos_screen.dart
│   │   │       │   └── emergency_history_screen.dart
│   │   │       └── widgets/
│   │   │           ├── sos_button.dart
│   │   │           └── emergency_mode_banner.dart
│   │   │
│   │   ├── hospitals/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── hospital_model.g.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── hospital_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── hospital_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── hospital.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── hospital_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       └── find_nearby_hospitals_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── hospital_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── hospitals_screen.dart
│   │   │       │   └── hospital_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── hospital_card.dart
│   │   │           └── hospital_map.dart
│   │   │
│   │   ├── settings/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── settings_screen.dart
│   │   │       └── widgets/
│   │   │           ├── language_selector.dart
│   │   │           └── theme_selector.dart
│   │   │
│   │   └── admin/
│   │       └── presentation/
│   │           └── screens/
│   │               └── admin_dashboard.dart
│   │
│   └── common/
│       └── widgets/
│           ├── glass_card.dart              # Reusable glassmorphism card
│           ├── app_button.dart
│           ├── app_text_field.dart
│           ├── loading_overlay.dart
│           ├── error_dialog.dart
│           ├── empty_state.dart
│           └── avatar_widget.dart
│
├── assets/
│   ├── fonts/
│   │   ├── Cairo/                          # Arabic font
│   │   └── Inter/                          # English/Latin font
│   ├── images/
│   │   ├── logo.svg
│   │   ├── onboarding/
│   │   └── illustrations/
│   └── l10n/
│       ├── app_en.arb
│       └── app_ar.arb
│
├── test/
│   ├── features/
│   │   ├── auth/
│   │   ├── patient/
│   │   └── ...
│   └── core/
│
├── pubspec.yaml
└── analysis_options.yaml
```

## Layer Interaction Pattern

```
Screen (Widget)
    │
    ▼ reads
Provider (StateNotifierProvider / FutureProvider / StreamProvider)
    │
    ▼ calls
UseCase (domain layer)
    │
    ▼ calls
Repository (abstract, domain layer)
    │
    ▼ implements
RepositoryImpl (data layer)
    │
    ▼ calls
RemoteDataSource (API calls via Dio)
    │
    ▼ returns
Model (JSON serializable, data layer)
    │
    ▼ mapped to
Entity (pure Dart, domain layer)
```

## Provider Architecture (Riverpod)

```dart
// === Auth Provider Example ===

// 1. State class
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated(String? message) = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// 2. StateNotifierProvider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerPatientUseCase: ref.read(registerPatientUseCaseProvider),
    registerGuardianUseCase: ref.read(registerGuardianUseCaseProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

// 3. Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterPatientUseCase _registerPatientUseCase;
  // ...

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterPatientUseCase registerPatientUseCase,
    required SecureStorage secureStorage,
  })  : _loginUseCase = loginUseCase,
        _registerPatientUseCase = registerPatientUseCase,
        _secureStorage = secureStorage,
        super(const AuthState.initial());

  Future<void> login(String nationalId, String password) async {
    state = const AuthState.loading();
    final result = await _loginUseCase(nationalId, password);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) {
        _secureStorage.saveToken(user.token);
        state = AuthState.authenticated(user);
      },
    );
  }
}

// 4. Screen usage
final authState = ref.watch(authProvider);
authState.when(
  initial: () => ...,
  loading: () => const LoadingOverlay(),
  authenticated: (user) => PatientDashboard(),
  unauthenticated: (message) => LoginScreen(),
  error: (message) => ErrorDialog(message),
);
```

## Provider Per Feature Pattern

| Feature | Provider(s) | Type |
|---------|------------|------|
| Auth | `authProvider` | `StateNotifierProvider` |
| Patient | `patientProfileProvider` | `FutureProvider.family` |
| Guardian | `linkedPatientsProvider`, `guardianActionProvider` | `FutureProvider`, `StateNotifierProvider` |
| Medical Files | `filesProvider`, `uploadFileProvider` | `FutureProvider.family`, `StateNotifierProvider` |
| Emergency | `sosProvider`, `emergencyHistoryProvider` | `StateNotifierProvider`, `FutureProvider` |
| Hospitals | `nearbyHospitalsProvider` | `FutureProvider.family` (takes lat/lng) |
| Settings | `localeProvider`, `themeProvider` | `StateProvider` |

## Navigation (GoRouter)

```dart
// Shell routes for role-based bottom navigation
final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final auth = ref.read(authProvider);
    return auth.maybeWhen(
      authenticated: (_) => state.matchedLocation == '/login' ? '/patient/home' : null,
      unauthenticated: (_) => state.matchedLocation.startsWith('/auth') ? null : '/auth/login',
      orElse: () => null,
    );
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/auth/register/patient', builder: (_, __) => const RegisterPatientScreen()),
    GoRoute(path: '/auth/register/guardian', builder: (_, __) => const RegisterGuardianScreen()),

    // Patient Shell (Bottom Navigation)
    ShellRoute(
      builder: (_, __, child) => PatientShell(child: child),
      routes: [
        GoRoute(path: '/patient/home', builder: (_, __) => const PatientDashboard()),
        GoRoute(path: '/patient/health-card', builder: (_, __) => const HealthCardScreen()),
        GoRoute(path: '/patient/medical-record', builder: (_, __) => const MedicalRecordScreen()),
        GoRoute(path: '/patient/files', builder: (_, __) => const MedicalFilesScreen()),
        GoRoute(path: '/patient/hospitals', builder: (_, __) => const HospitalsScreen()),
        GoRoute(path: '/patient/sos', builder: (_, __) => const SosScreen()),
        GoRoute(path: '/patient/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),

    // Guardian Shell
    ShellRoute(
      builder: (_, __, child) => GuardianShell(child: child),
      routes: [
        GoRoute(path: '/guardian/home', builder: (_, __) => const GuardianDashboard()),
        GoRoute(path: '/guardian/patient-card', builder: (_, __) => const PatientCardScreen()),
        GoRoute(path: '/guardian/medical-record', builder: (_, __) => const GuardianMedicalRecordScreen()),
        GoRoute(path: '/guardian/files', builder: (_, __) => const GuardianFilesScreen()),
        GoRoute(path: '/guardian/location', builder: (_, __) => const PatientLocationScreen()),
        GoRoute(path: '/guardian/notifications', builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: '/guardian/emergency-history', builder: (_, __) => const EmergencyHistoryScreen()),
        GoRoute(path: '/guardian/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);
```

## Dependency Injection Setup (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      overrides: [
        // Override with actual implementations
        secureStorageProvider.overrideWithValue(SecureStorage()),
        localStorageProvider.overrideWithValue(LocalStorage()),
        apiClientProvider.overrideWithValue(createApiClient()),
      ],
      child: const BitaqatiApp(),
    ),
  );
}

class BitaqatiApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Bitaqati As-Sihiya',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme,
      routerConfig: appRouter,
    );
  }
}
```
