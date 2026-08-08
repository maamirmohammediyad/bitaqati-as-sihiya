// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicalFileImpl _$$MedicalFileImplFromJson(Map<String, dynamic> json) =>
    _$MedicalFileImpl(
      id: json['id'] as String,
      originalName: json['original_name'] as String,
      fileType: json['file_type'] as String?,
      description: json['description'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MedicalFileImplToJson(_$MedicalFileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'original_name': instance.originalName,
      'file_type': instance.fileType,
      'description': instance.description,
      'size_bytes': instance.sizeBytes,
      'mime_type': instance.mimeType,
      'url': instance.url,
      'created_at': instance.createdAt?.toIso8601String(),
    };
