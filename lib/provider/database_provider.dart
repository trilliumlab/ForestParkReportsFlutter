import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sembast_web/sembast_web.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
class ForestParkDatabase extends _$ForestParkDatabase {
  @override
  Future<Database> build() async {
    if (kIsWeb) {
      return databaseFactoryWeb.openDatabase(kDbName);
    } else {
      return await getDatabaseFactorySqflite(sqflite.databaseFactory)
          .openDatabase(await ref.watch(dbPathProvider.future));
    }
  }

  Future<void> delete() async {
    final db = await future;
    state = const AsyncLoading();
    await db.close();
    if (kIsWeb) {
      await databaseFactoryWeb.deleteDatabase(kDbName);
    } else {
      await File(await ref.read(dbPathProvider.future)).delete();
    }
    state = await AsyncValue.guard(build);
  }
}

@Riverpod(keepAlive: true)
Future<String> dbPath(DbPathRef ref) async {
  if (kIsWeb) {
    return "";
  }
  final dir = await ref.watch(appDirectoryProvider.future);
  return join(dir!.path, "$kDbName.db");
}
