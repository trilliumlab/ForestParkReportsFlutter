import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for SpritesApi
void main() {
  final instance = Openapi().getSpritesApi();

  group(SpritesApi, () {
    // Get a sprite
    //
    //Future<BuiltMap<String, SpritesPathJsonGet200ResponseValue>> spritesPathJsonGet(String path) async
    test('test spritesPathJsonGet', () async {
      // TODO
    });

    // Get a sprite
    //
    //Future<JsonObject> spritesPathPngGet(String path) async
    test('test spritesPathPngGet', () async {
      // TODO
    });
  });
}
