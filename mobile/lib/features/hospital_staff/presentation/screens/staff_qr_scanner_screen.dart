import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:bitaqati_as_sihiya/core/errors/app_exceptions.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

class StaffQrScannerScreen extends ConsumerStatefulWidget {
  final bool emergencyMode;

  const StaffQrScannerScreen({
    super.key,
    this.emergencyMode = false,
  });

  @override
  ConsumerState<StaffQrScannerScreen> createState() =>
      _StaffQrScannerScreenState();
}
class _StaffQrScannerScreenState
    extends ConsumerState<StaffQrScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isCameraPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cameraController.stop();
      return;
    }

    if (state == AppLifecycleState.resumed &&
        !_isProcessing &&
        !_isCameraPaused) {
      _cameraController.start();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _isCameraPaused) {
      return;
    }

    String qrValue = '';

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();

      if (value != null && value.isNotEmpty) {
        qrValue = value;
        break;
      }
    }

    if (qrValue.isEmpty) {
      return;
    }

    _isProcessing = true;
    await _cameraController.stop();

    if (!mounted) {
      return;
    }

    setState(() {});

try {
  if (widget.emergencyMode) {
    final emergency = await _checkInEmergency(qrValue);

    if (!mounted) {
      return;
    }

    final emergencyId = emergency['id']?.toString();

    if (emergencyId == null || emergencyId.isEmpty) {
      throw Exception('استجابة الخادم لا تحتوي على رقم حالة الطوارئ.');
    }

    context.pushReplacement(
      '/staff/emergencies/${Uri.encodeComponent(emergencyId)}',
    );

    return;
  }

  final patient = await _verifyPatientQr(qrValue);

  if (!mounted) {
    return;
  }

  final patientId = patient['id']?.toString();

  if (patientId == null || patientId.isEmpty) {
    throw Exception('استجابة الخادم لا تحتوي على رقم المريض.');
  }

  final patientName = patient['full_name']?.toString() ??
      patient['name']?.toString() ??
      patient['patient_name']?.toString() ??
      'المريض';

  context.pushReplacement(
    '/staff/patients/${Uri.encodeComponent(patientId)}',
    extra: patientName,
  );
  }
   catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(_errorMessage(error)),
        ),
      );

      _isProcessing = false;

      if (mounted && !_isCameraPaused) {
        await _cameraController.start();
      }

      if (mounted) {
        setState(() {});
      }
    }
  }
Future<Map<String, dynamic>> _verifyPatientQr(String qrValue) async {
  final apiClient = ref.read(apiClientProvider);

  final response = await apiClient.post<dynamic>(
    '/hospital/patients/scan-qr',
    data: {
      'token': qrValue,
    },
  );

  final body = response.data;

  if (body is! Map) {
    throw Exception('استجابة غير متوقعة من الخادم.');
  }

  final map = Map<String, dynamic>.from(body);
  final data = map['data'];

  if (data is! Map || data['patient'] is! Map) {
    throw Exception(
      map['message']?.toString() ??
          'تعذر استخراج بيانات المريض من استجابة الخادم.',
    );
  }

  return Map<String, dynamic>.from(data['patient'] as Map);
}

Future<Map<String, dynamic>> _checkInEmergency(String qrToken) async {
  final apiClient = ref.read(apiClientProvider);

  final response = await apiClient.post<dynamic>(
    '/hospital/emergencies/scan-qr',
    data: {
      'qr_token': qrToken,
    },
  );

  final body = response.data;

  if (body is! Map) {
    throw Exception('استجابة غير متوقعة من الخادم.');
  }

  final map = Map<String, dynamic>.from(body);
  final data = map['data'];

  if (data is! Map) {
    throw Exception(
      map['message']?.toString() ??
          'تعذر تسجيل وصول حالة الطوارئ.',
    );
  }

  return Map<String, dynamic>.from(data);
}
  String _errorMessage(Object error) {
    if (error is DioException) {
      final customError = error.error;

      if (customError is AppException) {
        return customError.message;
      }

      final statusCode = error.response?.statusCode;

      if (statusCode == 401) {
        return 'انتهت صلاحية تسجيل الدخول. يرجى تسجيل الدخول مجددًا.';
      }

      if (statusCode == 403) {
        return 'ليس لديك الصلاحية للوصول إلى بيانات هذا المريض.';
      }

      if (statusCode == 404) {
  final message = error.response?.data is Map
      ? (error.response?.data['message']?.toString())
      : null;

  return message?.isNotEmpty == true
      ? message!
      : 'رمز QR غير صالح أو لم يتم العثور على المريض.';
}

      return 'تعذر التحقق من رمز QR. تحقق من الاتصال ثم حاول مجددًا.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _toggleTorch() async {
    await _cameraController.toggleTorch();

    if (mounted) {
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    }
  }

  Future<void> _switchCamera() async {
    await _cameraController.switchCamera();
  }

  Future<void> _togglePause() async {
    if (_isCameraPaused) {
      await _cameraController.start();
    } else {
      await _cameraController.stop();
    }

    if (mounted) {
      setState(() {
        _isCameraPaused = !_isCameraPaused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
  widget.emergencyMode
      ? 'مسح QR للطوارئ'
      : 'مسح الكود الصحي',
),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _isTorchOn ? 'إيقاف الفلاش' : 'تشغيل الفلاش',
            onPressed: _toggleTorch,
            icon: Icon(
              _isTorchOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
            ),
          ),
          IconButton(
            tooltip: 'تبديل الكاميرا',
            onPressed: _switchCamera,
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return _CameraErrorView(
                error: error,
                onRetry: () async {
                  await _cameraController.start();
                },
              );
            },
          ),
          const _QrScannerOverlay(),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Column(
              children: [
                Text(
                  _isProcessing
    ? 'جارٍ التحقق من رمز المريض...'
    : widget.emergencyMode
        ? 'امسح رمز QR للمريض لتأكيد وصوله إلى الطوارئ'
        : 'وجّه الكاميرا نحو رمز QR الخاص بالمريض',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _isProcessing ? null : _togglePause,
                  icon: Icon(
                    _isCameraPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                  label: Text(
                    _isCameraPaused ? 'متابعة المسح' : 'إيقاف المسح مؤقتًا',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () => context.push('/staff/scanned-patients'),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('سجل المرضى الممسوحين'),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _QrScannerOverlay extends StatelessWidget {
  const _QrScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  final MobileScannerException error;
  final Future<void> Function() onRetry;

  const _CameraErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'تم رفض إذن الكاميرا. فعّل إذن الكاميرا من إعدادات التطبيق.'
        : 'تعذر تشغيل الكاميرا. تحقق من الإذن ثم أعد المحاولة.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_rounded,
              color: Colors.white,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}