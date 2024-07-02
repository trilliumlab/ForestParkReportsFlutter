import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_directory_provider.g.dart';

/// Provides the directory [directory] in the application support directory folder.
/// Ensures the folder has been created.
@Riverpod(keepAlive: true)
Future<Directory?> appDirectory(AppDirectoryRef ref, String directory) async {
  if (kIsWeb) {
    return null;
  }
  final appDir = await getApplicationSupportDirectory();
  final subDir = Directory(join(appDir.path, directory));
  await subDir.create(recursive: true);
  return subDir;
}
