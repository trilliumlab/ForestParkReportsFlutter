import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_cursor_provider.g.dart';

@riverpod
class MapCursor extends _$MapCursor {
  @override
  LatLng? build() {
    ref.listen(selectedRelationProvider, (_, next) {
      if (next == null) {
        clear();
      }
    });
    return null;
  }

  void set(LatLng? position) =>
    state = position;

  void clear() =>
    state = null;
}
