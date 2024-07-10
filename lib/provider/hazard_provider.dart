import 'dart:async';

import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/queued_request.dart';
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
    await db.delete(db.hazardsTable).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.hazardsTable, hazards);
    });

    return hazards;
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }

  Future<void> createHazard(HazardRequestModel request, {XFile? imageFile}) async {
    img.Image? image;

    // If we're passed an image, decode it.
    if (imageFile != null) {
      final cmd = img.Command()
        ..decodeNamedImage(imageFile.path, await imageFile.readAsBytes());
      image = await cmd.getImageThread();
    }

    // If decoding successful, generate blurHash and add to hazard request.
    if (image != null) {
      request = request.copyWith(
          image: kUuidGen.v1(),
          blurHash: await image.getBlurHash(),
      );
    }

    // Queue new hazard request.
    OfflineUploader().enqueueJson(
      method: UploadMethod.POST,
      requestType: QueuedRequestType.newHazard,
      url: "$kApiUrl/hazard/new",
      data: request.toJson(),
    );

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final queueDir = await ref.read(directoryProvider(kQueueDirectory).future);
    final imagePath = join(queueDir!.path, "${request.image!}.jpeg");
    await image.compressToFile(filePath: imagePath);

    // Queue image upload
    await OfflineUploader().enqueueFile(
      method: UploadMethod.PUT,
      requestType: QueuedRequestType.imageUpload,
      url: "$kApiUrl/hazard/image/${request.image!}",
      multipart: true,
      filePath: imagePath,
    );
  }

  Future<void> handleCreateResponse(HazardModel hazard) async {
    print("Handling hazard create response: $hazard");

    // Add new HazardModel to state and db
    state = AsyncData([
      if (state.hasValue)
        ...state.requireValue,
      hazard
    ]);
    final db = ref.read(databaseProvider);
    await db.into(db.hazardsTable).insertOnConflictUpdate(hazard);
  }

  Future updateHazard(HazardUpdateRequestModel request, {XFile? imageFile}) async {
    img.Image? image;

    // If we're passed an image, decode it.
    if (imageFile != null) {
      final cmd = img.Command()
        ..decodeNamedImage(imageFile.path, await imageFile.readAsBytes());
      image = await cmd.getImageThread();
    }

    // If decoding successful, generate blurHash and add to hazard update request.
    if (image != null) {
      request = request.copyWith(
        image: kUuidGen.v1(),
        blurHash: await image.getBlurHash(),
      );
    }

    // Queue new hazard update request.
    OfflineUploader().enqueueJson(
      method: UploadMethod.POST,
      requestType: QueuedRequestType.updateHazard,
      url: "$kApiUrl/hazard/update",
      data: request.toJson(),
    );

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final queueDir = await ref.read(directoryProvider(kQueueDirectory).future);
    final imagePath = join(queueDir!.path, "${request.image!}.jpeg");
    await image.compressToFile(filePath: imagePath);

    // Queue image upload
    await OfflineUploader().enqueueFile(
      method: UploadMethod.PUT,
      requestType: QueuedRequestType.imageUpload,
      url: "$kApiUrl/hazard/image/${request.image!}",
      multipart: true,
      filePath: imagePath,
    );
  }

  Future<void> handleUpdateResponse(HazardUpdateModel hazardUpdate) async {
    print("Handling hazard update create response: $hazardUpdate");

    // Add new hazard to hazard updates
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
    final updates = HazardUpdateList([
      for (final val in res.data)
        HazardUpdateModel.fromJson(val)
    ]);
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
