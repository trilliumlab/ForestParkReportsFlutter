import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/model/camera_position.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

//const kApiUrl = "https://forestpark.elliotnash.org/api/v1";
// const kApiUrl = "https://forestpark.cecs.pdx.edu/staging/v1";
const kApiUrl = "http://192.168.0.247:8000";
// const kApiUrl = "http://localhost:8000/";

// This is for development only.
// TODO Maybe move this over to the settings page or only set on debug
const kPlatformOverride = null;
// const kPlatformOverride = TargetPlatform.android;
// const kPlatformOverride = TargetPlatform.iOS;

// Example: 11:53 AM July 12 2022
final DateFormat kDisplayDateFormat = DateFormat('hh:mm a MMMM dd y');

// Provider consts
const kHazardRefreshPeriod = Duration(seconds: 10);

// Filesystem consts
const kDbName = "forest_park_reports";
const kImageDirectory = "images";
const kQueueDirectory = "queue";

const double kFabPadding = 10;

// Map constants
const kHomeCameraPosition = CameraPosition(
  center: LatLng(45.57416784067063, -122.76892379502566),
  zoom: 11.5,
);
const kMarkerTopAlignment = Alignment(0, -0.65);

const kElevationMaxEntries = 200;

// Encoding consts
const kNetworkEndian = Endian.little;
const kElevationDeltaMultiplier = 8;

// Isolate consts
const kBackgroundRequestPortName = "backgroundRequestPort";

// Uuid generator
const kUuidGen = Uuid();

// Colors
const kDialogColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xCCF2F2F2),
  darkColor: Color(0xBF1E1E1E),
);
