import 'dart:async';
import 'dart:io';

import 'package:forest_park_reports/provider/map_position_provider.dart';
import 'package:http/io_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:forest_park_reports/provider/align_position_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/page/home_page/map_page/trail_cursor_marker_layer.dart';
import 'package:forest_park_reports/page/home_page/map_page/trail_ends_marker_layer.dart';
import 'package:forest_park_reports/page/home_page/map_page/trail_polyline_layer.dart';
import 'package:forest_park_reports/page/home_page/map_page/hazard_marker_layer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

/// Renders the main map.
///
/// Contains all trails, hazard markers, and hazard info popups.
class MapPage extends ConsumerStatefulWidget {
  final MapController mapController;
  const MapPage({super.key, required this.mapController});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> with WidgetsBindingObserver, TickerProviderStateMixin{
  // TODO add satellite map style
  late final PopupController _popupController;
  late StreamController<double?> _alignPositionStreamController;
  late final AnimatedMapController _animatedMapController;
  bool _isFingerDown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _popupController = PopupController();
    _alignPositionStreamController = StreamController<double?>();
    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      mapController: widget.mapController
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animatedMapController.mapController.dispose();
    _alignPositionStreamController.close();
    super.dispose();
  }

  // listen for brightness change so we can refrash map tiles
  @override
  void didChangePlatformBrightness() {
    setState(() {});
    // // This is a workaround for a bug in flutter_map preventing the
    // // TileLayerOptions reset stream from working. Instead we are rebuilding
    // // every image in the application.
    // // This is ~probably~ definitely causing some visual bugs and needs to be updated asap.
    // // Some light mode tiles are still cached, and show when relaunching the app
    // PaintingBinding.instance.imageCache.clear();
  }

  //TODO move provider consumption out of main widget
  @override
  Widget build(BuildContext context) {
    // using ref.watch will allow the widget to be rebuilt everytime
    // the provider is updated
    // final parkTrails = ref.watch(parkTrailsProvider);
    final locationStatus = ref.watch(locationPermissionStatusProvider);
    ref.listen(alignPositionTargetProvider, (prev, next) {
      if (next==AlignPositionTargetState.forestPark){
        _alignPositionStreamController.add(null);
        _animatedMapController.centerOnPoint(kHomeCameraPosition.center, zoom: kHomeCameraPosition.zoom);
      }
    });

    

    final retinaMode = ref.watch(settingsProvider.select((s) => s.retinaMode));

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _isFingerDown = true,
      onPointerUp: (_) => _isFingerDown = false,
      // onPointerUp: ,
      child: FlutterMap(
        mapController: _animatedMapController.mapController,
        options: MapOptions(
          initialCenter: kHomeCameraPosition.center,
          initialZoom: kHomeCameraPosition.zoom,
          initialRotation: kHomeCameraPosition.rotation,
          backgroundColor: const Color(0xff53634b),
          // lightMode
          //     ? const Color(0xfff7f7f2)
          //     : const Color(0xff36475c),
          onPositionChanged: (MapCamera position, bool hasGesture) {
            if (hasGesture && _isFingerDown) {
              ref.read(alignPositionTargetProvider.notifier).update(AlignPositionTargetState.none);
            }
            ref.read(mapCameraPositionProvider.notifier).update(position);
          },
          maxZoom: 20,
          onTap: (TapPosition position, LatLng? latlng) {
            // We clicked somewhere that is not a polyline nor hazard.
            // Deselect both
            if (ref
                .read(panelPositionProvider)
                .position == PanelState.OPEN) {
              ref.read(panelPositionProvider.notifier).move(
                  PanelState.SNAPPED);
            } else {
              ref.read(selectedHazardProvider.notifier).deselect();
              ref.read(selectedRelationProvider.notifier).deselect();
              ref.read(panelPositionProvider.notifier).move(
                  PanelState.HIDDEN);
            }
          },
        ),
        //TODO attribution, this one looks off
        // nonRotatedChildren: const [
        //   SimpleAttributionWidget(
        //       source: Text('OpenStreetMap contributors')
        //   ),
        // ],
        children: [
          TileLayer(
            tileProvider: const FMTCStore('forestPark').getTileProvider(
              httpClient: IOClient(HttpClient()..maxConnectionsPerHost = 3)
            ),
            urlTemplate: "https://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}&s=Ga",
            // urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            // urlTemplate: "https://api.mapbox.com/styles/v1/ethemoose/cl5d12wdh009817p8igv5ippy/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
            // urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}@2x",
            // urlTemplate: false
            //         ? "https://api.mapbox.com/styles/v1/ethemoose/cl55mcv4b004u15sbw36oqa8p/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}"
            //         : "https://api.mapbox.com/styles/v1/ethemoose/cl548b3a4000s15tkf8bbw2pt/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
            retinaMode: retinaMode,
            maxNativeZoom: 22 - (retinaMode ? 1 : 0),
            maxZoom: 23 - (retinaMode ? 1 : 0),
          ),
          // TODO render on top of everything (currently breaks tappable polyline)
          // we'll probably need to handle taps ourselves, shouldn't be too bad
          if (locationStatus.permission.authorized)
            Consumer(
                builder: (context, ref, _) {
                  final positionStreamController = StreamController<LocationMarkerPosition?>();
                  ref.listen(locationProvider, (_, pos) {
                    positionStreamController.add(pos.valueOrNull?.locationMarkerPosition());
                  });
                  final followOnLocationTarget = ref.watch(alignPositionTargetProvider);
                  return CurrentLocationLayer(
                    alignPositionStream: _alignPositionStreamController.stream,
                    alignPositionOnUpdate: followOnLocationTarget.update,
                    positionStream: positionStreamController.stream
                  );
                }
            ),
          const TrailPolylineLayer(),
          const TrailEndsMarkerLayer(),
          HazardMarkerLayer(popupController: _popupController, mapController: _animatedMapController),
          const TrailCursorMarkerLayer(),
          // const MapCompass.cupertino(alignment: Alignment.topLeft, hideIfRotatedNorth: false,)
        ],
      ),
    );
  }
}
