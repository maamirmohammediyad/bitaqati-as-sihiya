import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/main.dart'; // للوصول إلى navigatorKey
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/login_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/register_patient_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/register_guardian_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/health_card_screen.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/screens/sos_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospitals/presentation/screens/hospitals_screen.dart';
import 'package:bitaqati_as_sihiya/features/settings/presentation/screens/settings_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/complete_profile_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_patient_card_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/patient_details_screen.dart'; 
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_qr_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_files_screen.dart';    
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/medical_record_screen.dart'; 
import 'package:bitaqati_as_sihiya/features/emergency/presentation/screens/emergency_history_screen.dart';  
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_patient_emergencies_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_account_screen.dart';   
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_patient_medical_files_screen.dart';  
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_account_screen.dart';                                        
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',                                                            
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation.startsWith('/register');

      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        return authState.isGuardian ? '/guardian/home' : '/patient/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register/patient',
        name: 'registerPatient',
        builder: (context, state) => const RegisterPatientScreen(),
      ),
      GoRoute(
        path: '/register/guardian',
        name: 'registerGuardian',
        builder: (context, state) => const RegisterGuardianScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _PatientShell(child: child),
        routes: [
          GoRoute(
            path: '/patient/home',
            name: 'patientHome',
            builder: (context, state) => const PatientDashboard(),
          ),
          GoRoute(
            path: '/patient/health-card',
            name: 'patientHealthCard',
            builder: (context, state) => const HealthCardScreen(),
          ),
          GoRoute(
  path: '/patient/account',
  name: 'patientAccount',
  builder: (context, state) => const PatientAccountScreen(),
),
          GoRoute(
  path: '/patient/medical-record',
  name: 'patientMedicalRecord',
  builder: (context, state) => const MedicalRecordScreen(),
),
          GoRoute(
  path: '/patient/files',
  name: 'patientFiles',
  builder: (context, state) => const PatientFilesScreen(),
),
          GoRoute(
            path: '/patient/hospitals',
            name: 'patientHospitals',
            builder: (context, state) => const HospitalsScreen(),
          ),
          GoRoute(
            path: '/patient/complete-profile',
            name: 'patient-complete-profile',
            builder: (context, state) => const CompleteProfileScreen(),
          ),
          GoRoute(
  path: '/patient/qr',
  builder: (context, state) => const PatientQrScreen(),
),
GoRoute(
  path: '/emergency/history',
  name: 'emergencyHistory',
  builder: (context, state) => const EmergencyHistoryScreen(),
),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => _GuardianShell(child: child),
        routes: [
          GoRoute(
  path: '/guardian/home',
  name: 'guardianHome',
  builder: (context, state) => const GuardianDashboard(),
),
          GoRoute(
  path: '/guardian/card',
  name: 'guardianPatientCard',
  builder: (context, state) => const GuardianPatientCardScreen(),
),
GoRoute(
  path: '/guardian/account',
  name: 'guardianAccount',
  builder: (context, state) => const GuardianAccountScreen(),
),
          GoRoute(
            path: '/guardian/medical-record',
            name: 'guardianMedicalRecord',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Medical Record')),
            ),
          ),
          GoRoute(
            path: '/guardian/files',
            name: 'guardianFiles',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Files')),
            ),
          ),
          GoRoute(
            path: '/guardian/location',
            name: 'guardianLocation',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Location')),
            ),
          ),
          GoRoute(
            path: '/guardian/notifications',
            name: 'guardianNotifications',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Notifications')),
            ),
          ),
          GoRoute(
            path: '/guardian/emergency-history',
            name: 'guardianEmergencyHistory',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Emergency History')),
            ),
          ),
          GoRoute(
  path: '/guardian/patient/:patientId/complete-profile',
  name: 'guardianPatientCompleteProfile',
  builder: (context, state) {
    return CompleteProfileScreen(
      patientId: state.pathParameters['patientId'],
    );
  },
),
        ],
      ),
      GoRoute(
  path: '/guardian/patient-emergencies/:id',
  name: 'guardianPatientEmergencies',
  builder: (context, state) {
    final patientId = state.pathParameters['id']!;
    final patientName = (state.extra as String?) ?? 'المريض';
    return GuardianPatientEmergenciesScreen(
      patientId: patientId,
      patientName: patientName,
    );
  },
),
       GoRoute(
  path: '/guardian/patient/:id/medical-files',
  name: 'guardianPatientMedicalFiles',
  builder: (context, state) {
    final patient = state.extra as User?;
    final patientId = state.pathParameters['id']!;

    return GuardianPatientMedicalFilesScreen(
      patientId: patientId,
      patientName: patient?.fullName ?? patient?.fullName ?? 'المريض',
    );
  },
),
    GoRoute(
      path: '/guardian/patient/:id/qr',
      name: 'guardianPatientQr',
      builder: (context, state) {
        final patientId = state.pathParameters['id']!;
        return Scaffold(
          appBar: AppBar(title: const Text('الكود الصحي')),
          body: Center(
            child: Text('الكود الصحي للمريض $patientId'),
          ),
        );
      },
    ),
      GoRoute(
        path: '/sos',
        name: 'sos',
        builder: (context, state) => const SosScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _PatientShell extends StatelessWidget {
  final Widget child;

  const _PatientShell({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _PatientBottomNav(),
    );
  }
}

class _PatientBottomNav extends StatelessWidget {
  const _PatientBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;

    if (location.startsWith('/patient/health-card')) {
      currentIndex = 1;
    } else if (location.startsWith('/patient/account')) {
      currentIndex = 2;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/patient/home');
            break;
          case 1:
            context.go('/patient/health-card');
            break;
          case 2:
            context.go('/patient/account');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge_rounded),
          label: 'بطاقتي',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'حسابي',
        ),
      ],
    );
  }
}

class _GuardianShell extends StatelessWidget {
  final Widget child;

  const _GuardianShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _GuardianBottomNav(),
    );
  }
}

class _GuardianBottomNav extends StatelessWidget {
  const _GuardianBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;

    if (location.startsWith('/guardian/card')) {
      currentIndex = 1;
    } else if (location.startsWith('/guardian/account')) {
      currentIndex = 2;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/guardian/home');
            break;
          case 1:
            context.go('/guardian/card');
            break;
          case 2:
            context.go('/guardian/account');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge_rounded),
          label: 'بطاقتي',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'حسابي',
        ),
      ],
    );
  }
}
