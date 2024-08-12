import 'package:flutter/material.dart';

/// A pill that indicates draggability of the main panel
class PanelPill extends StatelessWidget {
  const PanelPill({super.key});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 10
        ),
        width: 26,
        height: 5,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            borderRadius: const BorderRadius.all(Radius.circular(12.0))),
      ),
    );
  }
}
