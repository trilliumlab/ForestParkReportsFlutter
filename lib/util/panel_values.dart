import 'package:flutter/material.dart';

/// An assortment of calculated values regarding the panel  
class PanelValues {
  /// The fraction of the total window height to which the panel should open
  static const double _kOpenFraction = 0.85;

  /// The minimum visible height of the panel (can go below when hidden)
  static const double _kCollapsedHeight = 100;

  /// Fraction of the distance between the open and collapsed states to which the panel should snap
  static const double _kSnapPoint = 0.5;

  static double panelBottomPadding(BuildContext context) => (MediaQuery.of(context).viewPadding.bottom > 40)
      ? MediaQuery.of(context).viewPadding.bottom
      : MediaQuery.of(context).viewPadding.bottom / 2;
  
  /// The open height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN THE BUILD METHOD. This value may change when the BuildContext changes
  static double openHeight(BuildContext context) => _kOpenFraction * MediaQuery.of(context).size.height;
  
  /// The collapsed height of the panel as a fraction of the maximum panel height
  /// 
  /// ALWAYS USE THIS IN a BUILD METHOD. This value may change when the BuildContext changes
  static double collapsedFraction (BuildContext context) => collapsedHeight(context) / openHeight(context);
  /// The collapsed height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double collapsedHeight (BuildContext context) => _kCollapsedHeight + panelBottomPadding(context);
  
  /// The collapsed height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double safeCollapsedHeight (BuildContext context) => _kCollapsedHeight;
  
  /// The snapped height of the panel as a fraction of the maximum panel height
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double snapFraction (BuildContext context) => snapHeight(context) / openHeight(context);
  /// The snapped height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double snapHeight (BuildContext context) =>  _kSnapPoint * (openHeight(context) - collapsedHeight(context))
      + collapsedHeight(context);
}
