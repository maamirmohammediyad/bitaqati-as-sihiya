import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/account_provider.dart';

class PatientChangePasswordScreen extends ConsumerStatefulWidget {
  const PatientChangePasswordScreen({super.key});

  @override
  ConsumerState<PatientChangePasswordScreen> createState() =>
      _PatientChangePasswordScreenState();
}

class _PatientChangePasswordScreenState
    extends ConsumerState<PatientChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmation = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    try {
      await ref
          .read(accountActionsProvider)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            password: _newPasswordController.text,
            passwordConfirmation: _confirmationController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      await ref.read(authProvider.notifier).logout();

if (!mounted) return;

context.go('/login');
    } on DioException catch (error) {
      if (!mounted) return;

      final message = _extractErrorMessage(error);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تغيير كلمة المرور، حاول مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return 'تعذر تغيير كلمة المرور، حاول مرة أخرى.';
  }

  InputDecoration _passwordDecoration({
    required String label,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        tooltip: isVisible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
        onPressed: onVisibilityChanged,
        icon: Icon(
          isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(accountLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                textInputAction: TextInputAction.next,
                decoration: _passwordDecoration(
                  label: 'كلمة المرور الحالية',
                  icon: Icons.lock_outline_rounded,
                  isVisible: _showCurrentPassword,
                  onVisibilityChanged: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                textInputAction: TextInputAction.next,
                decoration: _passwordDecoration(
                  label: 'كلمة المرور الجديدة',
                  icon: Icons.lock_reset_outlined,
                  isVisible: _showNewPassword,
                  onVisibilityChanged: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';
                  }

                  if (value == _currentPasswordController.text) {
                    return 'اختر كلمة مرور مختلفة عن الحالية';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmationController,
                obscureText: !_showConfirmation,
                textInputAction: TextInputAction.done,
                decoration: _passwordDecoration(
                  label: 'تأكيد كلمة المرور الجديدة',
                  icon: Icons.lock_reset_outlined,
                  isVisible: _showConfirmation,
                  onVisibilityChanged: () {
                    setState(() {
                      _showConfirmation = !_showConfirmation;
                    });
                  },
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'كلمتا المرور غير متطابقتين';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _changePassword(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _changePassword,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
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
}
