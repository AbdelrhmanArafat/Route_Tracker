import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/utils/services/maps_services.dart';
import 'package:route_tracker/utils/services/location_service.dart';
import 'package:route_tracker/view/widget/custom_list_view.dart';
import 'package:route_tracker/view/widget/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late MapsServices mapsServices;
  late TextEditingController searchController;
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;
  List<PlaceAutocompleteModel> places = [];
  Set<Marker> markers = {};
  Set<Polyline> polyline = {};
  late Uuid uuid;
  String? sessionToken;
  late LatLng destination;
  Timer? debounce;

  @override
  void initState() {
    uuid = const Uuid();
    initialCameraPosition = CameraPosition(target: LatLng(0, 0));
    searchController = TextEditingController();
    mapsServices = MapsServices();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    searchController.addListener(() {
      if (debounce?.isActive ?? false) debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 100), () async {
        sessionToken ??= uuid.v4();
        await mapsServices.getPredictions(
          input: searchController.text,
          sessionToken: sessionToken!,
          places: places,
        );
        setState(() {});
      });
    });
  }

  void updateCurrentLocation() {
    try {
      mapsServices.updateCurrentLocation(
        mapController: mapController,
        markers: markers,
        onUpdateCurrentLocation: () {
          setState(() {});
        },
      );
    } on LocationServiceException catch (_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location Service Disabled'),
            content: const Text(
              'Please enable location Service on settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on LocationPermissionGrantedException catch (_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location Permission Denied'),
            content: const Text(
              'Please enable location permission on settings For App.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on LocationPermissionDeniedForeverException catch (_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location Permission Denied Forever'),
            content: const Text(
              'Please enable location permission on settings For App.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (_) {}
  }

  @override
  dispose() {
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: markers,
              polylines: polyline,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                updateCurrentLocation();
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  CustomTextField(textEditingController: searchController),
                  const SizedBox(height: 16),
                  CustomListView(
                    onPlaceSelected: (placeDetailsModel) async {
                      searchController.clear();
                      places.clear();
                      sessionToken = null;
                      setState(() {});
                      destination = LatLng(
                        placeDetailsModel.geometry!.location!.lat!,
                        placeDetailsModel.geometry!.location!.lng!,
                      );
                      var points = await mapsServices.getRouterData(
                        destination: destination,
                      );
                      mapsServices.displayRoute(
                        points,
                        polyline: polyline,
                        mapController: mapController,
                      );
                      setState(() {});
                    },
                    places: places,
                    mapsServices: mapsServices,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
