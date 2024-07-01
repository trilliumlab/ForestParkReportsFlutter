import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/page/home_page/map_page/hazard_info_popup.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A layer over the trails with hazard icons and [HazardInfoPopup] handling
class HazardMarkerLayer extends ConsumerWidget {
  const HazardMarkerLayer({
    super.key,
    required PopupController popupController,
    required AnimatedMapController mapController
  }) :
    _popupController = popupController,
    _mapController = mapController;

  final PopupController _popupController;
  final AnimatedMapController _mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markers = (ref.watch(activeHazardProvider).valueOrNull??[]).map((hazard) {
      late final HazardMarker marker;
      marker = HazardMarker(
        hazard: hazard,
        rotate: true,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            ref.read(selectedRelationProvider.notifier).deselect();
            if (hazard == ref.read(selectedHazardProvider).hazard) {
              ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
              ref.read(selectedHazardProvider.notifier).deselect();
              _popupController.hideAllPopups();
            }
            else if (ref.read(panelPositionProvider).position == PanelPositionState.closed) {
              ref.read(panelPositionProvider.notifier).move(PanelPositionState.snapped);
            }
            ref.read(selectedHazardProvider.notifier).select(hazard);
            _popupController.showPopupsOnlyFor([marker]);
          },
          child: Icon(
            Icons.warning_rounded,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.destructiveRed, context)
          ),
        )
      );
      return marker;
    }).toList();

    ref.listen<SelectedHazardState>(selectedHazardProvider, (prev, next) {
      if (next.hazard == null) {
        _popupController.hideAllPopups();
      } else {
        _popupController.showPopupsOnlyFor(markers.where((e) => e.hazard == next.hazard).toList());
        if (next.moveCamera) {
          _mapController.centerOnPoint(next.hazard!.location);
        }
      }
    });

    return PopupMarkerLayer(
      options: PopupMarkerLayerOptions(
          popupController: _popupController,
          markers: markers,
          popupDisplayOptions: PopupDisplayOptions(
            builder: (_, marker) {
              if (marker is HazardMarker) {
                return HazardInfoPopup(hazard: marker.hazard);
              }
              return Container();
            },
            animation: const PopupAnimation.fade(duration: Duration(milliseconds: 100)),
          )
      ),
    );
  }
}

class HazardMarker extends Marker {
  final HazardModel hazard;
  HazardMarker({required this.hazard, required super.child, super.rotate, super.alignment}) : super(point: hazard.location);
}
