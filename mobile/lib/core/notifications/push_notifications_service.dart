import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ستحتاج لتمرير navigatorKey و router من main.dart
class PushNotificationsService {
  final GlobalKey<NavigatorState> navigatorKey;
  final GoRouter router;

  PushNotificationsService({
    required this.navigatorKey,
    required this.router,
  });

  void init() {
    // عند وصول إشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // عند فتح التطبيق من الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    final type = message.data['type'];
    if (type != 'sos') return;

    final patientId   = message.data['patient_id'];
    final emergencyId = message.data['emergency_id'];

    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      // لو ما في كونتكست (مثلاً التطبيق في الخلفية) افتح الشاشة مباشرة
      router.goNamed(
        'guardianPatientEmergencies',
        pathParameters: {'id': patientId},
        extra: 'المريض',
      );
      return;
    }

    // لو التطبيق مفتوح: أظهر Dialog
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('نداء طوارئ'),
        content: const Text('تم استلام نداء طوارئ من المريض المرتبط بحسابك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              router.goNamed(
                'guardianPatientEmergencies',
                pathParameters: {'id': patientId},
                extra: 'المريض',
              );
            },
            child: const Text('عرض السجل'),
          ),
        ],
      ),
    );
  }
}