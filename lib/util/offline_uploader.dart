import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/main.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
export 'package:flutter_uploader/flutter_uploader.dart' show UploadMethod;

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
    print("upload completed: $result");
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

  static final store = StoreRef<String, String>("queue");

  Future<void> initialize() async {
    await FlutterUploader().setBackgroundHandler(backgroundHandler);
  }

  /// Uploads the JSON object [data] to [url] with http method [method].
  ///
  /// This method creates a temporary file which is deleted when the request is completed.
  Future<void> enqueueJson({
    required UploadMethod method,
    required String url,
    required Map<String, dynamic> data
  }) async {
    // TODO use dio on web.
    final queueDir = await providerContainer
        .read(directoryProvider(kQueueDirectory).future);

    final file = File(join(queueDir!.path, kUuidGen.v1()));
    // Store json content in file.
    await file.writeAsString(jsonEncode(data));
    await enqueueFile(method: method, url: url, filePath: file.path);
  }

  /// Uploads the file with path [filePath] to [url] with http method [method].
  ///
  /// The file at [filePath] will be deleted when the request is completed.
  Future<void> enqueueFile({
    required UploadMethod method,
    required String url,
    required String filePath
  }) async {
    final taskId = await FlutterUploader().enqueue(
      RawUpload(
        url: url,
        path: filePath,
      ),
    );

    final db = await providerContainer.read(forestParkDatabaseProvider.future);
    // Store the taskId and filePath so when the request completes we can
    // look up the filePath we want to delete.
    store.record(taskId).put(db, filePath);
  }
}
