import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'relation.g.dart';
part 'relation.freezed.dart';

extension RelationList on List<RelationModel> {
  RelationModel? get(int id) {
    return firstWhereOrNull((relation) => relation.id == id);
  }
  RelationModel? forTrail(int id) {
    return firstWhereOrNull((relation) => relation.members.contains(id));
  }
}

@freezed
class RelationModel with _$RelationModel implements drift.Insertable<RelationModel> {
  const RelationModel._();
  const factory RelationModel({
    required int id,
    required Map<String, String> tags,
    required List<int> members
  }) = _RelationModel;

  /// Maps a [RelationModel] to a database [RelationsTable] row.
  @override
  Map<String, drift.Expression<Object>> toColumns(bool nullToAbsent) =>
      RelationsTableCompanion(
        id: drift.Value(id),
        tags: drift.Value(tags),
        members: drift.Value(members),
      ).toColumns(nullToAbsent);

  factory RelationModel.fromJson(Map<String, dynamic> json) =>
      _$RelationModelFromJson(json);
}
