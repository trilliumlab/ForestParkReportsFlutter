import 'package:flutter/material.dart';
import 'package:forest_park_reports/util/trail_eyes_icons.dart';

/// An icon with a filled in background for use on the map. Only works with Material pin icons.
class MapIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const MapIcon(this.icon, {
    required this.color,
    this.backgroundColor = Colors.white,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        // Background icon
        Icon(
          TrailEyesIcons.blankPin,
          color: backgroundColor,
        ),
        Icon(
          icon,
          color: color,
        ),
      ],
    );
  }
}
