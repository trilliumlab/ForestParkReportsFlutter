import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/pages/home_page/panel_page.dart';
import 'package:forest_park_reports/pages/settings_page.dart';
import 'package:forest_park_reports/providers/location_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/permissions_dialog.dart';
import 'package:forest_park_reports/util/statusbar_blur.dart';
import 'package:forest_park_reports/widgets/add_hazard_modal.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/widgets/map_fabs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../providers/align_position_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ScreenPanelController extends PanelController {
  // utility functions
  bool get isPanelSnapped => (panelPosition-snapPoint).abs()<0.0001 && !isPanelAnimating;
  double get safePanelPosition => isAttached ? panelPosition : 0;

  double get snapWidgetOpacity => (panelPosition/snapPoint).clamp(0, 1);
  double get fullWidgetOpacity => ((panelPosition-snapPoint)/(1-snapPoint)).clamp(0, 1);

  // bounding stuff
  double snapPoint;
  double panelClosedHeight;
  ScreenPanelController({
    required this.snapPoint,
    required this.panelClosedHeight,
  });

  double panelOpenHeight = 0;

  double get pastSnapPosition => ((panelPosition-snapPoint)/(1-snapPoint)).clamp(0, 1);
  double get panelSnapHeight => ((panelOpenHeight-panelClosedHeight) * snapPoint) + panelClosedHeight;
  double get panelHeight => safePanelPosition * (panelOpenHeight - panelClosedHeight) + panelClosedHeight;
}

class _HomeScreenState extends State<HomeScreen> {
  // parameters for the sliding modal/panel on the bottom
  // TODO animate hiding/showing of panel
  late final _panelController = ScreenPanelController(
    snapPoint: 0.40,
    panelClosedHeight: 100,
  );

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
    _panelController.panelOpenHeight = MediaQuery.of(context).size.height * 0.80;
    final theme = Theme.of(context);

    return PlatformScaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Consumer(
            builder: (context, ref, child) {
              // listen to panel position state to control panel position
              ref.listen<PanelPositionUpdate>(panelPositionProvider, (prev, next) {
                if (next.move) {
                  switch (next.position) {
                    case PanelPositionState.open:
                      _panelController.open();
                      break;
                    case PanelPositionState.closed:
                      _panelController.close();
                      break;
                    case PanelPositionState.snapped:
                      _panelController.animatePanelToSnapPoint();
                      break;
                  }
                }
              });
              // update panel position
              var position = ref.read(panelPositionProvider).position;
              if (_panelController.isAttached) {
                if (_panelController.isPanelClosed) {
                  position = PanelPositionState.closed;
                } else if (_panelController.isPanelOpen) {
                  position = PanelPositionState.open;
                } else if (_panelController.isPanelSnapped) {
                  position = PanelPositionState.snapped;
                }
              }
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  ref.read(panelPositionProvider.notifier).update(position));
              //TODO cupertino scrolling physics
              return SlidingUpPanel(
                maxHeight: _panelController.panelOpenHeight,
                minHeight: _panelController.panelClosedHeight,
                parallaxEnabled: isMaterial(context),
                parallaxOffset: 0.58,
                snapPoint: _panelController.snapPoint,
                body: const ForestParkMap(),
                controller: _panelController,
                scrollController: _scrollController,
                panelBuilder: () => PanelPage(
                  scrollController: _scrollController,
                  panelController: _panelController,
                ),
                // don't render panel sheet so we can add custom blur
                renderPanelSheet: false,
                onPanelSlide: (double pos) => setState(() {
                  // _snapWidgetOpacity = (pos/_snapPoint).clamp(0, 1);
                  // _fullWidgetOpacity = ((pos-_snapPoint)/(1-_snapPoint)).clamp(0, 1);
                  // _panelHeight = pos * (_panelHeightOpen - _panelHeightClosed) + _panelHeightClosed;
                }),
              );
            },
          ),
          // Location and add hazard buttons
          // When panel is visible, position 20dp above the panel height (_fabHeight)
          // when panel is hidden, set it to 20db from bottom
          Positioned(
            right: kFabPadding,
            bottom: _panelController.panelHeight + kFabPadding, 
            child: Visibility(
              visible: !_panelController.isAttached ? true
                  : 1 < (_panelController.panelPosition - _panelController.snapPoint) / (0.2 * (1 - _panelController.snapPoint)),
              child: Opacity(
                opacity: !_panelController.isAttached ? 1
                    : 1 - clampDouble((_panelController.panelPosition - _panelController.snapPoint) / (0.2 * (1 - _panelController.snapPoint)), 0, 1),
                child: MapFabs(),
              ),
            ),
          ),
          

          // Settings FAB
          Positioned(
            right: kFabPadding,
            top: MediaQuery.of(context).viewPadding.top + kFabPadding,
            child: Consumer(
              builder: (context, ref, child) {
                return PlatformFAB(
                  heroTag: "settings_fab",
                  onPressed: () async {
                    Navigator.of(context).push(
                      platformPageRoute(
                        context: context,
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                  child: PlatformWidget(
                    cupertino: (_, __) => Icon(
                      // Fix for bug in cupertino_icons package, should be CupertinoIcons.location
                        CupertinoIcons.gear,
                        color: View.of(context).platformDispatcher.platformBrightness == Brightness.light
                            ? CupertinoColors.systemGrey.highContrastColor
                            : CupertinoColors.systemGrey.darkHighContrastColor
                    ),
                    material: (_, __) => Icon(
                      Icons.settings,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              }
            ),
          ),
          // status bar blur
          if (isCupertino(context))
            const StatusBarBlur(),
        ],
      ),
    );
  }
}
