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

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

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

  // يمكن حذفها لو لن تستعملها مستقبلاً
  final _allergiesController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();

  // إدخال كـ tags
  final _allergyInputController = TextEditingController();
  final _chronicInputController = TextEditingController();

  final List<String> _allergies = [];
  final List<String> _chronicDiseases = [];

  bool _isSubmitting = false;

  @override
void initState() {
  super.initState();
  // نؤجل القراءة حتى بعد بناء أول frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initFromExtra();
  });
}

void _initFromExtra() {
  final routerState = GoRouterState.of(context);
  final extra = routerState.extra;

  debugPrint('EXTRA IN COMPLETE PROFILE: $extra');

  // extra متوقَّع يكون Map فيها profile من نوع PatientProfileSummary
  if (extra is Map<String, Object?> && extra['profile'] != null) {
    final profile = extra['profile'] as PatientProfileSummary;

    try {
      // dateOfBirth في الكلاس عندك String? بصيغة yyyy-MM-dd
      final dobString = profile.dateOfBirth;
      if (dobString != null && dobString.isNotEmpty) {
        _dateOfBirth = DateTime.tryParse(dobString);
      }

      // الجنس
      _gender = profile.gender;

      // فصيلة الدم
      _bloodGroup = profile.bloodGroup;

      // الطول (double?) نحوله لنص
      final height = profile.heightCm;
      if (height != null) {
        _heightController.text = height.toString();
      }

      // الوزن
      final weight = profile.weightKg;
      if (weight != null) {
        _weightController.text = weight.toString();
      }

      // ملاحظة: PatientProfileSummary لا يحتوي allergies أو chronicDiseases
      // لذلك نترك _allergies و _chronicDiseases فارغين حالياً

      setState(() {});
    } catch (e) {
      debugPrint('Error parsing profile in CompleteProfileScreen: $e');
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null || _gender == null || _bloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة الحقول الأساسية'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(apiClientProvider).dio;

      // 1) البيانات المشتركة
      final Map<String, dynamic> data = {
        'date_of_birth': _dateOfBirth!.toIso8601String(),
        'gender': _gender,
        'blood_group': _bloodGroup,
        'height_cm': int.tryParse(_heightController.text),
        'weight_kg': int.tryParse(_weightController.text),
        'allergies': _allergies.isNotEmpty ? _allergies.join(', ') : null,
        'chronic_diseases':
            _chronicDiseases.isNotEmpty ? _chronicDiseases.join(', ') : null,
      };

      // 2) نحدد المستخدم الحالي
      final authState = ref.read(authProvider);
      final currentUser = authState.user;

      // 3) لو المستخدم ولي، نحاول قراءة patientId من extra
      final routerState = GoRouterState.of(context);
final extra = routerState.extra;

final bool isGuardian =
    currentUser != null && currentUser.role == 'guardian';

if (isGuardian &&
    extra is Map<String, Object?> &&
    extra['patientId'] is String) {
  data['patient_id'] = extra['patientId'];
}

      debugPrint('*** COMPLETE PROFILE DATA ***');
      debugPrint(data.toString());

      await dio.post(
        ApiConstants.completePatientProfile,
        data: data,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      if (!mounted) return;

      // توجيه بعد الحفظ
      if (isGuardian) {
        context.goNamed('guardianHome');
      } else {
        context.goNamed('patientHome');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملف الطبي بنجاح'),
        ),
      );
    } on DioException catch (e, st) {
      debugPrint('LOCAL DIO ERROR: $e');
      debugPrint('LOCAL DIO STACK: $st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DioException: $e')),
      );
    } catch (e, st) {
      debugPrint('LOCAL OTHER ERROR: $e');
      debugPrint('LOCAL OTHER STACK: $st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Other error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
      if (context.canPop()) {
        context.pop();
        return;
      }

      final authState = ref.read(authProvider);

      if (authState.isGuardian) {
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'مثال: 170',
                ),
              ),
              const SizedBox(height: 16),

              // الوزن
              Text('الوزن (كغ)', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'مثال: 65',
                ),
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