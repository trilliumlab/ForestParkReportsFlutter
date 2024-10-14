import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for GeojsonApi
void main() {
  final instance = Openapi().getGeojsonApi();

  group(GeojsonApi, () {
    // Get all routes as GeoJSON
    //
    //Future<BuiltMap<String, JsonObject>> geojsonRoutesJsonGet() async
    test('test geojsonRoutesJsonGet', () async {
      // TODO
    });

    // Get start markers as GeoJSON
    //
    //Future<BuiltMap<String, JsonObject>> geojsonStartMarkersJsonGet() async
    test('test geojsonStartMarkersJsonGet', () async {
      // TODO
    });
  });
}
