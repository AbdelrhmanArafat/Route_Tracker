import 'lat_lng_info.dart';

class LocationInfo {
  LatLngInfo? latLng;

  LocationInfo({this.latLng});

  factory LocationInfo.fromJson(Map<String, dynamic> json) => LocationInfo(
    latLng:
        json['latLng'] == null
            ? null
            : LatLngInfo.fromJson(json['latLng'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'latLng': latLng?.toJson()};
}
