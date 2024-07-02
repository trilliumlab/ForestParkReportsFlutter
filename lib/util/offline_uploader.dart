import 'package:flutter/cupertino.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/main.dart';
import 'package:forest_park_reports/provider/app_directory_provider.dart';
import 'package:forest_park_reports/provider/database_provider.dart';

/// Handler for background network requests using flutter_uploader
void backgroundHandler() {
  // Needed so that plugin communication works.
  WidgetsFlutterBinding.ensureInitialized();

  // This uploader instance works within the isolate only.
  FlutterUploader uploader = FlutterUploader();

  uploader.progress.listen((progress) {
    // upload progress
  });
  uploader.result.listen((result) {
    // upload results
  });
}

/// A utility class that manages background POST requests.
class OfflineUploader {
  static final OfflineUploader _instance = OfflineUploader._();
  OfflineUploader._();
  /// Constructs a new [OfflineUploader]
  ///
  /// [OfflineUploader] is a singleton (will always return the same instance)
  factory OfflineUploader() => _instance;

  Future<void> initialize() async {
    await FlutterUploader().setBackgroundHandler(backgroundHandler);
  }

  Future<void> post() async {
    final queueDir = await providerContainer
        .read(appDirectoryProvider(kQueueDirectory).future);
    final db = await providerContainer.read(forestParkDatabaseProvider.future);
  }
}
