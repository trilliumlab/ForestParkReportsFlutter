import 'package:flutter/material.dart';

enum HazardType {
  tree("Fallen Tree", Icons.park_outlined),
  flood("Flooded Trail", Icons.flood_rounded),
  other("Other Hazard", Icons.help_outline_outlined);

  const HazardType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}
