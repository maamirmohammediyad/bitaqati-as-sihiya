// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_patient_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RegisterPatientResponse {
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  User get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'token')
  String get token => throw _privateConstructorUsedError;

  /// Create a copy of RegisterPatientResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterPatientResponseCopyWith<RegisterPatientResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterPatientResponseCopyWith<$Res> {
  factory $RegisterPatientResponseCopyWith(
    RegisterPatientResponse value,
    $Res Function(RegisterPatientResponse) then,
  ) = _$RegisterPatientResponseCopyWithImpl<$Res, RegisterPatientResponse>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _userFromJson, toJson: _userToJson) User user,
    @JsonKey(name: 'token') String token,
  });
}

/// @nodoc
class _$RegisterPatientResponseCopyWithImpl<
  $Res,
  $Val extends RegisterPatientResponse
>
    implements $RegisterPatientResponseCopyWith<$Res> {
  _$RegisterPatientResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterPatientResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? token = null}) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterPatientResponseImplCopyWith<$Res>
    implements $RegisterPatientResponseCopyWith<$Res> {
  factory _$$RegisterPatientResponseImplCopyWith(
    _$RegisterPatientResponseImpl value,
    $Res Function(_$RegisterPatientResponseImpl) then,
  ) = __$$RegisterPatientResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _userFromJson, toJson: _userToJson) User user,
    @JsonKey(name: 'token') String token,
  });
}

/// @nodoc
class __$$RegisterPatientResponseImplCopyWithImpl<$Res>
    extends
        _$RegisterPatientResponseCopyWithImpl<
          $Res,
          _$RegisterPatientResponseImpl
        >
    implements _$$RegisterPatientResponseImplCopyWith<$Res> {
  __$$RegisterPatientResponseImplCopyWithImpl(
    _$RegisterPatientResponseImpl _value,
    $Res Function(_$RegisterPatientResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterPatientResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? token = null}) {
    return _then(
      _$RegisterPatientResponseImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RegisterPatientResponseImpl implements _RegisterPatientResponse {
  const _$RegisterPatientResponseImpl({
    @JsonKey(fromJson: _userFromJson, toJson: _userToJson) required this.user,
    @JsonKey(name: 'token') required this.token,
  });

  @override
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final User user;
  @override
  @JsonKey(name: 'token')
  final String token;

  @override
  String toString() {
    return 'RegisterPatientResponse(user: $user, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterPatientResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.token, token) || other.token == token));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, token);

  /// Create a copy of RegisterPatientResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterPatientResponseImplCopyWith<_$RegisterPatientResponseImpl>
  get copyWith =>
      __$$RegisterPatientResponseImplCopyWithImpl<
        _$RegisterPatientResponseImpl
      >(this, _$identity);
}

abstract class _RegisterPatientResponse implements RegisterPatientResponse {
  const factory _RegisterPatientResponse({
    @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
    required final User user,
    @JsonKey(name: 'token') required final String token,
  }) = _$RegisterPatientResponseImpl;

  @override
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  User get user;
  @override
  @JsonKey(name: 'token')
  String get token;

  /// Create a copy of RegisterPatientResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterPatientResponseImplCopyWith<_$RegisterPatientResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
