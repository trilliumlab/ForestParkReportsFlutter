import 'package:flutter/material.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';

/// A popup that appears above a hazard when clicked with details
class HazardInfoPopup extends StatelessWidget {
  final HazardModel hazard;
  const HazardInfoPopup({super.key, required this.hazard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = BorderRadius.all(Radius.circular(8));
    return Container(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          OutlineBoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          color: theme.colorScheme.surface,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                  child: Text(
                    hazard.hazard.displayName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: Text(
                    hazard.timeString(),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
