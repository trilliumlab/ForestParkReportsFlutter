import 'package:drift/drift.dart';
import 'package:forest_park_reports/database/connection/connection.dart';
import 'package:forest_park_reports/database/json_object_converter.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:forest_park_reports/model/queued_request.dart';
import 'package:forest_park_reports/model/relation.dart';
import 'package:forest_park_reports/model/trail.dart';

part 'database.g.dart';

@UseRowClass(TrailModel, constructor: 'fromDb')
class TrailsTable extends Table {
  IntColumn get id => integer()();
  BlobColumn get data => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(HazardModel, constructor: 'fromDb')
class HazardsTable extends Table {
  TextColumn get uuid => text()();
  DateTimeColumn get time => dateTime()();
  TextColumn get hazard => textEnum<HazardType>()();
  IntColumn get trail => integer()();
  IntColumn get node => integer()();
  RealColumn get lat => real()();
  RealColumn get long => real()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@UseRowClass(HazardUpdateModel)
class HazardUpdatesTable extends Table {
  TextColumn get uuid => text()();
  TextColumn get hazard => text().unique().references(HazardsTable, #uuid)();
  DateTimeColumn get time => dateTime()();
  BoolColumn get active => boolean()();
  TextColumn get blurHash => text().nullable()();
  TextColumn get image => text().nullable().unique()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@UseRowClass(RelationModel)
class RelationsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get tags => text().map(const JsonMapConverter<String>())();
  TextColumn get members => text().map(const JsonListConverter<int>())();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(QueuedRequestModel)
class QueueTable extends Table {
  TextColumn get taskId => text()();
  TextColumn get requestType => textEnum<QueuedRequestType>()();
  TextColumn get filePath => text()();

  @override
  Set<Column> get primaryKey => {taskId};
}

@DriftDatabase(
  tables: [
    TrailsTable,
    HazardsTable,
    HazardUpdatesTable,
    RelationsTable,
    QueueTable,
  ]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabase());

  @override
  int get schemaVersion => 1;
}
