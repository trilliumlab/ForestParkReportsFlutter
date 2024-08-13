import 'package:flutter/material.dart';

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
    return Opacity(
      opacity: opacity,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: theme.colorScheme.surface,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
