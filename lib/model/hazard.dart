import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/database/database.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/model/snapped_latlng.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'hazard.g.dart';
part 'hazard.freezed.dart';

@freezed
class HazardModel with _$HazardModel implements drift.Insertable<HazardModel> {
  const HazardModel._();
  const factory HazardModel({
    required String uuid,
    required DateTime time,
    required HazardType hazard,
    required SnappedLatLng location,
    // TODO these probably can be removed.
    String? blurHash,
    String? image,
  }) = _HazardModel;

  /// Maps a database [HazardsTable] row to a [HazardModel].
  factory HazardModel.fromDb({
    required String uuid,
    required DateTime time,
    required HazardType hazard,
    required int trail,
    required int node,
    required double lat,
    required double long,
  }) => HazardModel(
    uuid: uuid,
    time: time,
    hazard: hazard,
    location: SnappedLatLng(trail, node, LatLng(lat, long)),
  );

  /// Maps a [HazardModel] to a database [HazardsTable] row.
  @override
  Map<String, drift.Expression<Object>> toColumns(bool nullToAbsent) =>
      HazardsTableCompanion(
        uuid: drift.Value(uuid),
        time: drift.Value(time),
        hazard: drift.Value(hazard),
        trail: drift.Value(location.trail),
        node: drift.Value(location.node),
        lat: drift.Value(location.latitude),
        long: drift.Value(location.longitude),
      ).toColumns(nullToAbsent);

  factory HazardModel.fromJson(Map<String, dynamic> json) =>
      _$HazardModelFromJson(json);

  String timeString() => kDisplayDateFormat.format(time.toLocal());
}

@freezed
class HazardRequestModel with _$HazardRequestModel {
  const HazardRequestModel._();
  const factory HazardRequestModel({
    required HazardType hazard,
    required SnappedLatLng location,
    String? blurHash,
    String? image,
  }) = _HazardRequestModel;

  factory HazardRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HazardRequestModelFromJson(json);
}
