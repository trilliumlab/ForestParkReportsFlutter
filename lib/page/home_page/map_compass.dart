import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forest_park_reports/provider/map_position_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/util/panel_values.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// A compass for flutter_map that shows the map rotation and allows to reset
/// the rotation back to 0.
/// Adapted from https://github.com/josxha/flutter_map_plugins/blob/main/flutter_map_compass/lib/src/map_compass.dart
class MapCompass extends ConsumerStatefulWidget {
  /// If [icon] is left blank, defaults to a platform-customized icon with light and dark versions.
  const MapCompass({
    super.key,
    this.icon,
    required this.mapController,
    this.rotationOffset = 0,
    this.rotationDuration = const Duration(seconds: 1),
    this.animationCurve = Curves.fastOutSlowIn,
    this.onPressed,
    this.hideIfRotatedNorth = true,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.only(),
    this.showCardDir = false,
  });


  /// This child widget, for example a [Icon] with a compass icon.
  final Widget? icon;

  /// Use this to fix the rotation offset if your icon is not north-up by default.
  final double rotationOffset;

  /// Overrides the default behaviour for a tap or click event
  final VoidCallback? onPressed;

  /// Set to true to hide the compass while the map is not rotated.
  final bool hideIfRotatedNorth;

  /// The [Alignment] of the compass in its parent widget.
  final Alignment alignment;

  /// The padding of the compass widget.
  final EdgeInsets padding;

  /// The duration of the rotation animation.
  final Duration rotationDuration;

  /// The curve of the rotation animation.
  final Curve animationCurve;

  /// The map controller that was passed to the FlutterMap
  final MapController mapController;

  /// When true, shows a letter indicating the cardinal direction the map is facing
  final bool showCardDir;
  
  @override
  ConsumerState<MapCompass> createState() => _MapCompassState();
}

class _MapCompassState extends ConsumerState<MapCompass> with TickerProviderStateMixin {
  AnimationController? _animationController;
  late Animation<double> _rotateAnimation;

  late Tween<double> _rotationTween;

  @override
  Widget build(BuildContext context) {
    
    final camera = ref.watch(mapPositionProvider);

    final ThemeData theme = Theme.of(context);

    if (camera == null || widget.hideIfRotatedNorth && (camera.rotation) % 360 == 0) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: IconButton(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: degToRadian(camera.rotation + widget.rotationOffset),
                child: widget.icon ?? Transform.rotate(
                  angle: degToRadian(135.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle, color: theme.colorScheme.surface, size: 48),
                      Image.asset('assets/icons/compass.png', width: 20),
                    ],
                  ),
                ),
              ),
            ]
          ),
          onPressed:
              widget.onPressed ?? () => _resetRotation(camera),
        ),
      ),
    );
  }

  void _resetRotation(MapCamera camera) {
    // current rotation of the map
    final rotation = camera.rotation;
    // nearest north (0°, 360°, -360°, ...)
    final endRotation = (rotation / 360).round() * 360.0;
    // don't start animation if rotation doesn't need to change
    if (rotation == endRotation) return;

    _animationController = AnimationController(
      duration: widget.rotationDuration,
      vsync: this,
    )..addListener(_handleAnimation);
    _rotateAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: widget.animationCurve,
    );

    _rotationTween = Tween<double>(begin: rotation, end: endRotation);
    _animationController!.forward(from: 0);
  }

  void _handleAnimation() {
    final controller = widget.mapController;
    controller.rotateAroundPoint(_rotationTween.evaluate(_rotateAnimation), offset: Offset(0, -(PanelValues.positionHeight(context, ref.read(panelPositionProvider).position) ?? 0) / 2));
    ref.read(mapPositionProvider.notifier).update(controller.camera);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}