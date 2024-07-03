import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forest_park_reports/model/relation.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:forest_park_reports/provider/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Marks the start and end points of the trail with a green circle and a red square accordingly.
class TrailEndsMarkerLayer extends ConsumerWidget {
  const TrailEndsMarkerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationID = ref.watch(selectedRelationProvider);
    if (relationID == null) {
      return Container();
    }

    final relation = ref.watch(relationsProvider).value?.get(relationID);
    final trails = ref.watch(trailsProvider).value;

    if (relation == null || trails == null) {
      return Container();
    }

    final firstTrail = trails.get(relation.members.first);
    final lastTrail = trails.get(relation.members.last);

    if (firstTrail == null || lastTrail == null) {
      return Container();
    }

    final prevPoint = lastTrail.geometry[lastTrail.geometry.length-2];
    final bearing = lastTrail.geometry.last.bearingTo(prevPoint);

    return MarkerLayer(
      markers: [
        // End marker
        Marker(
          point: lastTrail.geometry.last,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(bearing/(2*pi)),
            child: const Icon(
              Icons.square_rounded,
              color: Colors.red,
              size: 12.0,
            ),
          ),
        ),
        // Start marker
        Marker(
          point: firstTrail.geometry.first,
          child: const Icon(
            Icons.circle,
            color: Colors.green,
            size: 12.0,
          ),
        ),
      ],
    );
  }
}