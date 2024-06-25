import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forest_park_reports/provider/map_cursor_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A cursor indicator displayed over a trail when a user drags over the elevation graph
class TrailCursorMarkerLayer extends ConsumerWidget {
  const TrailCursorMarkerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursor = ref.watch(mapCursorProvider);
    if (cursor == null) {
      return Container();
    } else {
      return MarkerLayer(
        markers: [
          Marker(
            point: cursor,
            child: const Icon(
              Icons.circle,
              color: Colors.grey,
              size: 14.0,
            ),
          ),
        ],
      );
    }
  }
}