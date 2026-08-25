import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

final accountVerificationApiProvider = Provider<AccountVerificationApi>((ref) {
  return AccountVerificationApi(ref.watch(apiClientProvider));
});

class AccountVerificationDocument {
  final String id;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final DateTime? submittedAt;
  final String status;
  final String? rejectionReason;

  const AccountVerificationDocument({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
    required this.submittedAt,
    required this.status,
    required this.rejectionReason,
  });

  factory AccountVerificationDocument.fromJson(Map<String, dynamic> json) {
    return AccountVerificationDocument(
      id: json['id']?.toString() ?? '',
      originalName: json['original_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      submittedAt: DateTime.tryParse(
        json['submitted_at']?.toString() ?? '',
      ),
      // دعم المستندات القديمة التي ليس لها status مخزّن.
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class AccountVerificationApi {
  final ApiClient _apiClient;

  AccountVerificationApi(this._apiClient);

  Future<AccountVerificationDocument?> getDocument() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/account-verification-document',
    );

    final body = response.data;
    final data = body?['data'];

    if (data == null) {
      return null;
    }

    return AccountVerificationDocument.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<AccountVerificationDocument> uploadDocument({
    required String filePath,
    required String fileName,
  }) async {
    final response = await _apiClient.postFormData<Map<String, dynamic>>(
      '/account-verification-document',
      data: FormData.fromMap({
        'document': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      }),
    );

    final data = response.data?['data'];

    if (data is! Map) {
      throw const FormatException('Invalid document upload response.');
    }

    return AccountVerificationDocument.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}