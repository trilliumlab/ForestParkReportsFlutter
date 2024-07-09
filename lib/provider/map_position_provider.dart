

import 'package:flutter_map/flutter_map.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_position_provider.g.dart';

@riverpod
class MapPosition extends _$MapPosition {
  
  @override
  MapCamera? build() => null;
  
  void update(MapCamera camera) {
    state = camera;
  }
}