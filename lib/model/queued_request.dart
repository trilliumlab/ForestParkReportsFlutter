import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'queued_request.g.dart';
part 'queued_request.freezed.dart';

@freezed
class QueuedRequestModel with _$QueuedRequestModel {
  const QueuedRequestModel._();
  const factory QueuedRequestModel({
    required QueuedRequestType requestType,
    required String filePath,
  }) = _QueuedRequestModel;

  factory QueuedRequestModel.fromJson(Map<String, dynamic> json) =>
      _$QueuedRequestModelFromJson(json);
}

enum QueuedRequestType {
  newHazard,
  imageUpload,
  updateHazard;
}
