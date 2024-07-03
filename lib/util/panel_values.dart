import 'package:flutter/cupertino.dart';

/// An assortment of calculated values regarding the panel  
class PanelValues {
  /// The fraction of the total window height to which the panel should open
  static const double _kOpenFraction = 0.8;

  /// The minimum visible height of the panel (can go below when hidden)
  static const double _kCollapsedHeight = 100;

  /// Fraction of the distance between the open and collapsed states to which the panel should snap
  static const double _kSnapPoint = 0.4;
  
  /// The open height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN THE BUILD METHOD. This value may change when the BuildContext changes
  static double openHeight(BuildContext context) => _kOpenFraction * MediaQuery.of(context).size.height;
  
  /// The collapsed height of the panel as a fraction of the maximum panel height
  /// 
  /// ALWAYS USE THIS IN a BUILD METHOD. This value may change when the BuildContext changes
  static double collapsedFraction (BuildContext context) => _kCollapsedHeight / openHeight(context);
  /// The collapsed height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double collapsedHeight (BuildContext context) => _kCollapsedHeight;
  
  /// The snapped height of the panel as a fraction of the maximum panel height
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double snapFraction (BuildContext context) => snapHeight(context) / openHeight(context);
  /// The snapped height of the panel in pixels
  /// 
  /// ALWAYS USE THIS IN A BUILD METHOD. This value may change when the BuildContext changes
  static double snapHeight (BuildContext context) =>  _kSnapPoint * (openHeight(context) - _kCollapsedHeight) + _kCollapsedHeight;
}
