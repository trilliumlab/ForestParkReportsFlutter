import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:blurhash_ffi/blurhash.dart';
import 'package:flutter/cupertino.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:forest_park_reports/util/image_extensions.dart';
import 'package:forest_park_reports/util/offline_uploader.dart';
import 'package:image/image.dart' as img;
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

part 'hazard_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveHazard extends _$ActiveHazard {
  static final store = StoreRef<String, Map<String, dynamic>>("hazards");

  @override
  Future<List<HazardModel>> build() async {
    final db = await ref.watch(forestParkDatabaseProvider.future);

    final hazards = [
      for (final hazard in await store.find(db))
        HazardModel.fromJson(hazard.value)
    ];

    Timer.periodic(
      const Duration(seconds: 10),
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

    final db = await ref.read(forestParkDatabaseProvider.future);
    for (final hazard in hazards) {
      store.record(hazard.uuid).put(db, hazard.toJson());
    }

    return hazards;
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }

  Future<void> create(HazardRequestModel request, {XFile? imageFile}) async {
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

    // Save new hazard - returns the HazardModel created
    OfflineUploader().enqueueJson(
      method: UploadMethod.POST,
      url: "$kApiUrl/hazard/new",
      data: request.toJson()
    );
    // final res = await ref.read(dioProvider).post(
    //     "/hazard/new",
    //     data: request.toJson()
    // );
    // final hazard = HazardModel.fromJson(res.data);
    //
    // // Add new HazardModel to state and db
    // state = AsyncData([
    //   if (state.hasValue)
    //     ...state.requireValue,
    //   hazard
    // ]);
    // final db = await ref.read(forestParkDatabaseProvider.future);
    // store.record(hazard.uuid).put(db, hazard.toJson());

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final queueDir = await ref.read(directoryProvider(kQueueDirectory).future);
    final imagePath = join(queueDir!.path, request.image!);
    await image.compressToFile(filePath: imagePath);

    // Queue upload
    await OfflineUploader().enqueueFile(
      method: UploadMethod.PUT,
      url: "$kApiUrl/hazard/image/${request.image!}",
      filePath: imagePath
    );
  }

  Future<bool> _uploadImage(Uint8List image, String uuid, {void Function(int, int)? onSendProgress}) async {
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(image),
    });
    final res = await ref.read(dioProvider).put(
        "/hazard/image/$uuid",
        data: formData,
        options: Options(
          headers: {
            'Accept-Ranged': 'bytes'
          },
        ),
        onSendProgress: onSendProgress
    );
    return res.statusCode == 200;
  }
}

class HazardUpdateList extends ListBase<HazardUpdateModel> {
  final List<HazardUpdateModel> l;

  HazardUpdateList(this.l);

  @override
  set length(int newLength) { l.length = newLength; }
  @override
  int get length => l.length;
  @override
  HazardUpdateModel operator [](int index) => l[index];
  @override
  void operator []=(int index, HazardUpdateModel value) { l[index] = value; }

  String? get lastImage => lastWhereOrNull((e) => e.image != null)?.image;
  String? get lastBlurHash => lastWhereOrNull((e) => e.blurHash != null)?.blurHash;
}

@Riverpod(keepAlive: true)
class HazardUpdates extends _$HazardUpdates {
  @override
  HazardUpdateList build(String hazard) {
    refresh();
    return HazardUpdateList([]);
  }
  Future refresh() async {
    final res = await ref.read(dioProvider).get("/hazard/$hazard");
    final updates = HazardUpdateList([
      for (final val in res.data)
        HazardUpdateModel.fromJson(val)
    ]);
    updates.sort((a, b) => a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch);
    state = updates;
  }

  Future create(HazardUpdateRequestModel request) async {
    final res = await ref.read(dioProvider).post("/hazard/update", data: request.toJson());
    state = HazardUpdateList([...state, HazardUpdateModel.fromJson(res.data)]);
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
