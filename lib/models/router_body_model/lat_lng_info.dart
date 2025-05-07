class LatLngInfo {
  double? latitude;
  double? longitude;

  LatLngInfo({this.latitude, this.longitude});

  factory LatLngInfo.fromJson(Map<String, dynamic> json) => LatLngInfo(
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}
