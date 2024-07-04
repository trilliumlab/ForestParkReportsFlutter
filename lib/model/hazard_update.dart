import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hazard_update.g.dart';
part 'hazard_update.freezed.dart';

@freezed
class HazardUpdateModel with _$HazardUpdateModel implements drift.Insertable<HazardUpdateModel> {
  const HazardUpdateModel._();
  const factory HazardUpdateModel({
    required String uuid,
    required String hazard,
    required DateTime time,
    required bool active,
    String? blurHash,
    String? image,
  }) = _HazardUpdateModel;

  /// Maps a [HazardUpdateModel] to a database [HazardUpdatesTable] row.
  @override
  Map<String, drift.Expression<Object>> toColumns(bool nullToAbsent) =>
      HazardUpdatesTableCompanion(
        uuid: drift.Value(uuid),
        hazard: drift.Value(hazard),
        time: drift.Value(time),
        active: drift.Value(active),
        blurHash: drift.Value(blurHash),
        image: drift.Value(image),
      ).toColumns(nullToAbsent);

  factory HazardUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$HazardUpdateModelFromJson(json);

  String timeString() => kDisplayDateFormat.format(time.toLocal());
}

@freezed
class HazardUpdateRequestModel with _$HazardUpdateRequestModel {
  const HazardUpdateRequestModel._();
  const factory HazardUpdateRequestModel({
    required String hazard,
    required bool active,
    String? blurHash,
    String? image,
  }) = _HazardUpdateRequestModel;

  factory HazardUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HazardUpdateRequestModelFromJson(json);
}