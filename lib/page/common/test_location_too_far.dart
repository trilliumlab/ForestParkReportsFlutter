import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

Future<bool> testLocationTooFar(BuildContext context, WidgetRef ref, {
  required LatLng actionLocation,
  required double tolerance,
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
      DistanceVincenty().as(LengthUnit.Meter, location.latLng()!, actionLocation)
      <= tolerance + (location.accuracy)) {
    continueCompleter.complete(true);
  } else {
    continueCompleter.complete(_badLocationAlert(context, title, content, acceptText, overrideEnabled, overrideText));
  }
  return continueCompleter.future;
}

Future<bool> testLocationTooFarDynamic(BuildContext context, WidgetRef ref, {
    required Future<LatLng> Function(BuildContext, WidgetRef, LatLng) actionLocationGetter,
    required double tolerance,
    String title = "Location is to far",
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

  
  actionLocationGetter(context, ref, location.latLng()!).then( (actionLocation) {
    if (context.mounted && 
        DistanceVincenty().as(LengthUnit.Meter, location.latLng()!, actionLocation)
        <= tolerance + (location.accuracy)) {
      continueCompleter.complete(true);
    } else {
      continueCompleter.complete(_badLocationAlert(context, title, content, acceptText, overrideEnabled, overrideText));
    }
  });
  return continueCompleter.future;
}

Future<bool> _badLocationAlert(BuildContext context, String title, String? content, String acceptText, bool overrideEnabled, String overrideText) {
  final continueCompleter = Completer<bool>(); 
  showDialog(context: context, builder: (context) => AlertDialog(
    title: Text(title),
    content: (content == null) ? null : Text(content),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          continueCompleter.complete(false);
        },
        child: Text(acceptText)
      ),
      if (overrideEnabled)
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            continueCompleter.complete(true);
          },
          child: Text(overrideText)
        ),
    ],
  ));
  return continueCompleter.future;
}
