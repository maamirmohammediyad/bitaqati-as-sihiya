// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicalFile _$MedicalFileFromJson(Map<String, dynamic> json) {
  return _MedicalFile.fromJson(json);
}

/// @nodoc
mixin _$MedicalFile {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_name')
  String get originalName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_type')
  String? get fileType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_bytes')
  int? get sizeBytes => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String? get mimeType => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MedicalFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalFileCopyWith<MedicalFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalFileCopyWith<$Res> {
  factory $MedicalFileCopyWith(
    MedicalFile value,
    $Res Function(MedicalFile) then,
  ) = _$MedicalFileCopyWithImpl<$Res, MedicalFile>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'original_name') String originalName,
    @JsonKey(name: 'file_type') String? fileType,
    String? description,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    @JsonKey(name: 'mime_type') String? mimeType,
    String? url,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$MedicalFileCopyWithImpl<$Res, $Val extends MedicalFile>
    implements $MedicalFileCopyWith<$Res> {
  _$MedicalFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalName = null,
    Object? fileType = freezed,
    Object? description = freezed,
    Object? sizeBytes = freezed,
    Object? mimeType = freezed,
    Object? url = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            originalName: null == originalName
                ? _value.originalName
                : originalName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileType: freezed == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sizeBytes: freezed == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicalFileImplCopyWith<$Res>
    implements $MedicalFileCopyWith<$Res> {
  factory _$$MedicalFileImplCopyWith(
    _$MedicalFileImpl value,
    $Res Function(_$MedicalFileImpl) then,
  ) = __$$MedicalFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'original_name') String originalName,
    @JsonKey(name: 'file_type') String? fileType,
    String? description,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    @JsonKey(name: 'mime_type') String? mimeType,
    String? url,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$MedicalFileImplCopyWithImpl<$Res>
    extends _$MedicalFileCopyWithImpl<$Res, _$MedicalFileImpl>
    implements _$$MedicalFileImplCopyWith<$Res> {
  __$$MedicalFileImplCopyWithImpl(
    _$MedicalFileImpl _value,
    $Res Function(_$MedicalFileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicalFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalName = null,
    Object? fileType = freezed,
    Object? description = freezed,
    Object? sizeBytes = freezed,
    Object? mimeType = freezed,
    Object? url = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MedicalFileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        originalName: null == originalName
            ? _value.originalName
            : originalName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileType: freezed == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sizeBytes: freezed == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicalFileImpl implements _MedicalFile {
  const _$MedicalFileImpl({
    required this.id,
    @JsonKey(name: 'original_name') required this.originalName,
    @JsonKey(name: 'file_type') this.fileType,
    this.description,
    @JsonKey(name: 'size_bytes') this.sizeBytes,
    @JsonKey(name: 'mime_type') this.mimeType,
    this.url,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$MedicalFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicalFileImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'original_name')
  final String originalName;
  @override
  @JsonKey(name: 'file_type')
  final String? fileType;
  @override
  final String? description;
  @override
  @JsonKey(name: 'size_bytes')
  final int? sizeBytes;
  @override
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  @override
  final String? url;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MedicalFile(id: $id, originalName: $originalName, fileType: $fileType, description: $description, sizeBytes: $sizeBytes, mimeType: $mimeType, url: $url, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalFileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalName, originalName) ||
                other.originalName == originalName) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    originalName,
    fileType,
    description,
    sizeBytes,
    mimeType,
    url,
    createdAt,
  );

  /// Create a copy of MedicalFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalFileImplCopyWith<_$MedicalFileImpl> get copyWith =>
      __$$MedicalFileImplCopyWithImpl<_$MedicalFileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalFileImplToJson(this);
  }
}

abstract class _MedicalFile implements MedicalFile {
  const factory _MedicalFile({
    required final String id,
    @JsonKey(name: 'original_name') required final String originalName,
    @JsonKey(name: 'file_type') final String? fileType,
    final String? description,
    @JsonKey(name: 'size_bytes') final int? sizeBytes,
    @JsonKey(name: 'mime_type') final String? mimeType,
    final String? url,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$MedicalFileImpl;

  factory _MedicalFile.fromJson(Map<String, dynamic> json) =
      _$MedicalFileImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'original_name')
  String get originalName;
  @override
  @JsonKey(name: 'file_type')
  String? get fileType;
  @override
  String? get description;
  @override
  @JsonKey(name: 'size_bytes')
  int? get sizeBytes;
  @override
  @JsonKey(name: 'mime_type')
  String? get mimeType;
  @override
  String? get url;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of MedicalFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalFileImplCopyWith<_$MedicalFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
