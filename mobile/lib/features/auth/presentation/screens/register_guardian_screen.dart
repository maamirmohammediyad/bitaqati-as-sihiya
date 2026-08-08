import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/common/widgets/app_button.dart';
import 'package:bitaqati_as_sihiya/common/widgets/app_text_field.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/utils/validators.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
final _phoneController = TextEditingController();
class RegisterGuardianScreen extends ConsumerStatefulWidget {
  const RegisterGuardianScreen({super.key});

  @override
  ConsumerState<RegisterGuardianScreen> createState() =>
      _RegisterGuardianScreenState();
}

class _RegisterGuardianScreenState
    extends ConsumerState<RegisterGuardianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _patientCodeController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void dispose() {
    _nationalIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _patientCodeController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final localizations = AppLocalizations.of(context);

    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (_) {
          context.go('/guardian/home');
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
        title: Text(localizations.registerAsGuardian),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create your guardian account',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              const Text(
                'Link to a patient using their code',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: localizations.nationalId,
                hintText: 'Enter your 10-digit National ID',
                controller: _nationalIdController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                validator: Validators.nationalId,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: localizations.firstName,
                hintText: 'Enter your first name',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.name(v, 'First name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: localizations.lastName,
                hintText: 'Enter your last name',
                controller: _lastNameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.name(v, 'Last name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: localizations.password,
                hintText: 'Create a strong password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: localizations.confirmPassword,
                hintText: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordController.text),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.grey200),
              const SizedBox(height: 16),
              const Text(
                'Link Patient (Optional)',
                style: AppTextStyles.heading4,
              ),
              const SizedBox(height: 8),
              const Text(
                'You can link a patient now or do it later',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: localizations.patientCode,
                hintText: localizations.patientCodeHint,
                controller: _patientCodeController,
                prefixIcon: Icons.link_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: localizations.relationship,
                hintText: 'e.g., Parent, Spouse, Sibling',
                controller: _relationshipController,
                prefixIcon: Icons.people_outline,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: localizations.register,
                onPressed: _handleRegister,
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.alreadyHaveAccount,
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      localizations.login,
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
      ref.read(authProvider.notifier).registerGuardian(
            nationalId: _nationalIdController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text,
            password: _passwordController.text,
            patientCode: _patientCodeController.text.trim().isEmpty
                ? null
                : _patientCodeController.text.trim(),
            relationship: _relationshipController.text.trim().isEmpty
                ? null
                : _relationshipController.text.trim(),
          );
    }
  }
}
