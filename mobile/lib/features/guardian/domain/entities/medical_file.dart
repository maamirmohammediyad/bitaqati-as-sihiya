import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_file.freezed.dart';
part 'medical_file.g.dart';

@freezed
class MedicalFile with _$MedicalFile {
  const factory MedicalFile({
    required String id,

    @JsonKey(name: 'original_name') required String originalName,

    @JsonKey(name: 'file_type') String? fileType,

    String? description,

    @JsonKey(name: 'size_bytes') int? sizeBytes,

    @JsonKey(name: 'mime_type') String? mimeType,

    String? url,

    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MedicalFile;

  factory MedicalFile.fromJson(Map<String, dynamic> json) =>
      _$MedicalFileFromJson(json);
}
