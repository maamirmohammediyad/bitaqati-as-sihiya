import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_providers.dart';
class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const CompleteProfileScreen({
    super.key,
    this.patientId,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _dateOfBirth;
  String? _gender; // 'male' / 'female'
  String? _bloodGroup;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // إدخال كـ tags
  final _allergyInputController = TextEditingController();
  final _chronicInputController = TextEditingController();

  final List<String> _allergies = [];
  final List<String> _chronicDiseases = [];

  bool _isSubmitting = false;
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _loadInitialProfile();
    }
  });
}
List<String> _splitMedicalItems(String? value) {
  if (value == null || value.trim().isEmpty) {
    return [];
  }

  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

Future<void> _loadInitialProfile() async {
  final authState = ref.read(authProvider);
  final isGuardian = authState.isGuardian;

  // المريض يعدّل ملفه الخاص:
  // في هذا المسار لا نملك patientId من الولي.
  // اترك الحقول فارغة أو حمّل ملف المريض من endpoint مناسب لاحقًا.
  if (!isGuardian) {
    return;
  }
void _fillFieldsFromProfile(PatientProfileSummary profile) {
  final dobString = profile.dateOfBirth;

  _dateOfBirth = dobString == null || dobString.isEmpty
      ? null
      : DateTime.tryParse(dobString);

  _gender = profile.gender;
  _bloodGroup = profile.bloodGroup;

  _heightController.text = profile.heightCm?.toString() ?? '';
  _weightController.text = profile.weightKg?.toString() ?? '';

  _allergies
    ..clear()
    ..addAll(_splitMedicalItems(profile.allergies));

  _chronicDiseases
    ..clear()
    ..addAll(_splitMedicalItems(profile.chronicDiseases));

  if (mounted) {
    setState(() {});
  }
}
  final patientId = widget.patientId;

  if (patientId == null || patientId.isEmpty) {
    debugPrint('CompleteProfileScreen: patientId is missing.');
    return;
  }

  try {
    final dashboard = await ref
        .read(guardianRepositoryProvider)
        .getPatientDashboard(patientId);

    final profile = dashboard.profile;

    if (profile == null) {
      debugPrint('CompleteProfileScreen: patient profile is missing.');
      return;
    }

    _fillFieldsFromProfile(profile);
  } catch (e, stackTrace) {
    debugPrint('Error loading guardian patient profile: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر تحميل بيانات الملف الطبي للمريض'),
      ),
    );
  }
}
  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _addAllergyFromInput() {
    final text = _allergyInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!_allergies.contains(text)) {
        _allergies.add(text);
      }
      _allergyInputController.clear();
    });
  }

  void _removeAllergy(String value) {
    setState(() {
      _allergies.remove(value);
    });
  }

  void _addChronicFromInput() {
    final text = _chronicInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!_chronicDiseases.contains(text)) {
        _chronicDiseases.add(text);
      }
      _chronicInputController.clear();
    });
  }

  void _removeChronic(String value) {
    setState(() {
      _chronicDiseases.remove(value);
    });
  }
