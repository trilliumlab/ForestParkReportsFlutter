import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/page/common/hazard_modal_base.dart';
import 'package:forest_park_reports/page/common/test_location_too_far.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/provider/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// The additional modal with the ui for reporting a trail hazard 

createHazardAddModal(BuildContext context) async {
  await showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return Dismissible(
          direction: DismissDirection.down,
          key: const Key('key'),
          onDismissed: (_) => Navigator.of(context).pop(),
          child: HazardModal<HazardType>(
            title: "Report New Hazard",
            options: {
              for (final type in HazardType.values)
                type: Text("${type.name[0].toUpperCase()}${type.name.substring(1)}",)
            },
            onSubmit: (context, ref, image, uuid, hazardType) async {

              if (!await testLocationTooFarDynamic(context, ref,
                  tolerance: kAddLocationTolerance,
                  actionLocationGetter: (context, ref, loc) {
                    var completer = Completer<LatLng>();
                    ref.read(trailsProvider.notifier).snapLocation(loc).then(
                      (result) => completer.complete(result.location));
                    return completer.future;
                  },
                  title: "Too far from trail",
                  content: "Reports must be made on a marked Forest Park trail",
                  overrideEnabled: kLocationOverrideEnabled)) {
                return false;
              } 
              // The above check ensured the location already has a value (testLocationTooFarDynamic)
              final location = ref.read(locationProvider).requireValue;
              var snappedLoc = await ref.read(trailsProvider.notifier).snapLocation(location.latLng()!);

              final activeHazardNotifier = ref.read(activeHazardProvider.notifier);

              activeHazardNotifier.createHazard(
                uuid: uuid,
                hazard: hazardType!,
                location: snappedLoc.location,
                imageFile: image
              );
              return true;
            },
          ),
      );
    }
  );
}
