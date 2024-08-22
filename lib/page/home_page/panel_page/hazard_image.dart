import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/common/fade_in_widget.dart';
import 'package:forest_park_reports/provider/hazard_photo_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Displays an image of a hazard; used in hazard_info, trail_info, and panel_page
class HazardImage extends ConsumerWidget {
  final String uuid;
  final String? blurHash;
  const HazardImage(this.uuid, {super.key, this.blurHash});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(hazardPhotoProvider(uuid));

    final prov = BlurhashFfiImage(blurHash!);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (blurHash != null)
          FadeInWidget(
            placeholder: Image(
              image: prov,
              fit: BoxFit.cover,
            ),
            child: image.hasValue ? Image(
              image: image.value!,
              fit: BoxFit.cover,
            ) : null,
          )
        else if (image.hasValue)
          FadeInWidget(
            child: Image(
              image: image.value!,
              fit: BoxFit.cover,
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