double? _parseOptionalNumber(TextEditingController controller) {
  final value = controller.text.trim().replaceAll(',', '.');

  if (value.isEmpty) {
    return null;
  }

  return double.tryParse(value);
}
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_dateOfBirth == null || _gender == null || _bloodGroup == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يرجى تعبئة الحقول الأساسية'),
      ),
    );
    return;
  }

  final authState = ref.read(authProvider);
  final isGuardian = authState.isGuardian;

  final height = _parseOptionalNumber(_heightController);
  final weight = _parseOptionalNumber(_weightController);

  if (_heightController.text.trim().isNotEmpty && height == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('الطول يجب أن يكون رقمًا صحيحًا'),
      ),
    );
    return;
  }

  if (_weightController.text.trim().isNotEmpty && weight == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('الوزن يجب أن يكون رقمًا صحيحًا'),
      ),
    );
    return;
  }

  if (isGuardian &&
      (widget.patientId == null || widget.patientId!.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر تحديد المريض المطلوب تعديل ملفه'),
      ),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final data = <String, dynamic>{
      'date_of_birth': _dateOfBirth!.toIso8601String().split('T').first,
      'gender': _gender,
      'blood_group': _bloodGroup,
      'height_cm': height,
      'weight_kg': weight,
    };

    // لا ترسل null تلقائيًا كي لا تمسح بيانات موجودة
    // عند تعديل حقل آخر مثل الجنس أو الوزن.
    if (_allergies.isNotEmpty) {
      data['allergies'] = _allergies.join(', ');
    }

    if (_chronicDiseases.isNotEmpty) {
      data['chronic_diseases'] = _chronicDiseases.join(', ');
    }

    if (isGuardian) {
      data['patient_id'] = widget.patientId!;
    }

    final response = await ref.read(apiClientProvider).dio.post(
          ApiConstants.completePatientProfile,
          data: data,
        );

    debugPrint('Profile update response: ${response.data}');

    if (!mounted) {
      return;
    }

    if (isGuardian) {
      // هذه الشاشة فُتحت عبر pushNamed من PatientDetailsScreen.
      // true تخبر الصفحة السابقة أن الحفظ نجح.
      context.pop(true);
      return;
    }

    // للمريض نفسه: حدّث معلومات المستخدم ثم اذهب للرئيسية.
    await ref.read(authProvider.notifier).refreshCurrentUser();

    if (!mounted) {
      return;
    }

    context.goNamed('patientHome');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث الملف الطبي بنجاح'),
      ),
    );
  } on DioException catch (e, stackTrace) {
    debugPrint('Profile update Dio error: ${e.message}');
    debugPrint('Profile update server response: ${e.response?.data}');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) {
      return;
    }

    final responseData = e.response?.data;

    final message = responseData is Map<String, dynamic>
        ? (responseData['message']?.toString() ??
            'تعذر تحديث الملف الطبي')
        : 'تعذر تحديث الملف الطبي';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e, stackTrace) {
    debugPrint('Profile update error: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('حدث خطأ غير متوقع أثناء تحديث الملف'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
@override
void dispose() {
  _heightController.dispose();
  _weightController.dispose();
  _allergyInputController.dispose();
  _chronicInputController.dispose();
  super.dispose();
}
  @override
Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
  title: Text(localizations.editProfile),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    tooltip: 'رجوع',
    onPressed: () {
  final isGuardian = ref.read(authProvider).isGuardian;

  if (isGuardian && context.canPop()) {
    context.pop(false);
    return;
  }

  if (isGuardian) {
    context.goNamed('guardianHome');
  } else {
    context.goNamed('patientHome');
  }
},
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'استكمال ملفك الطبي يساعد في تقديم رعاية أفضل في الحالات العادية والطارئة.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),

              // تاريخ الميلاد
              Text(localizations.dateOfBirth, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
                        : 'اختر تاريخ الميلاد',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _dateOfBirth != null
                          ? AppColors.primary
                          : AppColors.grey500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // الجنس
              Text('الجنس', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('ذكر'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('أنثى'),
                  ),
                ],
                onChanged: (value) => setState(() => _gender = value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // فصيلة الدم
              Text(localizations.bloodType, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                items: const [
                  DropdownMenuItem(value: 'A+', child: Text('A+')),
                  DropdownMenuItem(value: 'A-', child: Text('A-')),
                  DropdownMenuItem(value: 'B+', child: Text('B+')),
                  DropdownMenuItem(value: 'B-', child: Text('B-')),
                  DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                  DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                  DropdownMenuItem(value: 'O+', child: Text('O+')),
                  DropdownMenuItem(value: 'O-', child: Text('O-')),
                ],
                onChanged: (value) => setState(() => _bloodGroup = value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // الطول
              Text('الطول (سم)', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'مثال: 170',
                  prefixText: 'cm',
                
                ),
                validator: (value) {
  final input = value?.trim().replaceAll(',', '.') ?? '';

  if (input.isEmpty) {
    return null;
  }

  final height = double.tryParse(input);

  if (height == null || height < 30 || height > 300) {
    return 'أدخل طولًا صحيحًا بين 30 و300 سم';
  }

  return null;
},
              ),
              const SizedBox(height: 16),

              // الوزن
              Text('الوزن (كغ)', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'مثال: 65',
                ),
                validator: (value) {
  final input = value?.trim().replaceAll(',', '.') ?? '';

  if (input.isEmpty) {
    return null;
  }

  final weight = double.tryParse(input);

  if (weight == null || weight < 1 || weight > 700) {
    return 'أدخل وزنًا صحيحًا بين 1 و700 كغ';
  }

  return null;
},
              ),
              const SizedBox(height: 16),

              // الحساسية: إدخال + Chips
              Text(localizations.allergies, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _allergyInputController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اكتب الحساسية ثم اضغط إدخال (Enter)',
                ),
                onSubmitted: (_) => _addAllergyFromInput(),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _allergies
                    .map(
                      (a) => Chip(
                        label: Text(a),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeAllergy(a),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // الأمراض المزمنة: إدخال + Chips
              Text(localizations.chronicDiseases,
                  style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _chronicInputController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اكتب المرض المزمن ثم اضغط إدخال (Enter)',
                ),
                onSubmitted: (_) => _addChronicFromInput(),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _chronicDiseases
                    .map(
                      (d) => Chip(
                        label: Text(d),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeChronic(d),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(
                    _isSubmitting
                        ? localizations.loading
                        : localizations.save,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}