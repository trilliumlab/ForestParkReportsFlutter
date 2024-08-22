import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/common/platform_fab.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/provider/align_position_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/page/common/permissions_dialog.dart';
import 'package:forest_park_reports/page/common/hazard_add_modal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The floating action buttons used on the map page. Holds the location and add hazard [PlatformFAB].
class MapFabs extends ConsumerWidget {
  final double opacity;

  const MapFabs({super.key, this.opacity = 1});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      verticalDirection: VerticalDirection.up,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Consumer(
            builder: (context, ref, child) {
              return PlatformFAB(
                heroTag: "add_hazard_fab",
                opacity: opacity,
                onPressed: () async {
                  createHazardAddModal(context);
                },
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onSurface,
                ),
              );
            }
        ),
        const SizedBox(
          height: 10,
        ),
        Consumer(
          builder: (context, ref, child) {
            final followOnLocationTarget = ref.watch(alignPositionTargetProvider);
            return PlatformFAB(
              heroTag: "location_fab",
              opacity: opacity,
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
              child: Icon(
                followOnLocationTarget == AlignPositionTargetState.forestPark
                    ? Icons.park
                    : followOnLocationTarget == AlignPositionTargetState.currentLocation
                    ? Icons.my_location
                    : Icons.location_searching,
                color: followOnLocationTarget == AlignPositionTargetState.none
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
              ),
            );
          }
        ),
      ],
    );
  }
}
