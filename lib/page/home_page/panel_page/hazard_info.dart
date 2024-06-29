import 'package:flutter/material.dart';
import 'package:forest_park_reports/model/hazard_update.dart';

import 'package:forest_park_reports/page/home_page/panel_page/hazard_image.dart';

/// A widget for the main panel modal with info on a singular hazard
class UpdateInfoWidget extends StatelessWidget {
  final HazardUpdateModel update;
  const UpdateInfoWidget({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                update.active ? "Reported Present" : "Reported Cleared",
                style: theme.textTheme.titleLarge,
              ),
              Text(
                  update.timeString(),
                  style: theme.textTheme.titleMedium
              )
            ],
          ),
          SizedBox(
            height: 80,
            child: AspectRatio(
              aspectRatio: 4/3,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: (update.image != null) ? HazardImage(update.image!, blurHash: update.blurHash) : Container(),
              ),
            )
          )
        ],
      ),
    );
  }
}