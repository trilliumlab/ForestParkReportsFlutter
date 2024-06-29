import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:forest_park_reports/model/relation.dart';
import 'package:forest_park_reports/page/home_page.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:forest_park_reports/page/home_page/panel_page/hazard_image.dart';
import 'package:forest_park_reports/page/home_page/panel_page/hazard_info.dart';
import 'package:forest_park_reports/page/home_page/panel_page/trail_info.dart';
import 'package:forest_park_reports/page/home_page/panel_page/trail_elevation_graph.dart';
import 'package:forest_park_reports/page/home_page/panel_page/trail_hazards_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The sliding-up modal with info on the current selected trail or hazard on the map
class PanelPage extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final ScreenPanelController panelController;
  const PanelPage({
    super.key,
    required this.scrollController,
    required this.panelController,
  });
  @override
  ConsumerState<PanelPage> createState() => _PanelPageState();
}

//TODO stateless?
class _PanelPageState extends ConsumerState<PanelPage> {
  @override
  Widget build(BuildContext context) {
    final selectedRelationID = ref.watch(selectedRelationProvider);
    final selectedRelation = selectedRelationID == null ? null : ref.watch(relationsProvider).value?.get(selectedRelationID);
    final selectedHazard = ref.watch(selectedHazardProvider.select((h) => h.hazard));
    final hazardRelation = selectedHazard == null ? null : ref.read(relationsProvider).value?.forTrail(selectedHazard.location.trail);

    HazardUpdateList? hazardUpdates;
    String? lastImage;
    if (selectedHazard != null) {
      hazardUpdates = ref.watch(hazardUpdatesProvider(selectedHazard.uuid));
      lastImage = hazardUpdates!.lastImage;
    }

    return Panel(
      // panel for when a hazard is selected
      child: selectedHazard != null ? TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        // TODO fetch trail name
        title: "${selectedHazard.hazard.displayName} on ${hazardRelation!.tags["name"]}",
        bottomWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      HazardUpdateRequestModel(
                        hazard: selectedHazard.uuid,
                        active: false,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Cleared",
                    style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 20),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      HazardUpdateRequestModel(
                        hazard: selectedHazard.uuid,
                        active: true,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Present",
                    style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context)),
                  ),
                ),
              ),
            ),
          ],
        ),
        children: [
          if (lastImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Opacity(
                opacity: widget.panelController.snapWidgetOpacity,
                child: SizedBox(
                  height: widget.panelController.panelSnapHeight * 0.7
                      + (widget.panelController.panelOpenHeight-widget.panelController.panelSnapHeight)*widget.panelController.pastSnapPosition * 0.6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: HazardImage(lastImage, blurHash: hazardUpdates?.lastBlurHash),
                  ),
                ),
              ),
            ),
          // TODO move this out of here
          Card(
            elevation: 1,
            shadowColor: Colors.transparent,
            margin: EdgeInsets.zero,
            child: Column(
              children: hazardUpdates!.map((update) => UpdateInfoWidget(
                update: update,
              )).toList(),
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //       borderRadius: const BorderRadius.all(Radius.circular(8)),
          //       color: isCupertino(context) ? CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40) : Theme.of(context).colorScheme.secondaryContainer
          //   ),
          //   child: Column(
          //     children: hazardUpdates!.map((update) => UpdateInfoWidget(
          //       update: update,
          //     )).toList(),
          //   ),
          // ),
        ],
      ):

      // panel for when a trail is selected
      selectedRelation != null ? TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        // TODO show real name
        title: selectedRelation.tags["name"],
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Opacity(
              opacity: widget.panelController.snapWidgetOpacity,
              child: TrailElevationGraph(
                relationID: selectedRelation.id,
                height: widget.panelController.panelSnapHeight*0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Opacity(
              opacity: widget.panelController.fullWidgetOpacity,
              child: TrailHazardsWidget(
                  relationID: selectedRelation.id
              ),
            ),
          ),
        ],
      ):

      // panel for when nothing is selected
      TrailInfoWidget(
          scrollController: widget.scrollController,
          panelController: widget.panelController,
          children: const []
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({
    super.key,
    required this.child
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelRadius = BorderRadius.vertical(top: Radius.circular(isCupertino(context) ? 8 : 18));
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      // pass the scroll controller to the list view so that scrolling panel
      // content doesn't scroll the panel except when at the very top of list
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: panelRadius,
            boxShadow: const [
              OutlineBoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: panelRadius,
            child: PlatformWidget(
                cupertino: (context, _) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(
                    color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
                    child: child,
                  ),
                ),
                material: (_, __) => Container(
                  color: theme.colorScheme.surface,
                  child: child,
                )
            ),
          ),
        ),
      ),
    );
  }
}