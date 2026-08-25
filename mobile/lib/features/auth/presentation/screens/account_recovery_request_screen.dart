import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/common/widgets/app_button.dart';
import 'package:bitaqati_as_sihiya/common/widgets/app_text_field.dart';
import 'package:bitaqati_as_sihiya/common/widgets/loading_overlay.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/utils/validators.dart';

class AccountRecoveryRequestScreen extends StatefulWidget {
  const AccountRecoveryRequestScreen({super.key});

  @override
  State<AccountRecoveryRequestScreen> createState() =>
      _AccountRecoveryRequestScreenState();
}

class _AccountRecoveryRequestScreenState
    extends State<AccountRecoveryRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nationalIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  PlatformFile? _identityDocument;
  bool _isLoading = false;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickIdentityDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (file.path == null) {
      _showError('تعذر الوصول إلى الملف المحدد.');
      return;
    }

    const maxSizeInBytes = 5 * 1024 * 1024;

    if (file.size > maxSizeInBytes) {
      _showError('يجب ألا يتجاوز حجم وثيقة الهوية 5 ميغابايت.');
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _identityDocument = file;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_identityDocument == null || _identityDocument!.path == null) {
      _showError('يرجى اختيار صورة أو ملف وثيقة الهوية.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final file = File(_identityDocument!.path!);

      final formData = FormData.fromMap({
        'national_id': _nationalIdController.text.trim(),
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'note': _noteController.text.trim(),
        'identity_document': await MultipartFile.fromFile(
          file.path,
          filename: _identityDocument!.name,
        ),
      });

      final response = await Dio().post<Map<String, dynamic>>(
        '${ApiConstants.baseUrl}/auth/account-recovery-requests',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: const {
            'Accept': 'application/json',
          },
        ),
      );

      if (!mounted) {
        return;
      }

      final message = response.data?['message'] as String? ??
          'تم إرسال طلب الاستعادة بنجاح.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } on DioException catch (error, stackTrace) {
      debugPrint('RECOVERY ERROR TYPE: ${error.type}');
      debugPrint('RECOVERY STATUS: ${error.response?.statusCode}');
      debugPrint('RECOVERY DATA: ${error.response?.data}');
      debugPrint('RECOVERY MESSAGE: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      final data = error.response?.data;
      String message = 'تعذر إرسال طلب الاستعادة. حاول مرة أخرى.';

      if (data is Map<String, dynamic>) {
        final apiMessage = data['message'];

        if (apiMessage is String && apiMessage.isNotEmpty) {
          message = apiMessage;
        }
      }

      _showError(message);
    } catch (error, stackTrace) {
      debugPrint('RECOVERY UNKNOWN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      _showError('حدث خطأ غير متوقع. يرجى المحاولة لاحقًا.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعادة الحساب'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_reset_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'طلب استعادة الحساب',
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل بياناتك وارفع وثيقة إثبات الهوية. سيُراجع فريق الإدارة الطلب قبل إرسال رابط تعيين كلمة مرور جديدة.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'رقم الهوية الوطنية',
                    hintText: 'أدخل رقم الهوية',
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.nationalId,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'الاسم الكامل',
                    hintText: 'أدخل الاسم كما هو في الهوية',
                    controller: _fullNameController,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'رقم الهاتف (اختياري)',
                    hintText: 'أدخل رقم الهاتف',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'ملاحظات (اختياري)',
                    hintText: 'أضف أي معلومة تساعد الإدارة في التحقق',
                    controller: _noteController,
                    prefixIcon: Icons.note_outlined,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickIdentityDocument,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(
                      _identityDocument == null
                          ? 'إرفاق وثيقة الهوية'
                          : _identityDocument!.name,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الصيغ المسموحة: JPG، JPEG، PNG، WEBP، PDF. الحد الأقصى: 5 MB.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'إرسال طلب الاستعادة',
                    onPressed: _submit,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text('العودة إلى تسجيل الدخول'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}