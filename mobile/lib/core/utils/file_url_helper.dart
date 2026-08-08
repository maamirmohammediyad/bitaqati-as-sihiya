import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';

class FileUrlHelper {
  FileUrlHelper._();

  static String toAbsoluteUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) {
      return '';
    }

    final value = pathOrUrl.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // API يعيد غالبًا: /storage/medical_files/...
    if (value.startsWith('/storage/')) {
      return '${ApiConstants.serverUrl}$value';
    }

    // يدعم storage/medical_files/... دون slash في البداية.
    if (value.startsWith('storage/')) {
      return '${ApiConstants.serverUrl}/$value';
    }

    // احتياطًا إن أعاد API مسار الملف فقط دون storage.
    return '${ApiConstants.storageUrl}/${value.replaceFirst(RegExp(r'^/+'), '')}';
  }
}