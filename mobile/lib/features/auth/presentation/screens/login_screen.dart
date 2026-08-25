import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/common/widgets/app_button.dart';
import 'package:bitaqati_as_sihiya/common/widgets/app_text_field.dart';
import 'package:bitaqati_as_sihiya/common/widgets/loading_overlay.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/utils/validators.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/widgets/role_selector.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/register_patient_screen.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/screens/account_recovery_request_screen.dart';
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'patient';
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final localizations = AppLocalizations.of(context);

    // الاستماع لتغيّر حالة المصادقة وإضافة التنقل حسب الدور
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (user) {
          // رسالة نجاح حسب الدور الحقيقي من الـ backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user.isHealthWorker
    ? 'تم تسجيل الدخول كموظف صحة بنجاح'
    : user.isGuardian
        ? 'تم تسجيل الدخول كولي بنجاح'
        : 'تم تسجيل الدخول كمريض بنجاح',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // بعد الرسالة، تنقل من صفحة واحدة إلى الشاشة المناسبة
          Future.microtask(() {
  if (user.isPatient) {
    context.go('/patient/home');
  } else if (user.isGuardian) {
    context.go('/guardian/home');
  } else if (user.isHealthWorker) {
    context.go('/staff/home');
  }
});
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
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // App Logo / Title
                  const Icon(
                    Icons.health_and_safety_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.appTitle,
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.appName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Role Selector (نفس الصفحة للمريض والولي)
                  RoleSelector(
                    selectedRole: _selectedRole,
                    onRoleChanged: (role) {
                      setState(() => _selectedRole = role);
                    },
                  ),
                  const SizedBox(height: 24),
                  // National ID
                  AppTextField(
                    label: localizations.nationalId,
                    // إذا عدلت Validator للـ 18 رقم، غيّر النص هنا أيضاً
                    hintText: 'Enter your 18-digit National ID',
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.nationalId,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  // Password
                  AppTextField(
                    label: localizations.password,
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                    validator: Validators.required,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    onSaved: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 8),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/account-recovery'),
                      child: Text(
                        localizations.forgotPassword,
                        style: AppTextStyles.link,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
  onPressed: () => context.go('/staff/login'),
  icon: const Icon(Icons.local_hospital_outlined),
  label: const Text('دخول موظفي الصحة'),
),
                  // Login Button
                  AppButton(
                    label: _selectedRole == 'patient'
                        ? localizations.loginAsPatient
                        : localizations.loginAsGuardian,
                    onPressed: _handleLogin,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.dontHaveAccount,
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPatientScreen(),
                            ),
                          );
                        },
                        child: Text(
                          localizations.register,
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
            nationalId: _nationalIdController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
          );
    }
  }
}