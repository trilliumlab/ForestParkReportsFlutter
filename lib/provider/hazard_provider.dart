import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/main.dart';
import 'package:forest_park_reports/model/hazard_new_response.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/model/queued_request.dart';
import 'package:forest_park_reports/model/snapped_latlng.dart';
import 'package:forest_park_reports/page/common/alert_banner.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:forest_park_reports/util/image_extensions.dart';
import 'package:forest_park_reports/util/offline_uploader.dart';
import 'package:image/image.dart' as img;
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hazard_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveHazard extends _$ActiveHazard {
  @override
  Future<List<HazardModel>> build() async {
    final db = ref.watch(databaseProvider);
    
    final hazards = await db.select(db.hazardsTable).get();

    Timer.periodic(
      kHazardRefreshPeriod,
      (_) => refresh(),
    );

    if (hazards.isNotEmpty) {
      refresh();
      return hazards;
    }
    return await _fetch();
  }

  Future<List<HazardModel>> _fetch() async {
    final res = await ref.read(dioProvider).get("/hazard/active");

    final hazards = [
      for (final hazard in res.data)
        HazardModel.fromJson(hazard)
    ];

    final db = ref.read(databaseProvider);
    await (db.delete(db.hazardsTable)..where((t) => t.offline.equals(false))).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.hazardsTable, hazards);
    });

    return hazards;
  }

  Future<void> refresh() async {
    final newHazards = await _fetch();
    final newUuids = newHazards.map((h) => h.uuid);
    state = AsyncData([
      if (state.hasValue)
        for (final hazard in state.value!)
          if (hazard.offline && !newUuids.contains(hazard.uuid))
            hazard,
      ...newHazards,
    ]);
  }

  Future<void> createHazard({
    required String uuid,
    required HazardType hazard,
    required SnappedLatLng location,
    XFile? imageFile
  }) async {
    // If we're passed an image, decode it.
    img.Image? image;
    if (imageFile != null) {
      final cmd = img.Command()
        ..decodeNamedImage(imageFile.path, await imageFile.readAsBytes());
      image = await cmd.getImageThread();
    }

    final hazardRequest = HazardModel.create(
      uuid: uuid,
      hazard: hazard,
      location: location,
      image: image != null ? kUuidGen.v1() : null,
      blurHash: image != null ? await image.getBlurHash() : null,
    );

    // Add offline hazard to app
    _addHazard(hazardRequest);

    // Queue new hazard request.
    OfflineUploader().enqueueJson(
      method: UploadMethod.POST,
      requestType: QueuedRequestType.newHazard,
      associatedUuid: hazardRequest.uuid,
      url: "$kApiUrl/hazard/new",
      data: hazardRequest.toJson(),
    );

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final imageDir = (await ref.read(directoryProvider(kImageDirectory).future))!;
    final imagePath = join(imageDir.path, "${hazardRequest.image!}.jpeg");
    await image.compressToFile(filePath: imagePath);

    // Queue image upload
    await OfflineUploader().enqueueFile(
      method: UploadMethod.PUT,
      requestType: QueuedRequestType.imageUpload,
      associatedUuid: hazardRequest.uuid,
      url: "$kApiUrl/hazard/image/${hazardRequest.image!}",
      multipart: true,
      filePath: imagePath,
    );
  }

  Future<void> handleCreateResponse(HazardNewResponseModel response) async {
    // Show success notification
    showAlertBanner(
      key: Key(response.hazard.uuid),
      child: const Text("Report uploaded successfully"),
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeGreen, homeKey.currentContext!),
    );

    _addHazard(response.hazard);

    // Add new update to hazard updates
    final updatesNotifier = ref.read(hazardUpdatesProvider(response.hazard.uuid).notifier);
    for (final update in response.updates) {
      await updatesNotifier.addHazardUpdate(update);
    }
  }

  Future<void> _addHazard(HazardModel hazard) async {
    // Add new HazardModel to state and db
    state = AsyncData([
      if (state.hasValue)
        ...state.requireValue,
      hazard
    ]);
    final db = ref.read(databaseProvider);
    await db.into(db.hazardsTable).insertOnConflictUpdate(hazard);
  }

  Future updateHazard({
    required String hazard,
    required bool active,
    XFile? imageFile
  }) async {
    // If we're passed an image, decode it.
    img.Image? image;
    if (imageFile != null) {
      final cmd = img.Command()
        ..decodeNamedImage(imageFile.path, await imageFile.readAsBytes());
      image = await cmd.getImageThread();
    }

    final hazardUpdateRequest = HazardUpdateModel.create(
      hazard: hazard,
      active: active,
      image: image != null ? kUuidGen.v1() : null,
      blurHash: image != null ? await image.getBlurHash() : null,
    );

    // Queue new hazard update request.
    OfflineUploader().enqueueJson(
      method: UploadMethod.POST,
      requestType: QueuedRequestType.updateHazard,
      associatedUuid: hazardUpdateRequest.uuid,
      url: "$kApiUrl/hazard/update",
      data: hazardUpdateRequest.toJson(),
    );

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final imageDir = (await ref.read(directoryProvider(kImageDirectory).future))!;
    final imagePath = join(imageDir.path, "${hazardUpdateRequest.image!}.jpeg");
    await image.compressToFile(filePath: imagePath);

    // Queue image upload
    await OfflineUploader().enqueueFile(
      method: UploadMethod.PUT,
      requestType: QueuedRequestType.imageUpload,
      associatedUuid: hazardUpdateRequest.uuid,
      url: "$kApiUrl/hazard/image/${hazardUpdateRequest.image!}",
      multipart: true,
      filePath: imagePath,
    );
  }

  Future<void> handleUpdateResponse(HazardUpdateModel hazardUpdate) async {
    print("Handling hazard update create response: $hazardUpdate");

    // Add new update to hazard updates
    await ref.read(hazardUpdatesProvider(hazardUpdate.hazard).notifier)
        .addHazardUpdate(hazardUpdate);
  }
}

