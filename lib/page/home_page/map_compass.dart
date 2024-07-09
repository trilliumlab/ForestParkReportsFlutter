import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/provider/map_position_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// A compass for flutter_map that shows the map rotation and allows to reset
/// the rotation back to 0.
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

    if (widget.hideIfRotatedNorth && (camera?.rotation ?? 0) % 360 == 0) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: Transform.rotate(
          angle: degToRadian(camera?.rotation ?? 0 + widget.rotationOffset),
          child: IconButton(
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            icon: widget.icon ?? PlatformWidget(
              cupertino: (_, __) => SizedBox(height: 50, child: Image(image: View.of(context).platformDispatcher.platformBrightness == Brightness.light
                ? const AssetImage("assets/image/cupertino_compass.png")
                : const AssetImage("assets/image/cupertino_compass_dark.png"))),
              material: (_, __) => Transform.rotate(
                angle: degToRadian(-45.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(CupertinoIcons.compass, color: Colors.red, size: 50),
                    Icon(CupertinoIcons.compass_fill, color: theme.colorScheme.surface, size: 50),
                    Icon(CupertinoIcons.circle, color: theme.colorScheme.surface, size: 52),
                  ],
                ),
              ),
            ),
            onPressed:
                widget.onPressed ?? () => _resetRotation(camera),
          ),
        ),
      ),
    );
  }

  void _resetRotation(MapCamera? camera) {
    // current rotation of the map
    final rotation = camera?.rotation ?? 0;
    // nearest north (0°, 360°, -360°, ...)
    final endRotation = (rotation / 360).round() * 360.0;
    // don't start animation if rotation doesn't need to change
    if (rotation == endRotation && camera != null) return;

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
    controller.rotate(_rotationTween.evaluate(_rotateAnimation));
    ref.read(mapPositionProvider.notifier).update(controller.camera);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}