import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/page/home_page/panel_page.dart';
import 'package:forest_park_reports/page/common/platform_fab.dart';
import 'package:forest_park_reports/page/settings_page.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/page/common/statusbar_blur.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/page/home_page/map_fabs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/page/home_page/map_page.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

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
  late final _panelController = PanelController();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
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
                  _panelController.goToState(next.position);
                }
              });
              // update panel position
              var position = ref.read(panelPositionProvider).position;
              if (_panelController.isAttached) {
                position = _panelController.panelState;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  ref.read(panelPositionProvider.notifier).update(position));
                print(PanelValues.openHeight(context));
                print(PanelValues.collapsedHeight(context));
                print(PanelValues.snapHeight(context));
              //TODO cupertino scrolling physics
              return SlidingUpPanel(
                maxHeight: PanelValues.openHeight(context),
                minHeight: PanelValues.collapsedHeight(context),
                snapHeight: PanelValues.snapHeight(context),
                defaultPanelState: PanelState.HIDDEN,
                body: const MapPage(),
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
          Positioned(
            right: kFabPadding,
            bottom: kFabPadding + (_panelController.isAttached ? _panelController.panelHeight + kFabPadding : 0), 
            child: Visibility(
              visible: !_panelController.isAttached ? true
                  : 1 > (_panelController.panelPosition - PanelValues.snapFraction(context)) / (0.2 * (1 - PanelValues.snapFraction(context))),
              child: MapFabs(
                opacity: !_panelController.isAttached ? 1
                    : Curves.easeInOut.transform(
                    1 - clampDouble((_panelController.panelPosition - PanelValues.snapFraction(context))
                        / (0.2 * (1 - PanelValues.snapFraction(context))), 0, 1)
                ),
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
