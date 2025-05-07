import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/models/place_details_model/place_details_model.dart';
import 'package:route_tracker/models/router_body_model/destination.dart';
import 'package:route_tracker/models/router_body_model/lat_lng_info.dart';
import 'package:route_tracker/models/router_body_model/location_info.dart';
import 'package:route_tracker/models/router_body_model/origin.dart';
import 'package:route_tracker/models/router_body_model/route_modifiers.dart';
import 'package:route_tracker/models/router_body_model/router_body_model.dart';
import 'package:route_tracker/models/routes_model/routes_model.dart';
import 'package:route_tracker/utils/services/location_service.dart';
import 'package:route_tracker/utils/services/places_service.dart';
import 'package:route_tracker/utils/services/routes_service.dart';

class MapsServices {
  LocationService locationService = LocationService();
  PlacesService placesService = PlacesService();
  RoutesService routesService = RoutesService();
  LatLng? currentLocation;

  Future<void> getPredictions({
    required String input,
    required String sessionToken,
    required List<PlaceAutocompleteModel> places,
  }) async {
    if (input.isNotEmpty) {
      var result = await placesService.getPredictions(
        input: input,
        sessionToken: sessionToken,
      );
      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  Future<List<LatLng>> getRouterData({required LatLng destination}) async {
    RouterBodyModel routerBody = RouterBodyModel(
      origin: Origin(
        locationInfo: LocationInfo(
          latLng: LatLngInfo(
            latitude: currentLocation!.latitude,
            longitude: currentLocation!.longitude,
          ),
        ),
      ),
      destination: Destination(
        locationInfo: LocationInfo(
          latLng: LatLngInfo(
            latitude: destination.latitude,
            longitude: destination.longitude,
          ),
        ),
      ),
      travelMode: 'driving',
      routingPreference: "TRAFFIC_AWARE",
      computeAlternativeRoutes: false,
      routeModifiers: RouteModifiers(),
      languageCode: "en-US",
      units: "IMPERIAL",
    );

    RoutesModel routers = await routesService.fetchRoutes(
      routerBody: routerBody,
    );

    PolylinePoints polylinePoints = PolylinePoints();

    List<PointLatLng> result = polylinePoints.decodePolyline(
      routers.routes!.first.polyline!.encodedPolyline!,
    );

    List<LatLng> points =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();

    return points;
  }

  void displayRoute(
    List<LatLng> points, {
    required Set<Polyline> polyline,
    required GoogleMapController mapController,
  }) {
    Polyline route = Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: Colors.blue,
      width: 5,
    );
    polyline.add(route);
    LatLngBounds bounds = getLatLngBounds(points);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    var southWestLatitude = points.first.latitude;
    var southWestLongitude = points.first.longitude;
    var northEastLatitude = points.first.latitude;
    var northEastLongitude = points.first.longitude;

    for (var point in points) {
      southWestLatitude = min(southWestLatitude, point.latitude);
      southWestLongitude = min(southWestLongitude, point.longitude);
      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southWestLatitude, southWestLongitude),
      northeast: LatLng(northEastLatitude, northEastLongitude),
    );
  }

  void updateCurrentLocation({
    required GoogleMapController mapController,
    required Set<Marker> markers,
    required Function onUpdateCurrentLocation,
  }) async {
    locationService.getRealTimeLocation((locationData) {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
        markerId: const MarkerId('my location'),
        position: currentLocation!,
      );
      CameraPosition myCurrentCameraPosition = CameraPosition(
        target: currentLocation!,
        zoom: 16,
      );
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(myCurrentCameraPosition),
      );
      markers.add(currentLocationMarker);
      onUpdateCurrentLocation();
    });
  }

  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    return await placesService.getPlaceDetails(placeId: placeId);
  }
}
