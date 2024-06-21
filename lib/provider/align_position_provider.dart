import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'align_position_provider.g.dart';

enum AlignPositionTargetState {
  none(AlignOnUpdate.never),
  currentLocation(AlignOnUpdate.always),
  forestPark(AlignOnUpdate.never);

  final AlignOnUpdate update;
  const AlignPositionTargetState(this.update);
}


@riverpod
class AlignPositionTarget extends _$AlignPositionTarget {
  @override
  AlignPositionTargetState build() => AlignPositionTargetState.none;
  void update(AlignPositionTargetState alignPositionTargetState) {
    state = alignPositionTargetState;
  }
}