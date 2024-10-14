//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_session_meta_get200_response.g.dart';

/// AuthSessionMetaGet200Response
///
/// Properties:
/// * [userVerified]
/// * [sessionConfirmed]
@BuiltValue()
abstract class AuthSessionMetaGet200Response
    implements
        Built<AuthSessionMetaGet200Response,
            AuthSessionMetaGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'userVerified')
  bool get userVerified;

  @BuiltValueField(wireName: r'sessionConfirmed')
  bool get sessionConfirmed;

  AuthSessionMetaGet200Response._();

  factory AuthSessionMetaGet200Response(
          [void updates(AuthSessionMetaGet200ResponseBuilder b)]) =
      _$AuthSessionMetaGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthSessionMetaGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthSessionMetaGet200Response> get serializer =>
      _$AuthSessionMetaGet200ResponseSerializer();
}

class _$AuthSessionMetaGet200ResponseSerializer
    implements PrimitiveSerializer<AuthSessionMetaGet200Response> {
  @override
  final Iterable<Type> types = const [
    AuthSessionMetaGet200Response,
    _$AuthSessionMetaGet200Response
  ];

  @override
  final String wireName = r'AuthSessionMetaGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthSessionMetaGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userVerified';
    yield serializers.serialize(
      object.userVerified,
      specifiedType: const FullType(bool),
    );
    yield r'sessionConfirmed';
    yield serializers.serialize(
      object.sessionConfirmed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthSessionMetaGet200Response object, {
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
    required AuthSessionMetaGet200ResponseBuilder result,
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
        case r'sessionConfirmed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sessionConfirmed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthSessionMetaGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthSessionMetaGet200ResponseBuilder();
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
