//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_get_verification_meta_get200_response_one_of1.g.dart';

/// AuthGetVerificationMetaGet200ResponseOneOf1
///
/// Properties:
/// * [userVerified]
@BuiltValue()
abstract class AuthGetVerificationMetaGet200ResponseOneOf1
    implements
        Built<AuthGetVerificationMetaGet200ResponseOneOf1,
            AuthGetVerificationMetaGet200ResponseOneOf1Builder> {
  @BuiltValueField(wireName: r'userVerified')
  bool get userVerified;

  AuthGetVerificationMetaGet200ResponseOneOf1._();

  factory AuthGetVerificationMetaGet200ResponseOneOf1(
          [void updates(
              AuthGetVerificationMetaGet200ResponseOneOf1Builder b)]) =
      _$AuthGetVerificationMetaGet200ResponseOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthGetVerificationMetaGet200ResponseOneOf1Builder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthGetVerificationMetaGet200ResponseOneOf1>
      get serializer =>
          _$AuthGetVerificationMetaGet200ResponseOneOf1Serializer();
}

class _$AuthGetVerificationMetaGet200ResponseOneOf1Serializer
    implements
        PrimitiveSerializer<AuthGetVerificationMetaGet200ResponseOneOf1> {
  @override
  final Iterable<Type> types = const [
    AuthGetVerificationMetaGet200ResponseOneOf1,
    _$AuthGetVerificationMetaGet200ResponseOneOf1
  ];

  @override
  final String wireName = r'AuthGetVerificationMetaGet200ResponseOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthGetVerificationMetaGet200ResponseOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userVerified';
    yield serializers.serialize(
      object.userVerified,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthGetVerificationMetaGet200ResponseOneOf1 object, {
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
    required AuthGetVerificationMetaGet200ResponseOneOf1Builder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthGetVerificationMetaGet200ResponseOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthGetVerificationMetaGet200ResponseOneOf1Builder();
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
