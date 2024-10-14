import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for AuthApi
void main() {
  final instance = Openapi().getAuthApi();

  group(AuthApi, () {
    // Get enabled second factors
    //
    //Future<BuiltList<String>> authEnabledSecondFactorsGet() async
    test('test authEnabledSecondFactorsGet', () async {
      // TODO
    });

    // Get verification metadata
    //
    //Future<AuthGetVerificationMetaGet200Response> authGetVerificationMetaGet() async
    test('test authGetVerificationMetaGet', () async {
      // TODO
    });

    // Login a user
    //
    //Future<AuthLoginPost200Response> authLoginPost({ AuthLoginPostRequest authLoginPostRequest }) async
    test('test authLoginPost', () async {
      // TODO
    });

    // Register a new user
    //
    //Future authRegisterPost({ AuthRegisterPostRequest authRegisterPostRequest }) async
    test('test authRegisterPost', () async {
      // TODO
    });

    // Send verification email
    //
    // Sends a verification email to the user's email address. If a code has been sent in the last 90 seconds, no action is taken.
    //
    //Future<AuthGetVerificationMetaGet200Response> authSendVerificationPost() async
    test('test authSendVerificationPost', () async {
      // TODO
    });

    // Get session metadata
    //
    //Future<AuthSessionMetaGet200Response> authSessionMetaGet() async
    test('test authSessionMetaGet', () async {
      // TODO
    });

    // Verify email
    //
    //Future authVerifyEmailPost({ AuthVerifyEmailPostRequest authVerifyEmailPostRequest }) async
    test('test authVerifyEmailPost', () async {
      // TODO
    });
  });
}
