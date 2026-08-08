import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/common/widgets/app_button.dart';
import 'package:bitaqati_as_sihiya/common/widgets/app_text_field.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/utils/validators.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';

class RegisterPatientScreen extends ConsumerStatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  ConsumerState<RegisterPatientScreen> createState() =>
      _RegisterPatientScreenState();
}

class _RegisterPatientScreenState
    extends ConsumerState<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nationalIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // خيار: هل هذا الحساب سيكون وليًا أيضًا؟
  bool _isGuardian = false;
  final _patientNationalIdController = TextEditingController();
  String? _relationship;
  @override
  void dispose() {
    _nationalIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _patientNationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (_) {
          // مؤقتاً فقط نظهر SnackBar بدل go_router
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registered successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // لاحقاً يمكن توجيه المريض مباشرة إلى PatientDashboard
          context.go('/patient/dashboard');
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create your patient account',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in your details to get started',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // بيانات المريض الأساسية
              AppTextField(
                label: 'National ID',
                hintText: 'Enter your 18-digit National ID',
                controller: _nationalIdController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                validator: Validators.nationalId,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'First name',
                hintText: 'Enter your first name',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.name(v, 'First name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Last name',
                hintText: 'Enter your last name',
                controller: _lastNameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.name(v, 'Last name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone number',
                hintText: 'Enter your phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.algerianPhone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hintText: 'Create a strong password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Confirm password',
                hintText: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordController.text),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              const Text(
                'Password must be at least 8 characters.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 24),

              // تيك: هل أنت ولي؟
              CheckboxListTile(
                value: _isGuardian,
                onChanged: (value) {
                  setState(() => _isGuardian = value ?? false);
                },
                title: const Text(
                  'هل أنت ولي للمريض؟',
                  style: AppTextStyles.bodyMedium,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // إذا اختار أنه ولي → نظهر حقل رقم تعريف المريض المرتبط
if (_isGuardian) ...[
  const SizedBox(height: 8),
  AppTextField(
    label: 'كود المريض',
    hintText: 'أدخل كود المريض مثل HLT-85BV-KSFU',
    controller: _patientNationalIdController,
    keyboardType: TextInputType.text, // لأن الكود فيه حروف وأرقام
    prefixIcon: Icons.badge_outlined,
    // يمكنك إنشاء Validator بسيط مثلاً:
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'أدخل كود المريض';
      }
      // إن أردت، تحقق من الطول أو نمط معين:
      // if (value.length < 5) return 'كود المريض غير صحيح';
      return null;
    },
    textInputAction: TextInputAction.next,
  ),
  const SizedBox(height: 16),
  DropdownButtonFormField<String>(
    value: _relationship,
    decoration: const InputDecoration(
      labelText: 'صلة القرابة',
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(value: 'father', child: Text('أب')),
      DropdownMenuItem(value: 'mother', child: Text('أم')),
      DropdownMenuItem(value: 'husband', child: Text('زوج')),
      DropdownMenuItem(value: 'wife', child: Text('زوجة')),
      DropdownMenuItem(value: 'son', child: Text('ابن')),
      DropdownMenuItem(value: 'daughter', child: Text('ابنة')),
      DropdownMenuItem(value: 'brother', child: Text('أخ')),
      DropdownMenuItem(value: 'sister', child: Text('أخت')),
      DropdownMenuItem(value: 'other', child: Text('أخرى')),
    ],
    onChanged: (value) => setState(() => _relationship = value),
    validator: (value) => value == null ? 'اختر صلة القرابة' : null,
  ),
  const SizedBox(height: 8),
  const Text(
    'يمكن لنفس الحساب أن يكون مريضًا ووليًا في نفس الوقت.',
    style: AppTextStyles.caption,
  ),
],
              const SizedBox(height: 32),
              AppButton(
                label: 'Register',
                onPressed: _handleRegister,
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Login',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
  if (_formKey.currentState?.validate() ?? false) {
    final notifier = ref.read(authProvider.notifier);

    if (_isGuardian) {
      // نفس الشخص سيكون مريضًا ووليًا، لكن من جهة الـ API هذه عملية "تسجيل ولي"
          notifier.registerGuardian(
        nationalId: _nationalIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        // هنا نرسل كود المريض مثل HLT-O9BV-KQAU
        patientCode: _patientNationalIdController.text.trim(),
        relationship: _relationship!, // لا تتركها null
      );
    } else {
      // مريض فقط
      notifier.registerPatient(
        nationalId: _nationalIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
}