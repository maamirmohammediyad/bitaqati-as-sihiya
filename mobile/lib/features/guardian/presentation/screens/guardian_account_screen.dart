import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import 'package:bitaqati_as_sihiya/core/errors/app_exceptions.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_dashboard_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/data/account_verification_api.dart';

class GuardianAccountScreen extends ConsumerStatefulWidget {
  const GuardianAccountScreen({super.key});

  @override
  ConsumerState<GuardianAccountScreen> createState() =>
      _GuardianAccountScreenState();
}

class _GuardianAccountScreenState extends ConsumerState<GuardianAccountScreen> {
  static const int _maxVerificationFileSizeBytes = 5 * 1024 * 1024;

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUploadingVerificationDocument = false;
bool _isLoadingVerificationDocument = true;

AccountVerificationDocument? _verificationDocument;

@override
void initState() {
  super.initState();

  final user = ref.read(authProvider).user;

  _nameController = TextEditingController(text: user?.fullName ?? '');
  _phoneController = TextEditingController(text: user?.phone ?? '');
  _emailController = TextEditingController(text: user?.email ?? '');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadVerificationDocument();
  });
}
Future<void> _loadVerificationDocument() async {
  try {
    final document = await ref
        .read(accountVerificationApiProvider)
        .getDocument();

    if (!mounted) return;

    setState(() {
      _verificationDocument = document;
      _isLoadingVerificationDocument = false;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _isLoadingVerificationDocument = false;
    });
  }
}
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSavingProfile = true);

    final error = await ref.read(authProvider.notifier).updateGuardianProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isSavingProfile = false);

    _showMessage(
      error ?? 'تم تحديث بيانات الحساب بنجاح',
      isError: error != null,
    );
  }

  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isChangingPassword = true);

    final error = await ref.read(authProvider.notifier).updatePassword(
          currentPassword: _currentPasswordController.text,
          password: _newPasswordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (!mounted) return;

    setState(() => _isChangingPassword = false);

    if (error != null) {
      _showMessage(error, isError: true);
      return;
    }

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    _showMessage('تم تغيير كلمة المرور. يرجى تسجيل الدخول من جديد.');

    await ref.read(authProvider.notifier).logout();

    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل تريد تسجيل الخروج من الحساب؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    await ref.read(authProvider.notifier).logout();

    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _openPatientProfile(String patientId) async {
    final wasUpdated = await context.pushNamed<bool>(
      'guardianPatientCompleteProfile',
      pathParameters: {
        'patientId': patientId,
      },
    );

    if (wasUpdated == true && mounted) {
      ref.invalidate(guardianPatientDashboardProvider(patientId));
      ref.invalidate(
        guardianPatientDashboardWithNotifyProvider(patientId),
      );
    }
  }

  Future<void> _uploadVerificationDocument() async {
    if (_isUploadingVerificationDocument) return;

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

    final fileSize =
        file.size > 0 ? file.size : await File(filePath).length();

    if (fileSize > _maxVerificationFileSizeBytes) {
      _showMessage(
        'حجم المستند أكبر من 5 ميغابايت. اختر ملفًا أصغر.',
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

    setState(() => _isUploadingVerificationDocument = true);

    try {
      final document = await ref
    .read(accountVerificationApiProvider)
    .uploadDocument(
      filePath: filePath,
      fileName: file.name,
    );

if (!mounted) return;

setState(() {
  _verificationDocument = document;
});

      _showMessage(
        'تم إرسال مستند التحقق بنجاح، وهو الآن قيد المراجعة.',
      );
    } on DioException catch (error) {
      if (!mounted) return;

      _showMessage(
        _verificationUploadErrorMessage(error),
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'تعذر رفع المستند حاليًا. يرجى المحاولة لاحقًا.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingVerificationDocument = false);
      }
    }
  }

  String _verificationUploadErrorMessage(DioException error) {
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

    return 'تعذر رفع المستند حاليًا. يرجى المحاولة لاحقًا.';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
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

    final patients = user.patients;
    final patient = patients.isNotEmpty ? patients.first : null;

    final verificationStatus =
    _verificationDocument?.status ?? user.verificationStatus;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حسابي'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _AccountHeader(
                name: user.fullName,
                phone: user.phone ?? '',
              ),
              const SizedBox(height: 16),
              _VerificationStatusCard(
  verificationStatus: verificationStatus,
  rejectionReason: _verificationDocument?.rejectionReason,
  isLoading: _isLoadingVerificationDocument,
  isUploading: _isUploadingVerificationDocument,
  onUpload: _uploadVerificationDocument,
),
              const SizedBox(height: 24),
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildPasswordSection(),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _logout,
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
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.person_outline_rounded,
                title: 'بيانات الحساب',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 2) {
                    return 'أدخل الاسم الكامل';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'أدخل رقم الهاتف';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني (اختياري)',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) return null;

                  final emailRegex = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  );

                  if (!emailRegex.hasMatch(email)) {
                    return 'أدخل بريدًا إلكترونيًا صحيحًا';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSavingProfile ? null : _saveProfile,
                  child: _isSavingProfile
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('حفظ التعديلات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.lock_outline_rounded,
                title: 'تغيير كلمة المرور',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                textInputAction: TextInputAction.next,
                decoration: _passwordDecoration(
                  label: 'كلمة المرور الحالية',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureCurrentPassword,
                  onToggle: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل كلمة المرور الحالية';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                textInputAction: TextInputAction.next,
                decoration: _passwordDecoration(
                  label: 'كلمة المرور الجديدة',
                  icon: Icons.lock_reset_outlined,
                  obscure: _obscureNewPassword,
                  onToggle: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                validator: (value) {
                  if ((value?.length ?? 0) < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                decoration: _passwordDecoration(
                  label: 'تأكيد كلمة المرور الجديدة',
                  icon: Icons.lock_reset_outlined,
                  obscure: _obscureConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'كلمتا المرور غير متطابقتين';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  child: _isChangingPassword
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تغيير كلمة المرور'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        tooltip: obscure ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: onToggle,
      ),
      border: const OutlineInputBorder(),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  final String name;
  final String phone;

  const _AccountHeader({
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final firstLetter = trimmedName.isEmpty
        ? 'و'
        : trimmedName.substring(0, 1).toUpperCase();

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                firstLetter,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trimmedName.isEmpty ? 'ولي الأمر' : trimmedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone.isEmpty ? 'لا يوجد رقم هاتف' : phone,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  final String verificationStatus;
  final String? rejectionReason;
  final bool isLoading;
  final bool isUploading;
  final VoidCallback onUpload;

  const _VerificationStatusCard({
    required this.verificationStatus,
    required this.rejectionReason,
    required this.isLoading,
    required this.isUploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: SizedBox(
          height: 150,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final status = verificationStatus.trim().toLowerCase();

    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';
    final isPending = status == 'pending';

    final color = isApproved
        ? Colors.green
        : isRejected
            ? Colors.red
            : Colors.orange;

    final icon = isApproved
        ? Icons.verified_user_rounded
        : isRejected
            ? Icons.cancel_outlined
            : Icons.hourglass_top_rounded;

    final title = isApproved
        ? 'تم اعتماد حساب ولي الأمر'
        : isRejected
            ? 'تم رفض طلب التحقق'
            : isPending
                ? 'طلب التحقق قيد المراجعة'
                : 'حسابك بحاجة إلى تحقق';

    final reason = rejectionReason?.trim();

    final subtitle = isApproved
        ? 'يمكنك الوصول إلى جميع بيانات المريض المصرح بها.'
        : isRejected
            ? reason != null && reason.isNotEmpty
                ? 'سبب الرفض: $reason'
                : 'تم رفض الوثيقة. يرجى رفع وثيقة أوضح وصالحة.'
            : isPending
                ? 'سيتم إشعارك بعد مراجعة مستند التحقق.'
                : 'ارفع وثيقة إثبات الهوية لإكمال التحقق من الحساب.';

    final canUpload = !isApproved && !isPending;

    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(subtitle),
              ),
            ),
            if (canUpload) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isUploading ? null : onUpload,
                  icon: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_file_outlined),
                  label: Text(
                    isUploading
                        ? 'جارٍ رفع المستند...'
                        : isRejected
                            ? 'رفع مستند جديد'
                            : 'اختيار ورفع مستند التحقق',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الأنواع المسموحة: PDF، JPG، PNG — الحد الأقصى: 5 MB',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}