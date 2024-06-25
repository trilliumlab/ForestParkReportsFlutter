import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HazardImage extends ConsumerWidget {
  final String uuid;
  const HazardImage(this.uuid, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(hazardPhotoProvider(uuid));
    final progress = ref.watch(hazardPhotoProgressProvider(uuid)).progress;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: PlatformWidget(
            cupertino: (_, __) => CupertinoActivityIndicator.partiallyRevealed(
              progress: progress,
            ),
            material: (_, __) => CircularProgressIndicator(
              value: progress,
            ),
          ),
        ),
        if (image.hasValue)
          Image.memory(
            image.value!,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}
