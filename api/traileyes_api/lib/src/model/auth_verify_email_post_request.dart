//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_verify_email_post_request.g.dart';

/// AuthVerifyEmailPostRequest
///
/// Properties:
/// * [code]
@BuiltValue()
abstract class AuthVerifyEmailPostRequest
    implements
        Built<AuthVerifyEmailPostRequest, AuthVerifyEmailPostRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  AuthVerifyEmailPostRequest._();

  factory AuthVerifyEmailPostRequest(
          [void updates(AuthVerifyEmailPostRequestBuilder b)]) =
      _$AuthVerifyEmailPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyEmailPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyEmailPostRequest> get serializer =>
      _$AuthVerifyEmailPostRequestSerializer();
}

class _$AuthVerifyEmailPostRequestSerializer
    implements PrimitiveSerializer<AuthVerifyEmailPostRequest> {
  @override
  final Iterable<Type> types = const [
    AuthVerifyEmailPostRequest,
    _$AuthVerifyEmailPostRequest
  ];

  @override
  final String wireName = r'AuthVerifyEmailPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyEmailPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthVerifyEmailPostRequest object, {
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
    required AuthVerifyEmailPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthVerifyEmailPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyEmailPostRequestBuilder();
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
