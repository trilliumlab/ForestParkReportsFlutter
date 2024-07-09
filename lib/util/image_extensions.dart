import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:blurhash_ffi/blurhash.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;

extension CompressImage on img.Image {
  /// Compresses and JPEG encodes an [img.Image]
  /// such that the largest side is [maxSidePixels] pixels.
  Future<void> compressToFile({required String filePath, double maxSidePixels = 1920.0}) async {
    final double resizeScale = maxSidePixels / max(width, height);

    // Resize image to maximum dimension 1920 and jpeg encode.
    final cmd = img.Command()
      ..image(this)
      ..copyResize(width: (width * resizeScale).round())
      ..encodeJpg(quality: 80)
      ..writeToFile(filePath);

    // Run command in isolate.
    await cmd.executeThread();
  }

  /// Computes the BlurHash of an image.
  Future<String?> getBlurHash() async {
    final double thumbScale = 240.0 / max(width, height);

    // Resize image to very small - this speeds up the image hashing algorithm greatly.
    final cmd = img.Command()
      ..image(this)
      ..copyResize(width: (width * thumbScale).round())
      ..encodeBmp();

    // Run command in isolate.
    final thumb = await cmd.getBytesThread();
    if (thumb == null) {
      return null;
    }

    // Calculate BlurHash
    final imageProvider = MemoryImage(thumb);
    final String blurHash = await BlurhashFFI.encode(imageProvider);

    return blurHash;
  }
}
