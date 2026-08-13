import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/account_provider.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';

class PatientEditAccountScreen extends ConsumerStatefulWidget {
  const PatientEditAccountScreen({super.key});

  @override
  ConsumerState<PatientEditAccountScreen> createState() =>
      _PatientEditAccountScreenState();
}

class _PatientEditAccountScreenState
    extends ConsumerState<PatientEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  String _savedEmail = '';
  @override
  void initState() {
    super.initState();

 final user = ref.read(authProvider).user;
_savedEmail = (user?.email ?? '').trim().toLowerCase();

_emailController = TextEditingController(
  text: user?.email ?? '',
);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
bool get _hasEmailChanged {
  return _emailController.text.trim().toLowerCase() != _savedEmail;
}
  Future<void> _saveEmail() async {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

try {
  await ref.read(accountActionsProvider).updateEmail(
        email: _emailController.text.trim(),
      );

  if (!mounted) return;

  setState(() {
    _savedEmail = _emailController.text.trim().toLowerCase();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('تم حفظ البريد الإلكتروني بنجاح'),
      backgroundColor: AppColors.success,
    ),
  );
} on DioException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_extractErrorMessage(error)),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ البريد الإلكتروني، حاول مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

String _extractErrorMessage(DioException error) {
  final data = error.response?.data;

  if (data is Map) {
    final errors = data['errors'];

    if (errors is Map && errors['email'] is List) {
      final emailErrors = errors['email'] as List;

      if (emailErrors.isNotEmpty) {
        return emailErrors.first.toString();
      }
    }

    if (data['message'] != null) {
      return data['message'].toString();
    }
  }

  if (error.response?.statusCode == 401) {
    return 'انتهت الجلسة. سجّل الدخول مجددًا.';
  }

  if (error.response?.statusCode == 403) {
    return 'هذه العملية متاحة للمريض فقط.';
  }

  return 'تعذر حفظ البريد الإلكتروني. حاول مرة أخرى.';
}

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(accountLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('البريد الإلكتروني')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'أضف بريدك الإلكتروني لتسهيل التواصل واستعادة الحساب.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'أدخل البريد الإلكتروني';
                  }

                  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                  if (!pattern.hasMatch(email)) {
                    return 'أدخل بريدًا إلكترونيًا صحيحًا';
                  }

                  return null;
                },
                onChanged: (_) {
  setState(() {});
},
onFieldSubmitted: (_) {
  if (_hasEmailChanged) {
    _saveEmail();
  }
},
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: isLoading || !_hasEmailChanged ? null : _saveEmail,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('حفظ البريد الإلكتروني'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
