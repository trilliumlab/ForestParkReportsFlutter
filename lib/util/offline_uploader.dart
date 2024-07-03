import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/main.dart';
import 'package:forest_park_reports/model/queued_request.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
export 'package:flutter_uploader/flutter_uploader.dart' show UploadMethod;

/// Handler for background network requests using flutter_uploader
void backgroundRequestsHandler() {
  // Needed so that plugin communication works.
  WidgetsFlutterBinding.ensureInitialized();

  // This uploader instance works within the isolate only.
  FlutterUploader uploader = FlutterUploader();

  // Called whenever upload progress changes.
  uploader.progress.listen((progress) async {
  });
  // Called when upload completes.
  uploader.result.listen((response) async {
    print("upload completed: $response");
    final db = await providerContainer.read(forestParkDatabaseProvider.future);
    if (response.statusCode != null) {
      final queuedRequestJson = await OfflineUploader.store.record(response.taskId).get(db);
      if (queuedRequestJson != null) {
        final queuedRequest = QueuedRequestModel.fromJson(queuedRequestJson);
        print("found associated queued request: $queuedRequest");

        // Delete request file.
        final file = File(queuedRequest.filePath);
        try {
          await file.delete();
        } catch(e) {}

        // Construct response
        final queuedRequestResponseJson = QueuedRequestResponseModel(
          requestType: queuedRequest.requestType,
          response: response.response,
        ).toJson();

        // Send response to main isolate to handle
        final sendPort = IsolateNameServer.lookupPortByName(kBackgroundRequestPortName);
        if (sendPort != null) {
          // If the app is open, then we should handle response in main isolate.
          sendPort.send(queuedRequestResponseJson);
        } else {
          // Otherwise, we don't need the ui to update so we can handle it in current isolate.
          OfflineUploader().handleQueuedRequestResponse(queuedRequestResponseJson);
        }

        // Clear uploads once we've processed them
        uploader.clearUploads();
      }
    }
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

  static final store = StoreRef<String, Map<String, dynamic>>("queue");

  ReceivePort receivePort = ReceivePort(kBackgroundRequestPortName);

  Future<void> initialize() async {
    // Register receive port globally
    IsolateNameServer.registerPortWithName(receivePort.sendPort, kBackgroundRequestPortName);
    receivePort.listen(handleQueuedRequestResponse);
    // Set function that receives background request responses
    await FlutterUploader().setBackgroundHandler(backgroundRequestsHandler);

    print("flutter uploader initialized");
  }

  /// **Function for internal use only**
  ///
  /// Handles background responses sent to [receivePort] from background isolate.
  /// Should never be called manually except by background isolate if
  /// there is no main isolate.
  Future<void> handleQueuedRequestResponse(dynamic queuedRequestResponseJson) async {
    final queuedRequestResponse = QueuedRequestResponseModel.fromJson(queuedRequestResponseJson);
    print("Received queuedRequestResponse in main isolate: $queuedRequestResponse");

    switch(queuedRequestResponse.requestType) {
      case QueuedRequestType.newHazard:
        providerContainer.read(activeHazardProvider.notifier)
            .handleCreateResponse(queuedRequestResponse.response);
        break;
      case QueuedRequestType.imageUpload:
      // TODO: not handled
        break;
      case QueuedRequestType.updateHazard:
      // TODO: not handled
        break;
    }
  }

  /// Uploads the JSON object [data] to [url] with http method [method].
  ///
  /// This method creates a temporary file which is deleted when the request is completed.
  Future<void> enqueueJson({
    required UploadMethod method,
    required String url,
    required Map<String, dynamic> data,
    required QueuedRequestType requestType,
    Map<String, String>? headers,
  }) async {
    // TODO use dio on web.
    final queueDir = await providerContainer
        .read(directoryProvider(kQueueDirectory).future);

    final file = File(join(queueDir!.path, "${kUuidGen.v1()}.json"));
    // Store json content in file.
    await file.writeAsString(jsonEncode(data));

    // Add content-type header
    final headerMap = headers ?? {};
    headerMap["Content-Type"] = "application/json";

    await enqueueFile(
      method: method,
      url: url,
      filePath: file.path,
      requestType: requestType,
      headers: headerMap,
    );
  }

  /// Uploads the file with path [filePath] to [url] with http method [method].
  ///
  /// The file at [filePath] will be deleted when the request is completed.
  Future<void> enqueueFile({
    required UploadMethod method,
    required String url,
    required String filePath,
    required QueuedRequestType requestType,
    bool multipart = false,
    Map<String, String>? headers,
  }) async {
    print("enqueuing file at path $filePath");

    final taskId = await FlutterUploader().enqueue(
      multipart ? MultipartFormDataUpload(
        method: method,
        url: url,
        headers: headers,
        files: [
          FileItem(path: filePath)
        ],
      ) : RawUpload(
        method: method,
        url: url,
        headers: headers,
        path: filePath,
      ),
    );

    print("Started task with id: $taskId");

    final db = await providerContainer.read(forestParkDatabaseProvider.future);
    // Store the QueuedRequestModel so when the request completes we can
    // delete the file and handle the returned data.
    store.record(taskId).put(db, QueuedRequestModel(
      requestType: requestType,
      filePath: filePath
    ).toJson());
  }
}
