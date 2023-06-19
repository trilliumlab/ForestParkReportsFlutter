import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hazard_provider.g.dart';

@riverpod
class ActiveHazard extends _$ActiveHazard {
  @override
  List<Hazard> build() {
    refresh();
    Timer.periodic(
      const Duration(seconds: 10),
          (_) => refresh(),
    );
    return [];
  }
  Future refresh() async {
    final res = await ref.read(dioProvider).get("/hazard/active");
    state = [
      for (final val in res.data)
        Hazard.fromJson(val)
    ];
  }
  Future<String?> uploadImage(XFile file, {void Function(int, int)? onSendProgress}) async {
    final image = await FlutterImageCompress.compressWithFile(
        file.path,
        keepExif: true,
        quality: 80
    );
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(image!),
    });
    final res = await ref.read(dioProvider).post(
        "/hazard/image",
        data: formData,
        options: Options(
          headers: {
            'Accept-Ranged': 'bytes'
          },
        ),
        onSendProgress: onSendProgress
    );
    return res.data['uuid'];
  }
  Future create(NewHazardRequest request) async {
    final res = await ref.read(dioProvider).post("/hazard/new", data: request.toJson());
    state = [...state, Hazard.fromJson(res.data)];
  }
}

class HazardUpdateList extends ListBase<HazardUpdate> {
  final List<HazardUpdate> l;

  HazardUpdateList(this.l);

  @override
  set length(int newLength) { l.length = newLength; }
  @override
  int get length => l.length;
  @override
  HazardUpdate operator [](int index) => l[index];
  @override
  void operator []=(int index, HazardUpdate value) { l[index] = value; }

  String? get lastImage => lastWhereOrNull((e) => e.image != null)?.image;
}

@riverpod
class HazardUpdates extends _$HazardUpdates {
  late final String hazard;
  @override
  HazardUpdateList build(String hazard) {
    this.hazard = hazard;
    refresh();
    return HazardUpdateList([]);
  }
  Future refresh() async {
    final res = await ref.read(dioProvider).get("/hazard/$hazard");
    final updates = HazardUpdateList([
      for (final val in res.data)
        HazardUpdate.fromJson(val)
    ]);
    updates.sort((a, b) => a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch);
    state = updates;
  }

  Future create(UpdateHazardRequest request) async {
    final res = await ref.read(dioProvider).post("/hazard/update", data: request.toJson());
    state = HazardUpdateList([...state, HazardUpdate.fromJson(res.data)]);
  }
}

class HazardPhotoProgress {
  int transmitted;
  int total;
  HazardPhotoProgress(this.transmitted, this.total);
  bool get isComplete => transmitted == total;
  double get progress {
    final p = transmitted/total;
    return p.isNaN ? 0.0 : p.clamp(0, 1);
  }
}

final hazardPhotoProgressProvider = StateProvider.family<HazardPhotoProgress, String>(
        (ref, uuid) => HazardPhotoProgress(0, 0));

@riverpod
class HazardPhoto extends _$HazardPhoto {
  @override
  Future<Uint8List?> build(String uuid) async {
    final res = await ref.read(dioProvider).get<Uint8List>(
      "/hazard/image/$uuid",
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (received, total) =>
      ref.read(hazardPhotoProgressProvider(uuid).notifier).state = HazardPhotoProgress(received, total),
    );
    return res.data;
  }
}

class SelectedHazard {
  final bool moveCamera;
  final Hazard? hazard;
  SelectedHazard(this.moveCamera, [this.hazard]);
}

class SelectedHazardNotifier extends StateNotifier<SelectedHazard> {
  SelectedHazardNotifier() : super(SelectedHazard(false));

  void selectAndMove(Hazard hazard) {
    state = SelectedHazard(true, hazard);
  }
  void select(Hazard hazard) {
    state = SelectedHazard(false, hazard);
  }
  void deselect() {
    state = SelectedHazard(false);
  }
}

final selectedHazardProvider = StateNotifierProvider<SelectedHazardNotifier, SelectedHazard>
  ((ref) => SelectedHazardNotifier());