@Riverpod(keepAlive: true)
class HazardUpdates extends _$HazardUpdates {
  @override
  Future<HazardUpdateList> build(String hazard) async {
    final db = ref.watch(databaseProvider);
    final hazardUpdates = HazardUpdateList(await db.select(db.hazardUpdatesTable).get());
    if (hazardUpdates.isNotEmpty) {
      refresh();
      return hazardUpdates;
    }
    return await _fetch();
  }

  Future<HazardUpdateList> _fetch() async {
    final res = await ref.read(dioProvider).get("/hazard/$hazard");
    final updates = HazardUpdateList.fromJson(res.data);
    updates.sort((a, b) => a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch);

    final db = ref.read(databaseProvider);
    await db.delete(db.hazardUpdatesTable).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.hazardUpdatesTable, updates);
    });

    return updates;
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }

  Future<void> addHazardUpdate(HazardUpdateModel hazardUpdate) async {
    // Add HazardUpdateModel to state and db
    state = AsyncData(HazardUpdateList([
      if (state.hasValue)
        ...state.requireValue,
      hazardUpdate
    ]));
    final db = ref.read(databaseProvider);
    await db.into(db.hazardUpdatesTable).insertOnConflictUpdate(hazardUpdate);
  }
}

class SelectedHazardState {
  final bool moveCamera;
  final HazardModel? hazard;
  SelectedHazardState(this.moveCamera, [this.hazard]);
}

@Riverpod(keepAlive: true)
class SelectedHazard extends _$SelectedHazard {
  @override
  SelectedHazardState build() => SelectedHazardState(false);

  void selectAndMove(HazardModel hazard) {
    state = SelectedHazardState(true, hazard);
  }
  void select(HazardModel hazard) {
    state = SelectedHazardState(false, hazard);
  }
  void deselect() {
    state = SelectedHazardState(false);
  }
}
