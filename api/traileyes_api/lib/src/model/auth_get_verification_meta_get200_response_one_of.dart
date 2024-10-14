//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_get_verification_meta_get200_response_one_of.g.dart';

/// AuthGetVerificationMetaGet200ResponseOneOf
///
/// Properties:
/// * [userVerified]
/// * [secondsUntilCanResend]
/// * [email]
/// * [hasActiveCode]
/// * [shouldResend]
@BuiltValue()
abstract class AuthGetVerificationMetaGet200ResponseOneOf
    implements
        Built<AuthGetVerificationMetaGet200ResponseOneOf,
            AuthGetVerificationMetaGet200ResponseOneOfBuilder> {
  @BuiltValueField(wireName: r'userVerified')
  bool get userVerified;

  @BuiltValueField(wireName: r'secondsUntilCanResend')
  int get secondsUntilCanResend;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'hasActiveCode')
  bool get hasActiveCode;

  @BuiltValueField(wireName: r'shouldResend')
  bool get shouldResend;

  AuthGetVerificationMetaGet200ResponseOneOf._();

  factory AuthGetVerificationMetaGet200ResponseOneOf(
          [void updates(AuthGetVerificationMetaGet200ResponseOneOfBuilder b)]) =
      _$AuthGetVerificationMetaGet200ResponseOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthGetVerificationMetaGet200ResponseOneOfBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthGetVerificationMetaGet200ResponseOneOf>
      get serializer =>
          _$AuthGetVerificationMetaGet200ResponseOneOfSerializer();
}

class _$AuthGetVerificationMetaGet200ResponseOneOfSerializer
    implements PrimitiveSerializer<AuthGetVerificationMetaGet200ResponseOneOf> {
  @override
  final Iterable<Type> types = const [
    AuthGetVerificationMetaGet200ResponseOneOf,
    _$AuthGetVerificationMetaGet200ResponseOneOf
  ];

  @override
  final String wireName = r'AuthGetVerificationMetaGet200ResponseOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthGetVerificationMetaGet200ResponseOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userVerified';
    yield serializers.serialize(
      object.userVerified,
      specifiedType: const FullType(bool),
    );
    yield r'secondsUntilCanResend';
    yield serializers.serialize(
      object.secondsUntilCanResend,
      specifiedType: const FullType(int),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'hasActiveCode';
    yield serializers.serialize(
      object.hasActiveCode,
      specifiedType: const FullType(bool),
    );
    yield r'shouldResend';
    yield serializers.serialize(
      object.shouldResend,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthGetVerificationMetaGet200ResponseOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthGetVerificationMetaGet200ResponseOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.userVerified = valueDes;
          break;
        case r'secondsUntilCanResend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.secondsUntilCanResend = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'hasActiveCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasActiveCode = valueDes;
          break;
        case r'shouldResend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.shouldResend = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthGetVerificationMetaGet200ResponseOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthGetVerificationMetaGet200ResponseOneOfBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
