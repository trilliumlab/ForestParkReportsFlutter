import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hazard_new_response.g.dart';
part 'hazard_new_response.freezed.dart';

@freezed
class HazardNewResponseModel with _$HazardNewResponseModel {
  const HazardNewResponseModel._();
  const factory HazardNewResponseModel({
    required HazardModel hazard,
    required HazardUpdateList updates,
  }) = _HazardNewResponseModel;

  factory HazardNewResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HazardNewResponseModelFromJson(json);
}
