import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

Future<bool> testLocationTooFar(BuildContext context, WidgetRef ref, {
  required LatLng actionLocation, 
    String title = "Location is too far",
    String? content,
    String acceptText = "Ok",
    bool overrideEnabled = false,
    String overrideText = "Override",
}) {
  
  final locationData = ref.read(locationProvider);
  
  
  final continueCompleter = Completer<bool>();
  if (!locationData.hasValue) {
    // TODO should we just alert the user like we are, or throw an error?
    continueCompleter.complete(
      _badLocationAlert(context, "Invalid location", "No location was found", acceptText, overrideEnabled, overrideText)
    );
  }
  final location = locationData.requireValue; 
  if (context.mounted && 
      const DistanceVincenty().as(LengthUnit.Meter, LatLng(location.latitude, location.longitude), actionLocation)
      <= kLocationTolerance + (location.accuracy)) {
    continueCompleter.complete(true);
    return continueCompleter.future;
  }
  continueCompleter.complete(_badLocationAlert(context, title, content, acceptText, overrideEnabled, overrideText));
  return continueCompleter.future;
}

Future<bool> _badLocationAlert(BuildContext context, String title, String? content, String acceptText, bool overrideEnabled, String overrideText) {
  final continueCompleter = Completer<bool>(); 
  showPlatformDialog(context: context, builder: (context) => PlatformAlertDialog(
    title: PlatformText(title),
    content: (content == null) ? null : PlatformText(content),
    actions: [
      PlatformDialogAction(
          onPressed: () {
            Navigator.pop(context);
            continueCompleter.complete(false);
          },
          child: PlatformText(acceptText)
      ),
      if (overrideEnabled) PlatformDialogAction(
          onPressed: () {
            Navigator.pop(context);
            continueCompleter.complete(true);
          },
          child: PlatformText(overrideText)
      ),
    ],
  ));
  return continueCompleter.future;
}