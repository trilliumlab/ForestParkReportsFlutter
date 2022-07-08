import 'package:latlong2/latlong.dart';

class Hazard extends NewHazardRequest {
  String uuid;
  DateTime time;

  Hazard(this.uuid, this.time, super.hazard, super.location);

  Hazard.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        time = DateTime.parse(json['time']),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'time': time.toIso8601String(),
      ...super.toJson()
    };
  }
}

class NewHazardRequest {
  HazardType hazard;
  SnappedLatLng location;

  NewHazardRequest(this.hazard, this.location);

  NewHazardRequest.fromJson(Map<String, dynamic> json)
      : hazard = HazardType.values.byName(json['hazard']),
        location = SnappedLatLng.fromJson(json['location']);

  Map<String, dynamic> toJson() {
    return {
      'hazard': hazard.name,
      'location': location.toJson(),
    };
  }
}

// A way of representing a LatLng pair that exists on a path. Stores
// the path uuid, along with the index of the point, and a LatLng pair
class SnappedLatLng extends LatLng {
  String trail;
  int index;

  SnappedLatLng(this.trail, this.index, LatLng loc) : super(loc.latitude, loc.longitude);

  SnappedLatLng.fromJson(Map<String, dynamic> json)
      : trail = json['trail'],
        index = json['index'],
        super(json['lat'], json['long']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'trail': trail,
      'index': index,
      'lat': latitude,
      'long': longitude,
    };
  }
  @override
  String toString() {
    return "${super.toString()} trailUuid:$trail, index:$index";
  }
}

enum HazardType {
  tree,
  flood,
  other
}
