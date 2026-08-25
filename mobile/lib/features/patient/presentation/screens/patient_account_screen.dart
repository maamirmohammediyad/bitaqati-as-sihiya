import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import 'package:bitaqati_as_sihiya/core/errors/app_exceptions.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/data/account_verification_api.dart';

class PatientAccountScreen extends ConsumerStatefulWidget {
  const PatientAccountScreen({super.key});

  @override
  ConsumerState<PatientAccountScreen> createState() =>
      _PatientAccountScreenState();
}

class _PatientAccountScreenState extends ConsumerState<PatientAccountScreen> {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024;

  bool _isUploadingDocument = false;
  bool _isLoadingDocument = true;
  AccountVerificationDocument? _document;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;

      if (user?.isProfileComplete == true) {
        _loadDocument();
      } else if (mounted) {
        setState(() {
          _isLoadingDocument = false;
        });
      }
    });
  }

  Future<void> _loadDocument() async {
    try {
      final document = await ref
          .read(accountVerificationApiProvider)
          .getDocument();

      if (!mounted) return;

      setState(() {
        _document = document;
        _isLoadingDocument = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingDocument = false;
      });
    }
  }

  Future<void> _pickAndUploadDocument() async {
    if (_isUploadingDocument) return;

    final selected = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
      withData: false,
    );

    if (!mounted || selected == null || selected.files.isEmpty) {
      return;
    }

    final file = selected.files.single;
    final filePath = file.path;

    if (filePath == null || filePath.isEmpty) {
      _showMessage(
        'تعذر الوصول إلى الملف المحدد. حاول اختيار الملف مرة أخرى.',
        isError: true,
      );
      return;
    }

    final size = file.size > 0 ? file.size : await File(filePath).length();

    if (size > _maxFileSizeBytes) {
      _showMessage(
        'حجم الوثيقة أكبر من 5 ميغابايت. اختر ملفًا أصغر.',
        isError: true,
      );
      return;
    }

    final mimeType = lookupMimeType(filePath);

    const allowedMimeTypes = {
      'application/pdf',
      'image/jpeg',
      'image/png',
    };

    if (mimeType == null || !allowedMimeTypes.contains(mimeType)) {
      _showMessage(
        'يسمح فقط بملفات PDF أو صور JPG وPNG.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isUploadingDocument = true;
    });

    try {
      final document = await ref
          .read(accountVerificationApiProvider)
          .uploadDocument(
            filePath: filePath,
            fileName: file.name,
          );

      if (!mounted) return;

      setState(() {
        _document = document;
      });

      _showMessage(
        'تم إرسال وثيقة الإثبات بنجاح، وهي الآن قيد المراجعة.',
      );
    } on DioException catch (error) {
      if (!mounted) return;

      _showMessage(
        _errorMessage(error),
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'تعذر رفع الوثيقة حاليًا. يرجى المحاولة لاحقًا.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
      }
    }
  }

  String _errorMessage(DioException error) {
    final exception = error.error;

    if (exception is ValidationException) {
      final documentErrors = exception.errors?['document'];

      if (documentErrors is List && documentErrors.isNotEmpty) {
        return documentErrors.first.toString();
      }

      return exception.message;
    }

    if (exception is UnauthorizedException) {
      return 'انتهت جلسة الدخول. يرجى تسجيل الدخول مرة أخرى.';
    }

    if (exception is NetworkConnectionException) {
      return 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';
    }

    if (exception is TimeoutException) {
      return 'استغرقت العملية وقتًا طويلًا. حاول مرة أخرى.';
    }

    if (exception is ServerException) {
      return exception.message;
    }

    return 'تعذر رفع الوثيقة حاليًا. يرجى المحاولة لاحقًا.';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
  }

  String _documentStatusText(AccountVerificationDocument document) {
    if (document.isApproved) {
      return 'تم توثيق حسابك بنجاح.';
    }

    if (document.isRejected) {
      final reason = document.rejectionReason?.trim();

      if (reason != null && reason.isNotEmpty) {
        return 'تم رفض الوثيقة: $reason';
      }

      return 'تم رفض الوثيقة. يرجى رفع وثيقة أوضح وصالحة.';
    }

    return 'تم إرسال الوثيقة وهي الآن قيد المراجعة.';
  }

  Color _documentStatusColor(AccountVerificationDocument document) {
    if (document.isApproved) return Colors.green;
    if (document.isRejected) return Colors.red;
    return Colors.orange;
  }

  IconData _documentStatusIcon(AccountVerificationDocument document) {
    if (document.isApproved) return Icons.verified_rounded;
    if (document.isRejected) return Icons.error_outline_rounded;
    return Icons.hourglass_top_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isProfileComplete = user.isProfileComplete;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName.substring(0, 1).toUpperCase()
                      : 'م',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 4),

            Text(
              'مريض',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('رقم الهاتف'),
                    subtitle: Text(user.phone ?? 'غير مضاف'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('البريد الإلكتروني'),
                    subtitle: Text(user.email ?? 'غير مضاف'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('كود المريض'),
                    subtitle: Text(user.patientCode ?? 'غير متوفر'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // لا يظهر قسم رفع وثيقة الهوية قبل اكتمال الملف الصحي.
            if (isProfileComplete) ...[
              _buildVerificationDocumentCard(),
              const SizedBox(height: 16),
            ] else ...[
              _CompleteProfileRequiredCard(
                onTap: () {
                  context.push('/patient/complete-profile');
                },
              ),
              const SizedBox(height: 16),
            ],

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('تغيير كلمة المرور'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
                      context.push('/patient/change-password');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('تعديل معلومات الحساب'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
                      context.push('/patient/edit-account');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();

                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationDocumentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _isLoadingDocument
            ? const SizedBox(
                height: 130,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _document == null
                          ? Icons.verified_user_outlined
                          : _documentStatusIcon(_document!),
                      color: _document == null
                          ? null
                          : _documentStatusColor(_document!),
                    ),
                    title: const Text('وثيقة إثبات الهوية'),
                    subtitle: Text(
                      _document == null
                          ? 'ارفع بطاقة الهوية أو أي وثيقة إثبات'
                          : '${_document!.originalName}\n${_documentStatusText(_document!)}',
                    ),
                    isThreeLine: _document != null,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isUploadingDocument ||
                              (_document?.isPending ?? false) ||
                              (_document?.isApproved ?? false)
                          ? null
                          : _pickAndUploadDocument,
                      icon: _isUploadingDocument
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_file_outlined),
                      label: Text(
                        _isUploadingDocument
                            ? 'جارٍ رفع الوثيقة...'
                            : _document == null
                                ? 'اختيار ورفع وثيقة'
                                : _document!.isPending
                                    ? 'الوثيقة قيد المراجعة'
                                    : _document!.isApproved
                                        ? 'تم توثيق الحساب'
                                        : 'رفع وثيقة جديدة',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _document?.isPending == true
                        ? 'لا يمكنك استبدال الوثيقة حتى تنتهي المراجعة.'
                        : 'الأنواع المسموحة: PDF، JPG، PNG — الحد الأقصى: 5 MB',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}

class _CompleteProfileRequiredCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CompleteProfileRequiredCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.assignment_late_outlined,
              size: 38,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            const Text(
              'أكمل ملفك الصحي أولًا',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'يمكنك رفع وثيقة إثبات الهوية بعد إكمال المعلومات الصحية.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                child: const Text('إكمال المعلومات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}