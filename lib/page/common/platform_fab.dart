import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';


/// A generic floating action button that automatically customizes to the current platform based on provided themes 
class PlatformFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Object? heroTag;
  final double opacity;
  const PlatformFAB({
    super.key,
    required this.onPressed,
    required this.child,
    this.opacity = 1,
    this.heroTag,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PlatformWidget(
      cupertino: (context, _) {
        const fabRadius = BorderRadius.all(Radius.circular(8));
        // Reduce blur before opacity
        final double sigma = 15 * Curves.easeIn.transform((opacity*1.5 - 0.5).clamp(0, 1));
        final shadowColor = Colors.black.withOpacity(0.26*opacity);
        return Container(
          decoration: BoxDecoration(
            borderRadius: fabRadius,
            boxShadow: [
              OutlineBoxShadow(
                color: shadowColor,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: fabRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Opacity(
                  opacity: opacity,
                  child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
                      pressedOpacity: 0.9,
                      onPressed: onPressed,
                      child: child
                  ),
                ),
              ),
            ),
          ),
        );
      },
      material: (_, __) => Opacity(
        opacity: opacity,
        child: FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: theme.colorScheme.surface,
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
