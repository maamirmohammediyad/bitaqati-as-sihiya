import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_emergencies_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_emergency_details_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_patient_details_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_qr_scanner_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_scanned_patients_screen.dart';
import 'package:bitaqati_as_sihiya/main.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_hospital_medications_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/login_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/register_guardian_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/register_patient_screen.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/screens/emergency_history_screen.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/screens/sos_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_patient_medical_files_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_account_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_patient_card_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_patient_emergencies_screen.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/screens/guardian_patient_medical_files_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_patient_medications_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_home_screen.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/screens/staff_login_screen.dart';

import 'package:bitaqati_as_sihiya/features/hospitals/presentation/screens/hospitals_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/account_recovery_request_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/complete_profile_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/health_card_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/medical_record_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_account_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_change_password_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_edit_account_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_files_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_qr_screen.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/screens/patient_medications_screen.dart';
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = authState.isAuthenticated;
      final user = authState.user;

      final isPublicRoute =
    location == '/login' ||
    location == '/account-recovery' ||
    location == '/staff/login' ||
    location.startsWith('/register');

      if (!isLoggedIn || user == null) {
        return isPublicRoute ? null : '/login';
      }

      final homeRoute = _homeRouteForUser(user);

      if (isPublicRoute) {
        return homeRoute;
      }

      if (location.startsWith('/patient/') && !user.isPatient) {
        return homeRoute;
      }

      if (location.startsWith('/guardian/') && !user.isGuardian) {
        return homeRoute;
      }

      if (location.startsWith('/staff/') &&
          (!user.isHealthWorker || user.activeHospital == null)) {
        return homeRoute;
      }

      if (location == '/sos' && !user.isPatient) {
        return homeRoute;
      }

      if (location.startsWith('/emergency/') &&
          !user.isPatient &&
          !user.isGuardian) {
        return homeRoute;
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
  path: '/account-recovery',
  builder: (context, state) => const AccountRecoveryRequestScreen(),
),
      GoRoute(
        path: '/staff/login',
        name: 'staffLogin',
        builder: (context, state) => const StaffLoginScreen(),
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
  path: '/patient/medications',
  name: 'patientMedications',
  builder: (context, state) => const PatientMedicationsScreen(),
),
          GoRoute(
            path: '/patient/hospitals',
            name: 'patientHospitals',
            builder: (context, state) => const HospitalsScreen(),
          ),
          GoRoute(
            path: '/patient/complete-profile',
            name: 'patientCompleteProfile',
            builder: (context, state) => const CompleteProfileScreen(),
          ),
          GoRoute(
            path: '/patient/edit-account',
            name: 'patientEditAccount',
            builder: (context, state) => const PatientEditAccountScreen(),
          ),
          GoRoute(
            path: '/patient/change-password',
            name: 'patientChangePassword',
            builder: (context, state) => const PatientChangePasswordScreen(),
          ),
          GoRoute(
            path: '/patient/qr',
            name: 'patientQr',
            builder: (context, state) => const PatientQrScreen(),
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
            builder: (context, state) => CompleteProfileScreen(
              patientId: state.pathParameters['patientId'],
            ),
          ),

        ],
      ),

ShellRoute(
  builder: (context, state, child) => _StaffShell(child: child),
  routes: [
    GoRoute(
      path: '/staff/home',
      name: 'staffHome',
      builder: (context, state) => const StaffHomeScreen(),
    ),
    GoRoute(
  path: '/staff/patients/:patientId/medical-files',
  name: 'staffPatientMedicalFiles',
  builder: (context, state) => StaffPatientMedicalFilesScreen(
    patientId: state.pathParameters['patientId']!,
    patientName: (state.extra as String?) ?? 'المريض',
  ),
),
    GoRoute(
      path: '/staff/scan-qr',
      name: 'staffScanQr',
      builder: (context, state) => const StaffQrScannerScreen(),
    ),
    GoRoute(
      path: '/staff/scanned-patients',
      name: 'staffScannedPatients',
      builder: (context, state) => const StaffScannedPatientsScreen(),
    ),
    GoRoute(
      path: '/staff/patients/:patientId',
      name: 'staffPatientDetails',
      builder: (context, state) => StaffPatientDetailsScreen(
        patientId: state.pathParameters['patientId']!,
        patientName: (state.extra as String?) ?? 'المريض',
      ),
    ),
    GoRoute(
      path: '/staff/emergencies',
      name: 'staffEmergencies',
      builder: (context, state) => const StaffEmergenciesScreen(),
    ),
    GoRoute(
      path: '/staff/emergencies/:emergencyId',
      name: 'staffEmergencyDetails',
      builder: (context, state) => StaffEmergencyDetailsScreen(
        emergencyId: state.pathParameters['emergencyId']!,
      ),
    ),
    GoRoute(
      path: '/staff/employees',
      name: 'staffEmployees',
      builder: (context, state) => const StaffPlaceholderScreen(
        title: 'إدارة الموظفين',
      ),
    ),
    GoRoute(
  path: '/staff/emergency-scan',
  name: 'staffEmergencyScan',
  builder: (context, state) => const StaffQrScannerScreen(
    emergencyMode: true,
  ),
),
GoRoute(
  path: '/staff/patients/:patientId/medications',
  name: 'staffPatientMedications',
  builder: (context, state) {
    return StaffPatientMedicationsScreen(
      patientId: state.pathParameters['patientId']!,
      patientName: state.extra as String? ?? '',
    );
  },
),
GoRoute(
  path: '/staff/medications',
  name: 'staffHospitalMedications',
  builder: (context, state) => const StaffHospitalMedicationsScreen(),
),

GoRoute(
  path: '/staff/change-password',
  name: 'staffChangePassword',
  builder: (context, state) => const PatientChangePasswordScreen(),
),
  ],
),

      GoRoute(
        path: '/emergency/history',
        name: 'emergencyHistory',
        builder: (context, state) => const EmergencyHistoryScreen(),
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
            patientName: patient?.fullName ?? 'المريض',
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
    ],
  );
});

String _homeRouteForUser(User user) {
  if (user.isHealthWorker) {
    return '/staff/home';
  }

  if (user.isGuardian) {
    return '/guardian/home';
  }

  return '/patient/home';
}

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

    var currentIndex = 0;

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

  const _GuardianShell({
    required this.child,
  });

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

    var currentIndex = 0;

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
class StaffPlaceholderScreen extends StatelessWidget {
  final String title;

  const StaffPlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('هذه الشاشة قيد الإنشاء.'),
      ),
    );
  }
}
class _StaffShell extends StatelessWidget {
  final Widget child;

  const _StaffShell({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }

  
}