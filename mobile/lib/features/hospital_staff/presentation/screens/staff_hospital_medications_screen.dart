import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';

class StaffHospitalMedicationsScreen extends ConsumerStatefulWidget {
  const StaffHospitalMedicationsScreen({super.key});

  @override
  ConsumerState<StaffHospitalMedicationsScreen> createState() =>
      _StaffHospitalMedicationsScreenState();
}

class _StaffHospitalMedicationsScreenState
    extends ConsumerState<StaffHospitalMedicationsScreen> {
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _canManage {
    final role = ref.read(authProvider).user?.hospitalStaffRole;
    return role == 'doctor' || role == 'admin';
  }

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications({String? search}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ref.read(apiClientProvider).get(
        ApiConstants.hospitalMedications,
        queryParameters: {
          if ((search ?? '').trim().isNotEmpty) 'search': search!.trim(),
        },
      );

      final body = response.data;

      if (body is! Map || body['data'] is! List) {
        throw const FormatException();
      }

      final items = (body['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _medications = items;
        _isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _dioErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل قائمة أدوية المستشفى.';
      });
    }
  }

  String _dioErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message']?.toString().trim();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;

        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
      }
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      case 403:
        return 'ليس لديك صلاحية لتنفيذ هذه العملية.';
      case 404:
        return 'لم يتم العثور على الدواء.';
      case 422:
        return 'تحقق من بيانات الدواء والجرعات.';
      case 500:
        return 'حدث خطأ في الخادم. حاول لاحقًا.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة الاتصال بالخادم.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم. تحقق من الإنترنت.';
    }

    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }

  String _value(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  List<String> _doses(Map<String, dynamic> medication) {
    final rawDoses = medication['recommended_doses'];

    if (rawDoses is! List) return [];

    return rawDoses
        .map((dose) => dose.toString().trim())
        .where((dose) => dose.isNotEmpty)
        .toList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }

  Future<void> _showMedicationSheet({
    Map<String, dynamic>? medication,
  }) async {
    final isEditing = medication != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: medication == null ? '' : _value(medication['name']),
    );

    final genericNameController = TextEditingController(
      text: medication == null ? '' : _value(medication['generic_name']),
    );

    final doses = medication == null
        ? <String>['']
        : (_doses(medication).isEmpty ? <String>[''] : _doses(medication));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'تعديل الدواء' : 'إضافة دواء جديد',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          enabled: !_isSaving,
                          maxLength: 150,
                          decoration: const InputDecoration(
                            labelText: 'اسم الدواء التجاري',
                            hintText: 'مثال: Panadol',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'اسم الدواء مطلوب.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: genericNameController,
                          enabled: !_isSaving,
                          maxLength: 150,
                          decoration: const InputDecoration(
                            labelText: 'الاسم العلمي (اختياري)',
                            hintText: 'مثال: Paracetamol',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'الجرعات المتاحة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(doses.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: doses[index],
                                    enabled: !_isSaving,
                                    decoration: InputDecoration(
                                      labelText: 'الجرعة ${index + 1}',
                                      hintText: 'مثال: 500 mg',
                                      border: const OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      doses[index] = value;
                                    },
                                    validator: (value) {
                                      if ((value ?? '').trim().isEmpty) {
                                        return 'أدخل الجرعة أو احذف الحقل.';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'حذف الجرعة',
                                  onPressed: _isSaving || doses.length == 1
                                      ? null
                                      : () {
                                          setModalState(() {
                                            doses.removeAt(index);
                                          });
                                        },
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    setModalState(() {
                                      doses.add('');
                                    });
                                  },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('إضافة جرعة'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () async {
                                    if (!(formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    final cleanDoses = doses
                                        .map((dose) => dose.trim())
                                        .where((dose) => dose.isNotEmpty)
                                        .toSet()
                                        .toList();

                                    if (cleanDoses.isEmpty) {
                                      _showSnackBar(
                                        'أضف جرعة واحدة على الأقل.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _isSaving = true;
                                    });

                                    final success = await _saveMedication(
                                      medicationId:
                                          medication?['id']?.toString(),
                                      name: nameController.text.trim(),
                                      genericName:
                                          genericNameController.text.trim(),
                                      doses: cleanDoses,
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      _isSaving = false;
                                    });

                                    if (success &&
                                        Navigator.of(sheetContext).canPop()) {
                                      Navigator.of(sheetContext).pop();
                                    }
                                  },
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    isEditing
                                        ? Icons.save_rounded
                                        : Icons.add_rounded,
                                  ),
                            label: Text(
                              _isSaving
                                  ? 'جارٍ الحفظ...'
                                  : isEditing
                                  ? 'حفظ التعديلات'
                                  : 'إضافة الدواء',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    genericNameController.dispose();
  }

  Future<bool> _saveMedication({
    String? medicationId,
    required String name,
    required String genericName,
    required List<String> doses,
  }) async {
    try {
      final data = {
        'name': name,
        'generic_name': genericName.isEmpty ? null : genericName,
        'recommended_doses': doses,
      };

      final response = medicationId == null
          ? await ref.read(apiClientProvider).post(
                ApiConstants.hospitalMedications,
                data: data,
              )
          : await ref.read(apiClientProvider).patch(
                '${ApiConstants.hospitalMedications}/$medicationId',
                data: data,
              );

      final body = response.data;

      if (body is! Map) {
        throw const FormatException();
      }

      await _loadMedications(search: _searchController.text);

      if (!mounted) return false;

      _showSnackBar(
        body['message']?.toString() ??
            (medicationId == null
                ? 'تمت إضافة الدواء بنجاح.'
                : 'تم تحديث الدواء بنجاح.'),
      );

      return true;
    } on DioException catch (error) {
      _showSnackBar(_dioErrorMessage(error), isError: true);
      return false;
    } catch (_) {
      _showSnackBar('تعذر حفظ الدواء. حاول مرة أخرى.', isError: true);
      return false;
    }
  }

  Future<bool> _confirmDelete(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الدواء'),
          content: Text(
            'هل تريد حذف "$name" من قائمة أدوية المستشفى؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _deleteMedication(
    Map<String, dynamic> medication,
  ) async {
    final medicationId = _value(medication['id']);
    final name = _value(medication['name'], fallback: 'هذا الدواء');

    if (medicationId.isEmpty) {
      _showSnackBar('معرف الدواء غير صالح.', isError: true);
      return;
    }

    final confirmed = await _confirmDelete(name);

    if (!confirmed) {
      await _loadMedications(search: _searchController.text);
      return;
    }

    try {
      final response = await ref.read(apiClientProvider).delete(
        '${ApiConstants.hospitalMedications}/$medicationId',
      );

      final body = response.data;

      if (!mounted) return;

      setState(() {
        _medications.removeWhere(
          (item) => item['id']?.toString() == medicationId,
        );
      });

      _showSnackBar(
        body is Map
            ? body['message']?.toString() ?? 'تم حذف الدواء.'
            : 'تم حذف الدواء.',
      );
    } on DioException catch (error) {
      if (!mounted) return;
      _showSnackBar(_dioErrorMessage(error), isError: true);
      await _loadMedications(search: _searchController.text);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('تعذر حذف الدواء. حاول مرة أخرى.', isError: true);
      await _loadMedications(search: _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canManage) {
      return Scaffold(
        appBar: AppBar(title: const Text('إدارة الأدوية')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'هذه الصفحة متاحة للطبيب أو مدير المستشفى فقط.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأدوية'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _isLoading
                ? null
                : () => _loadMedications(
                      search: _searchController.text,
                    ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _isSaving ? null : _showMedicationSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة دواء'),
            ),
      body: RefreshIndicator(
        onRefresh: () => _loadMedications(
          search: _searchController.text,
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: _loadMedications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => _loadMedications(search: value),
          decoration: InputDecoration(
            hintText: 'ابحث باسم الدواء أو الاسم العلمي',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'مسح البحث',
                    onPressed: () {
                      _searchController.clear();
                      _loadMedications();
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        Text(
          '${_medications.length} دواء متاح',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_medications.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 64),
            child: Column(
              children: [
                Icon(Icons.medication_outlined, size: 72),
                SizedBox(height: 16),
                Text(
                  'لا توجد أدوية مضافة لهذا المستشفى.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._medications.map(_buildMedicationItem),
      ],
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    final name = _value(medication['name'], fallback: 'دواء بدون اسم');
    final genericName = _value(medication['generic_name']);
    final doses = _doses(medication);

    return Dismissible(
      key: ValueKey('hospital-medication-${medication['id']}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteMedication(medication);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            child: Icon(
              Icons.medication_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (genericName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(genericName),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: doses
                    .map(
                      (dose) => Chip(
                        label: Text(dose),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          trailing: IconButton(
            tooltip: 'تعديل الدواء',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isSaving
                ? null
                : () => _showMedicationSheet(medication: medication),
          ),
          onTap: _isSaving
              ? null
              : () => _showMedicationSheet(medication: medication),
        ),
      ),
    );
  }
}