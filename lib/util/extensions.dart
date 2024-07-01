import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

extension LocationDataLatLng on Position {
  LatLng? latLng() =>
      LatLng(latitude, longitude);
}

extension LatLngBearing on LatLng {
  double bearingTo(LatLng other) {
    final y = sin(other.longitudeInRad - longitudeInRad) *
        cos(other.latitudeInRad);
    final x = cos(latitudeInRad) * sin(other.latitudeInRad) -
        sin(latitudeInRad) *
            cos(other.latitudeInRad) *
            cos(other.longitudeInRad - longitudeInRad);

    return atan2(y, x);
  }
}

extension Authorized on LocationPermission {
  bool get authorized =>
      this == LocationPermission.always
          || this == LocationPermission.whileInUse;
}

extension RemoveTrailingZeros on double {
  String toStringRemoveTrailing(int fractionDigits) =>
      toStringAsFixed(fractionDigits).toString().replaceFirst(RegExp(r'\.?0*$'), '');
}

extension PositionToMarker on Position {
  LocationMarkerPosition locationMarkerPosition() =>
      LocationMarkerPosition(latitude: latitude, longitude: longitude, accuracy: accuracy);
  LocationMarkerHeading locationMarkerHeading() =>
      LocationMarkerHeading(heading: heading, accuracy: accuracy);
}

extension Writer on BytesBuilder {
  void addUint64(int value) {
    final data = ByteData(8);
    data.setUint64(0, value, kNetworkEndian);
    add(data.buffer.asUint8List());
  }
  void addUint32(int value) {
    final data = ByteData(4);
    data.setUint32(0, value, kNetworkEndian);
    add(data.buffer.asUint8List());
  }
  void addUint16(int value) {
    final data = ByteData(2);
    data.setUint16(0, value, kNetworkEndian);
    add(data.buffer.asUint8List());
  }
  void addFloat32(double value) {
    final data = ByteData(4);
    data.setFloat32(0, value, kNetworkEndian);
    add(data.buffer.asUint8List());
  }
}

extension ToFlutterImage on img.Image {
  /// Converts an [ui.Image] to an [img.Image].
  Future<ui.Image> toFlutterImage() async {
    img.Image image = this;
    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      final cmd = img.Command()
        ..image(image)
        ..convert(format: img.Format.uint8, numChannels: 4);
      final rgba8 = await cmd.getImageThread();
      if (rgba8 != null) {
        image = rgba8;
      }
    }

    ui.ImmutableBuffer buffer = await
    ui.ImmutableBuffer.fromUint8List(image.toUint8List());

    ui.ImageDescriptor id = ui.ImageDescriptor.raw(
        buffer,
        height: image.height,
        width: image.width,
        pixelFormat: ui.PixelFormat.rgba8888);

    ui.Codec codec = await id.instantiateCodec(
        targetHeight: image.height,
        targetWidth: image.width);

    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }
}

extension ToImageImage on ui.Image {
  /// Converts an [img.Image] to an [ui.Image].
  Future<img.Image> toImageImage() async {
    final uiBytes = await toByteData();

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: uiBytes!.buffer,
      numChannels: 4
    );

    return image;
  }
}
