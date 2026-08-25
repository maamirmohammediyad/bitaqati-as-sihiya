import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

class StaffPatientMedicationsScreen extends ConsumerStatefulWidget {
  const StaffPatientMedicationsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  ConsumerState<StaffPatientMedicationsScreen> createState() =>
      _StaffPatientMedicationsScreenState();
}

class _StaffPatientMedicationsScreenState
    extends ConsumerState<StaffPatientMedicationsScreen> {
  List<Map<String, dynamic>> medications = [];
  bool canUpdate = false;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMedications();
  }

  Future<void> loadMedications() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await ref.read(apiClientProvider).get<dynamic>(
            ApiConstants.hospitalPatientMedications(widget.patientId),
          );

      final body = response.data;

      if (body is! Map || body['data'] is! List) {
        throw const FormatException('صيغة بيانات الأدوية غير صحيحة.');
      }

      final items = (body['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        medications = items;
        canUpdate = body['can_update'] == true;
        isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = dioErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'تعذر تحميل قائمة أدوية المريض.';
      });
    }
  }

  String dioErrorMessage(DioException error) {
    final body = error.response?.data;

    if (body is Map) {
      final message = body['message']?.toString().trim();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = body['errors'];
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
        return 'لم يتم العثور على المريض أو الدواء.';
      case 422:
        return 'البيانات المدخلة غير صحيحة.';
      case 500:
        return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة الاتصال بالخادم.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالإنترنت أو بالخادم.';
    }

    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }

  String value(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  String formatDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';

    if (raw.isEmpty || raw == 'null') {
      return '-';
    }

    final date = DateTime.tryParse(raw);

    if (date == null) {
      return raw;
    }

    final local = date.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'م' : 'ص';

    return '${local.year}/${local.month.toString().padLeft(2, '0')}/'
        '${local.day.toString().padLeft(2, '0')} - $hour:$minute $period';
  }

  Future<void> showAddMedicationSheet() async {
    List<Map<String, dynamic>> hospitalMedications = [];
    String? loadingError;
    bool isLoadingCatalog = true;
    String? selectedMedicationId;
    String? selectedDose;
    final instructionsController = TextEditingController();

    try {
      final response = await ref.read(apiClientProvider).get<dynamic>(
            ApiConstants.hospitalMedications,
          );

      final body = response.data;

      if (body is! Map || body['data'] is! List) {
        throw const FormatException();
      }

      hospitalMedications = (body['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      isLoadingCatalog = false;
    } on DioException catch (error) {
      loadingError = dioErrorMessage(error);
      isLoadingCatalog = false;
    } catch (_) {
      loadingError = 'تعذر تحميل قائمة أدوية المستشفى.';
      isLoadingCatalog = false;
    }

    if (!mounted) {
      instructionsController.dispose();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Map<String, dynamic>? selectedMedication;

            for (final medication in hospitalMedications) {
              if (medication['id']?.toString() == selectedMedicationId) {
                selectedMedication = medication;
                break;
              }
            }

            final doses = selectedMedication?['recommended_doses'] is List
                ? (selectedMedication!['recommended_doses'] as List)
                    .map((dose) => dose.toString().trim())
                    .where((dose) => dose.isNotEmpty)
                    .toList()
                : <String>[];

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إضافة دواء للمريض',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.patientName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      if (isLoadingCatalog)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (loadingError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loadingError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                showAddMedicationSheet();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        )
                      else if (hospitalMedications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('لا توجد أدوية نشطة مضافة لهذا المستشفى.'),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          value: selectedMedicationId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'الدواء',
                            border: OutlineInputBorder(),
                          ),
                          items: hospitalMedications.map((medication) {
                            final name = value(
                              medication['name'],
                              fallback: 'دواء بدون اسم',
                            );
                            final genericName = value(
                              medication['generic_name'],
                              fallback: '',
                            );

                            return DropdownMenuItem<String>(
                              value: medication['id']?.toString(),
                              child: Text(
                                genericName.isEmpty
                                    ? name
                                    : '$name ($genericName)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: isSaving
                              ? null
                              : (newValue) {
                                  setModalState(() {
                                    selectedMedicationId = newValue;
                                    selectedDose = null;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedDose,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'الجرعة',
                            border: OutlineInputBorder(),
                          ),
                          items: doses
                              .map(
                                (dose) => DropdownMenuItem<String>(
                                  value: dose,
                                  child: Text(dose),
                                ),
                              )
                              .toList(),
                          onChanged: selectedMedicationId == null || isSaving
                              ? null
                              : (newValue) {
                                  setModalState(() {
                                    selectedDose = newValue;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: instructionsController,
                          enabled: !isSaving,
                          maxLength: 500,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'التعليمات (اختياري)',
                            hintText: 'مثال: بعد الطعام',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (selectedMedicationId == null) {
                                      showSnackBar(
                                        'يرجى اختيار الدواء أولاً.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    if (selectedDose == null) {
                                      showSnackBar(
                                        'يرجى اختيار الجرعة.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    setModalState(() {
                                      isSaving = true;
                                    });

                                    await addMedication(
                                      medicationId: selectedMedicationId!,
                                      dose: selectedDose!,
                                      instructions:
                                          instructionsController.text.trim(),
                                    );

                                    if (!mounted) return;

                                    Navigator.of(sheetContext).pop();
                                  },
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded),
                            label: Text(
                              isSaving ? 'جارٍ الحفظ...' : 'إضافة الدواء',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    instructionsController.dispose();
  }

  Future<void> addMedication({
    required String medicationId,
    required String dose,
    required String instructions,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post<dynamic>(
            ApiConstants.hospitalPatientMedications(widget.patientId),
            data: {
              'hospital_medication_id': medicationId,
              'dose': dose,
              if (instructions.isNotEmpty) 'instructions': instructions,
            },
          );

      final body = response.data;

      if (body is! Map || body['data'] is! Map) {
        throw const FormatException();
      }

      if (!mounted) return;

      final newMedication = Map<String, dynamic>.from(body['data'] as Map);

      setState(() {
        medications = [newMedication, ...medications];
      });

      showSnackBar(
        body['message']?.toString() ?? 'تمت إضافة الدواء بنجاح.',
        isError: false,
      );
    } on DioException catch (error) {
      if (!mounted) return;

      showSnackBar(dioErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;

      showSnackBar('تعذر إضافة الدواء. حاول مرة أخرى.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> deleteMedication(Map<String, dynamic> medication) async {
    final medicationId = medication['id']?.toString() ?? '';

    if (medicationId.isEmpty) {
      showSnackBar('معرف دواء المريض غير صالح.', isError: true);
      return;
    }

    final medicationInfo = medication['medication'];
    final medicationMap = medicationInfo is Map
        ? Map<String, dynamic>.from(medicationInfo)
        : <String, dynamic>{};

    final medicationName = value(
      medicationMap['name'],
      fallback: 'هذا الدواء',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الدواء'),
          content: Text(
            'هل تريد حذف "$medicationName" من قائمة أدوية المريض؟',
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

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(apiClientProvider).delete<dynamic>(
            ApiConstants.hospitalPatientMedicationDelete(
              widget.patientId,
              medicationId,
            ),
          );

      if (!mounted) return;

      setState(() {
        medications.removeWhere(
          (item) => item['id']?.toString() == medicationId,
        );
      });

      showSnackBar('تم حذف الدواء من قائمة المريض.', isError: false);
    } on DioException catch (error) {
      if (!mounted) return;

      showSnackBar(dioErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;

      showSnackBar('تعذر حذف الدواء. حاول مرة أخرى.', isError: true);
    }
  }

  void showSnackBar(String message, {required bool isError}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوية المريض'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: isLoading ? null : loadMedications,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: !isLoading && canUpdate
          ? FloatingActionButton.extended(
              onPressed: isSaving ? null : showAddMedicationSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة دواء'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: loadMedications,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
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
            errorMessage!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: loadMedications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }

    if (medications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 110),
          Icon(
            Icons.medication_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أدوية مسجلة لهذا المريض.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          ),
          if (canUpdate) ...[
            const SizedBox(height: 16),
            Center(
              child: FilledButton.icon(
                onPressed: showAddMedicationSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة أول دواء'),
              ),
            ),
          ],
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
      children: [
        Text(
          widget.patientName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${medications.length} دواء مسجل',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ...medications.map(buildMedicationCard),
      ],
    );
  }

  Widget buildMedicationCard(Map<String, dynamic> item) {
    final medicationData = item['medication'];
    final medication = medicationData is Map
        ? Map<String, dynamic>.from(medicationData)
        : <String, dynamic>{};

    final addedByData = item['added_by'];
    final addedBy = addedByData is Map
        ? Map<String, dynamic>.from(addedByData)
        : <String, dynamic>{};

    final name = value(medication['name'], fallback: 'دواء بدون اسم');
    final genericName = value(medication['generic_name'], fallback: '');
    final dose = value(item['dose']);
    final instructions = value(item['instructions'], fallback: '');
    final authorName = value(addedBy['name'], fallback: 'غير معروف');
    final date = formatDateTime(item['created_at']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Icon(
                    Icons.medication_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (genericName.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          genericName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                if (canUpdate)
                  IconButton(
                    tooltip: 'حذف الدواء',
                    onPressed: () => deleteMedication(item),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.straighten_rounded, size: 19),
                const SizedBox(width: 8),
                Text(
                  'الجرعة: $dose',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (instructions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('التعليمات: $instructions'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'أضيف بواسطة: $authorName',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 3),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}