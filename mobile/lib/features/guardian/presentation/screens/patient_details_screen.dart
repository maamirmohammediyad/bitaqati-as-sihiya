// lib/features/guardian/presentation/screens/patient_details_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/widgets/patient_files_section.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key, required this.patient});

  final User patient;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // التحكم في زر الرجوع في الهاتف
      onWillPop: () async {
        // يرجع دائماً إلى home الولي
        context.goNamed('guardianHome');
        return false; // لا تترك النظام يغلق الصفحة بنفسه
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // نفس السلوك لسهم الرجوع في الـ AppBar
              context.goNamed('guardianHome');
            },
          ),
          title: Text('ملف ${patient.fullName}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات المريض',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text(patient.fullName),
                  subtitle: Text('الرقم الوطني: ${patient.nationalId}'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'سجل الطوارئ',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              const Text(
                'سجل الطوارئ سيتم إضافته لاحقاً.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'الملفات الطبية',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              PatientFilesSection(patientId: patient.id),
            ],
          ),
        ),
      ),
    );
  }
}