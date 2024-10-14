//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login_post_request.g.dart';

/// AuthLoginPostRequest
///
/// Properties:
/// * [email]
/// * [password]
@BuiltValue()
abstract class AuthLoginPostRequest
    implements Built<AuthLoginPostRequest, AuthLoginPostRequestBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'password')
  String get password;

  AuthLoginPostRequest._();

  factory AuthLoginPostRequest([void updates(AuthLoginPostRequestBuilder b)]) =
      _$AuthLoginPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLoginPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLoginPostRequest> get serializer =>
      _$AuthLoginPostRequestSerializer();
}

class _$AuthLoginPostRequestSerializer
    implements PrimitiveSerializer<AuthLoginPostRequest> {
  @override
  final Iterable<Type> types = const [
    AuthLoginPostRequest,
    _$AuthLoginPostRequest
  ];

  @override
  final String wireName = r'AuthLoginPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLoginPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLoginPostRequest object, {
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
    required AuthLoginPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthLoginPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLoginPostRequestBuilder();
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
