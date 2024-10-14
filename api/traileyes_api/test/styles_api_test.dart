import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for StylesApi
void main() {
  final instance = Openapi().getStylesApi();

  group(StylesApi, () {
    // Get dark style
    //
    //Future<BuiltMap<String, JsonObject>> stylesDarkJsonGet(String key, { bool mobile }) async
    test('test stylesDarkJsonGet', () async {
      // TODO
    });

    // Get light style
    //
    //Future<BuiltMap<String, JsonObject>> stylesLightJsonGet(String key, { bool mobile }) async
    test('test stylesLightJsonGet', () async {
      // TODO
    });
  });
}
