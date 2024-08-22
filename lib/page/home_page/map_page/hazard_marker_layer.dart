import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/page/home_page/map_page/hazard_info_popup.dart';
import 'package:forest_park_reports/page/home_page/map_page/map_icon.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:forest_park_reports/util/panel_values.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

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
        alignment: kMarkerTopAlignment,
        child: GestureDetector(
          onTap: hazard.offline ? null : () {
            ref.read(selectedRelationProvider.notifier).deselect();
            if (hazard == ref.read(selectedHazardProvider).hazard) {
              ref.read(panelPositionProvider.notifier).move(PanelState.HIDDEN);
              ref.read(selectedHazardProvider.notifier).deselect();
              _popupController.hideAllPopups();
            } else if (ref.read(panelPositionProvider).position.index <= PanelState.COLLAPSED.index) {
              ref.read(panelPositionProvider.notifier).move(PanelState.SNAPPED);
            }
            ref.read(selectedHazardProvider.notifier).select(hazard);
            _popupController.showPopupsOnlyFor([marker]);
          },
          child: MapIcon(
            Icons.fmd_bad_rounded,
            color: hazard.offline
                ? Colors.grey
                : Colors.red,
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
          ref.read(panelPositionProvider.notifier).move(PanelState.SNAPPED);
          _mapController.animateTo(dest: next.hazard!.location, offset: Offset(0, 24 - (PanelValues.positionHeight(context, PanelState.SNAPPED) ?? 0) / 2));
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
        ),
      ),
    );
  }
}

class HazardMarker extends Marker {
  final HazardModel hazard;
  HazardMarker({required this.hazard, required super.child, super.rotate, super.alignment}) : super(point: hazard.location);
}
