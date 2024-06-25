import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/map_cursor_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:forest_park_reports/provider/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/fl_latlng_spot.dart';
import 'package:forest_park_reports/util/math.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Graph displayed in the panel modal when a trail is clicked on
class TrailElevationGraph extends ConsumerWidget {
  final int relationID;
  final double height;
  const TrailElevationGraph({
    super.key,
    required this.relationID,
    required this.height,
  });

  Widget _loading() {
    return Center(
        child: PlatformCircularProgressIndicator()
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Gets the relation with relationID
    final relation = ref.watch(relationsProvider).valueOrNull?.firstWhere((r) => r.id == relationID);
    if (relation == null) { return _loading(); }

    // Gets all trails that are part of the relation
    final trails = ref.watch(trailsProvider).valueOrNull?.where((t) =>
        relation.members.contains(t.id)).toList() ?? [];
    if (trails.isEmpty) { return _loading(); }
    trails.sort((a, b) => relation.members.indexOf(a.id).compareTo(relation.members.indexOf(b.id)));

    // Gets all active hazards in the relation
    final activeHazards = ref.watch(activeHazardProvider)
        .valueOrNull?.where((h) => relation.members.contains(h.location.trail)) ?? [];

    // Create a distance list for the entire relation
    final distances = [];
    // Store the cumulative distance of all previous trails
    var cumulativeDistance = 0.0;
    for (final trail in trails) {
      for (final (i, distance) in trail.distances.indexed) {
        distances.add(distance+cumulativeDistance);
        if (i == trail.distances.length-1) {
          cumulativeDistance += distance;
        }
      }
    }

    final maxElevation = trails.map((t) => t.maxElevation).reduce(max);
    final minElevation = trails.map((t) => t.minElevation).reduce(min);

    final List<FlCoordinateSpot> spots = [];
    final filterInterval = max((trails.map((t) => t.geometry.length).reduce(sum)/kElevationMaxEntries).round(), 1);
    int i = 0;
    for (final trail in trails) {
      for (final (j, coord) in trail.geometry.indexed) {
        final cumulativeI = i+j;
        if (cumulativeI % filterInterval == 0) {
          final distance = distances[cumulativeI];
          spots.add(FlCoordinateSpot(
            distance,
            coord.elevation,
            coord,
            activeHazards.firstWhereOrNull((hazard) {
              if (hazard.location.trail != trail.id) {
                return false;
              }
              final difference = hazard.location.node - j;
              final halfFilter = (filterInterval*0.5);
              return -halfFilter < difference && difference <= halfFilter;
            })
          ));
        }
      }
      i += trail.geometry.length;
    }

    final maxInterval = distances.last/5;
    final interval = maxInterval-maxInterval/20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "Elevation",
                style: theme.textTheme.titleMedium
            ),
          ),
        ),
        Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Builder(
                builder: (context) {
                  return LineChart(
                    LineChartData(
                        maxY: (maxElevation/50).ceil() * 50.0,
                        minY: (minElevation/50).floor() * 50.0,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            dotData: FlDotData(
                              checkToShowDot: (s, d) {
                                final coordSpot = s is FlCoordinateSpot
                                    ? s : spots[d.spots.indexOf(s)];
                                return coordSpot.hazard != null;
                              },
                              getDotPainter: (a, b, c, d) => FlDotCirclePainter(
                                color: Colors.red,
                                radius: 5,
                              )
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchCallback: (event, ltr) {
                            // This is used to update the map cursor
                            // When the graph is dragged, we update the cursor
                            // When it is released, we clear it.
                            if (event is FlPanDownEvent || event is FlPanUpdateEvent || event is FlLongPressMoveUpdate) {
                              final lineTouch = ltr?.lineBarSpots?.firstOrNull;
                              if (lineTouch != null) {
                                final spot = spots[lineTouch.spotIndex];
                                ref.read(mapCursorProvider.notifier).set(spot.position);
                              }
                            }
                            if (event is FlLongPressEnd || event is FlPanEndEvent || event is FlTapUpEvent || event is FlTapUpEvent) {
                              ref.read(mapCursorProvider.notifier).clear();
                            }
                          },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedBarSpots) {
                              return [
                                for (final spot in touchedBarSpots)
                                  LineTooltipItem(
                                    '${spots[spot.spotIndex].y.toStringAsFixed(0)} m',
                                    theme.textTheme.labelLarge!,
                                  ),
                              ];
                            }
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 65,
                                // TODO add units to settings
                                getTitlesWidget: (yVal, meta) {
                                  return Text("${yVal.round().toString()} m");
                                },
                                interval: 50
                            )
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (xVal, meta) {
                                final offInterval = (xVal % meta.appliedInterval);
                                final isRegInterval = (offInterval < 0.01 || offInterval > meta.appliedInterval - 0.01);
                                return isRegInterval ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text("${(xVal/1000).toStringRemoveTrailing(1)} km"),
                                ) : Container();
                              },
                              interval: interval
                            )
                          ),
                        )
                    ),
                  );
                }
              ),
            ),
          ),
        ),
        // Container(
        //   decoration: BoxDecoration(
        //       borderRadius: const BorderRadius.all(Radius.circular(8)),
        //       color: CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40)
        //   ),
        //   height: height,
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        //     child: LineChart(
        //       LineChartData(
        //           maxY: (trailData.maxElevation/50).ceil() * 50.0,
        //           minY: (trailData.minElevation/50).floor() * 50.0,
        //           lineBarsData: [
        //             LineChartBarData(
        //               spots: spots,
        //               isCurved: false,
        //               dotData: FlDotData(
        //                   checkToShowDot: (s, d) => hazardsMap[s.x] != null,
        //                   getDotPainter: (a, b, c, d) => FlDotCirclePainter(
        //                     color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
        //                     radius: 5,
        //                   )
        //               ),
        //             ),
        //           ],
        //           gridData: const FlGridData(show: false),
        //           borderData: FlBorderData(show: false),
        //           titlesData: FlTitlesData(
        //               topTitles: const AxisTitles(),
        //               rightTitles: const AxisTitles(),
        //               leftTitles: AxisTitles(
        //                   sideTitles: SideTitles(
        //                       showTitles: true,
        //                       reservedSize: 65,
        //                       getTitlesWidget: (yVal, meta) {
        //                         return Text("${yVal.round().toString()} ft");
        //                       },
        //                       interval: 50
        //                   )
        //               ),
        //               bottomTitles: AxisTitles(
        //                   sideTitles: SideTitles(
        //                       showTitles: true,
        //                       getTitlesWidget: (xVal, meta) {
        //                         final offInterval = (xVal % meta.appliedInterval);
        //                         final isRegInterval = (offInterval < 0.01 || offInterval > meta.appliedInterval - 0.01);
        //                         return isRegInterval ? Padding(
        //                           padding: const EdgeInsets.only(top: 4),
        //                           child: Text("${xVal.toStringRemoveTrailing(1)} mi"),
        //                         ) : Container();
        //                       },
        //                       interval: interval
        //                   )
        //               )
        //           )
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}