import 'location_info.dart';

class Origin {
  LocationInfo? locationInfo;

  Origin({this.locationInfo});

  factory Origin.fromJson(Map<String, dynamic> json) => Origin(
    locationInfo:
        json['location'] == null
            ? null
            : LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'location': locationInfo?.toJson()};
}
