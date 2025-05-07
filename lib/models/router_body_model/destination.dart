import 'location_info.dart';

class Destination {
  LocationInfo? locationInfo;

  Destination({this.locationInfo});

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    locationInfo:
        json['location'] == null
            ? null
            : LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'location': locationInfo?.toJson()};
}
