import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hazard_photo_provider.g.dart';

/// Provides the directory where cached images should be stored.
/// Creates directory if it does not exist.
@Riverpod(keepAlive: true)
Future<Directory?> imageDirectory(ImageDirectoryRef ref) async {
  if (kIsWeb) {
    return null;
  }
  final appDir = await getApplicationSupportDirectory();
  final imageDir = Directory(join(appDir.path, kImageDirectory));
  await imageDir.create(recursive: true);
  return imageDir;
}

/// Stores the progress of a photo download.
class HazardPhotoProgressState {
  /// The number of bytes downloaded so far.
  int transmitted;
  /// The total number of bytes to be downloaded.
  int total;
  HazardPhotoProgressState(this.transmitted, this.total);
  /// True if the photo is fully downloaded.
  bool get isComplete => transmitted == total;
  /// The download progress from 0 to 1.
  double get progress {
    final p = transmitted/total;
    return p.isNaN ? 0.0 : p.clamp(0, 1);
  }
}

/// Provides the progress of the currently downloading photo.
@riverpod
class HazardPhotoProgress extends _$HazardPhotoProgress {
  @override
  HazardPhotoProgressState build(String uuid) => HazardPhotoProgressState(0, 0);

  /// Sets the current download progress.
  void updateProgress(int transmitted, int total) =>
      state = HazardPhotoProgressState(transmitted, total);
}

/// Provides the [Uint8List] image data for a photo of given UUID. Caches downloads locally.
@Riverpod(keepAlive: true)
class HazardPhoto extends _$HazardPhoto {
  @override
  Future<Uint8List?> build(String uuid) async {
    // Web we can't cache images so fetch from server.
    if (kIsWeb) {
      return await _fetch(uuid);
    }
    // Read all cached image filenames and see if any match the uuid we need.
    final imageDir = (await ref.watch(imageDirectoryProvider.future))!;
    final hasImage = await imageDir.list().any((f) => f.uri.pathSegments.last == uuid);
    // If image doesn't exist in cache (or path exists but is not a File) fetch from server.
    if (!hasImage) {
      return await _fetch(uuid);
    }
    // Otherwise load image from cache
    final imageFile = File(join(imageDir.path, uuid));
    return await imageFile.readAsBytes();
  }

  Future<Uint8List?> _fetch(String uuid) async {
    final res = await ref.read(dioProvider).get<Uint8List>(
      "/hazard/image/$uuid",
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (received, total) =>
          ref.read(hazardPhotoProgressProvider(uuid).notifier)
              .updateProgress(received, total),
    );
    final data = res.data;
    // If we're not on web we should save the image to the cache.
    if (!kIsWeb && data != null) {
      // No await since we want to immediately display the image and save it in the background.
      _saveImage(uuid, data);
    }
    return data;
  }

  Future<void> _saveImage(String uuid, Uint8List data) async {
    // Get image path and ensure exists.
    final imageDir = (await ref.read(imageDirectoryProvider.future))!;
    final imageFile = File(join(imageDir.path, uuid));
    await imageFile.create();
    // Write data.
    await imageFile.writeAsBytes(data);
  }
}
