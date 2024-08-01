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
    required bool offline,
    String? blurHash,
    String? image,
  }) = _HazardModel;

  factory HazardModel.create({
    required HazardType hazard,
    required SnappedLatLng location,
    String? uuid,
    String? blurHash,
    String? image,
  }) => HazardModel(
    uuid: uuid ?? kUuidGen.v1(),
    time: DateTime.now(),
    hazard: hazard,
    location: location,
    offline: true,
    blurHash: blurHash,
    image: image,
  );

  /// Maps a database [HazardsTable] row to a [HazardModel].
  factory HazardModel.fromDb({
    required String uuid,
    required DateTime time,
    required HazardType hazard,
    required int trail,
    required int node,
    required double lat,
    required double long,
    required bool offline,
    String? blurHash,
    String? image,
  }) => HazardModel(
    uuid: uuid,
    time: time,
    hazard: hazard,
    location: SnappedLatLng(trail, node, LatLng(lat, long)),
    offline: offline,
    blurHash: blurHash,
    image: image,
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
        offline: drift.Value(offline),
        blurHash: drift.Value(blurHash),
        image: drift.Value(image),
      ).toColumns(nullToAbsent);

  factory HazardModel.fromJson(Map<String, dynamic> json) =>
      _$HazardModelFromJson(json);

  String timeString() => kDisplayDateFormat.format(time.toLocal());
}
