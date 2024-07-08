import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'directory_provider.g.dart';

/// Provides the directory [directory] in the application support directory folder.
/// Ensures the folder has been created.
@Riverpod(keepAlive: true)
Future<Directory?> directory(DirectoryRef ref, String subdir) async {
  if (kIsWeb) {
    return null;
  }
  final appDir = await ref.watch(appDirectoryProvider.future);
  final subDir = Directory(join(appDir!.path, subdir));
  await subDir.create(recursive: true);
  return subDir;
}

@Riverpod(keepAlive: true)
Future<Directory?> appDirectory(AppDirectoryRef ref) async {
  if (kIsWeb) {
    return null;
  }
  final dir = kDebugMode
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return dir;
}
