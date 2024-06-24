import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/home_page/panel_page.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/page/common/permissions_dialog.dart';
import 'package:forest_park_reports/page/common/add_hazard_modal.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../provider/align_position_provider.dart';


class MapFabs extends ConsumerWidget {
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      verticalDirection: VerticalDirection.up,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          // right: kFabPadding,
          // bottom: (isCupertino(context) ? _panelController.panelHeight - 18 : _panelController.panelHeight - 8) + 20,
          child: Consumer(
            builder: (context, ref, child) {
              return PlatformFAB(
                heroTag: "add_hazard_fab",
                onPressed: () async {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Dismissible(
                          direction: DismissDirection.down,
                          key: const Key('key'),
                          onDismissed: (_) => Navigator.of(context).pop(),
                          child: const AddHazardModal()
                      );
                    },
                  );
                },
                child: PlatformWidget(
                  cupertino: (_, __) => Icon(
                    // Fix for bug in cupertino_icons package, should be CupertinoIcons.location
                      CupertinoIcons.add,
                      color: View.of(context).platformDispatcher.platformBrightness == Brightness.light
                          ? CupertinoColors.systemGrey.highContrastColor
                          : CupertinoColors.systemGrey.darkHighContrastColor
                  ),
                  material: (_, __) => Icon(
                    Icons.add,
                    color: theme.colorScheme.onSurface,
                  ),
                )
              );
            }
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          child: Consumer(
            builder: (context, ref, child) {
              final followOnLocationTarget = ref.watch(alignPositionTargetProvider);
              return PlatformFAB(
                heroTag: "location_fab",
                onPressed: () async {
                  final status = await ref.read(locationPermissionStatusProvider.notifier).checkPermission();
                  if (!context.mounted) return;
                  if (status.permission.authorized) {
                    switch (followOnLocationTarget) {
                      case AlignPositionTargetState.none:
                        ref.read(alignPositionTargetProvider.notifier).update(AlignPositionTargetState.currentLocation);
                      case AlignPositionTargetState.currentLocation:
                        ref.read(alignPositionTargetProvider.notifier).update(AlignPositionTargetState.forestPark);
                      case AlignPositionTargetState.forestPark:
                        ref.read(alignPositionTargetProvider.notifier).update(AlignPositionTargetState.currentLocation);
                    }
                  } else {
                    showMissingPermissionDialog(
                      context,
                      'Location Required',
                      'Location permission is required to jump to the current location',
                    );
                  }
                },
                child: PlatformWidget(
                  cupertino: (_, __) => Icon(
                    switch (followOnLocationTarget) {
                      AlignPositionTargetState.currentLocation =>
                        CupertinoIcons.location_fill,
                      AlignPositionTargetState.none =>
                        CupertinoIcons.location,
                      AlignPositionTargetState.forestPark =>
                        Icons.park,
                    },
                    color: View.of(context).platformDispatcher.platformBrightness == Brightness.light
                        ? CupertinoColors.systemGrey.highContrastColor
                        : CupertinoColors.systemGrey.darkHighContrastColor
                  ),
                  material: (_, __) => Icon(
                    followOnLocationTarget == AlignPositionTargetState.forestPark
                        ? Icons.park
                        : Icons.my_location_rounded,
                    color: followOnLocationTarget == AlignPositionTargetState.none
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.primary,
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}
