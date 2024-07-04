import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/database/database.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
class ForestParkDatabase extends _$ForestParkDatabase {
  @override
  AppDatabase build() => AppDatabase();

  Future<void> delete() async {
    // TODO Reimplement
  }
}

@Riverpod(keepAlive: true)
Future<File?> dbFile(DbPathRef ref) async {
  if (kIsWeb) {
    return null;
  }
  final dir = await ref.watch(appDirectoryProvider.future);
  return File(join(dir!.path, "$kDbName.db"));
}
