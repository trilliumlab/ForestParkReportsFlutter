import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/page/home_page/panel_page/hazard_image.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

/// A list of hazards on a given trail when that trail is clicked on
class TrailHazardsWidget extends ConsumerWidget {
  final int relationID;
  const TrailHazardsWidget({super.key, required this.relationID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeHazards = ref.watch(relationsProvider.selectAsync((relations) =>
        relations.firstWhereOrNull((r) => r.id == relationID)))
        .then((relation) => ref.watch(activeHazardProvider.select((hazards) =>
        hazards.valueOrNull?.where((e) =>
        relation?.members.contains(e.location.trail) ?? false))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hazards",
              style: theme.textTheme.titleMedium
            ),
          ),
        ),
        Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
          child: FutureBuilder(
            future: activeHazards,
            builder: (context, activeHazards) => activeHazards.data != null ? Column(
              children: activeHazards.data!.map((hazard) =>
                  HazardInfoWidget(
                    hazard: hazard,
                  )).toList(),
              ) : Center(
                child: PlatformCircularProgressIndicator(),
              ),
          ),
        ),
      ],
    );
  }
}

class HazardInfoWidget extends ConsumerWidget {
  final HazardModel hazard;
  const HazardInfoWidget({super.key, required this.hazard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hazardUpdates = ref.watch(hazardUpdatesProvider(hazard.uuid)).valueOrNull;
    final lastImage = hazardUpdates?.lastImage;
    final lastBlurHash = hazardUpdates?.lastBlurHash;
    return PlatformTextButton(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      onPressed: () {
        ref.read(selectedRelationProvider.notifier).deselect();
        ref.read(selectedHazardProvider.notifier).selectAndMove(hazard);
      },
      material: (_, __) => MaterialTextButtonData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hazard.hazard.displayName,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                  hazard.timeString(),
                  style: theme.textTheme.titleMedium
              )
            ],
          ),
          if (lastImage != null)
            SizedBox(
                height: 80,
                child: AspectRatio(
                  aspectRatio: 4/3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: HazardImage(lastImage, blurHash: lastBlurHash),
                  ),
                )
            )
        ],
      ),
    );
  }
}
