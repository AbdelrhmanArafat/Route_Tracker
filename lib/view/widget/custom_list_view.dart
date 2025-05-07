import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/models/place_details_model/place_details_model.dart';
import 'package:route_tracker/utils/services/maps_services.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.mapsServices,
    required this.onPlaceSelected,
  });

  final List<PlaceAutocompleteModel> places;
  final MapsServices mapsServices;
  final void Function(PlaceDetailsModel) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(FontAwesomeIcons.mapPin),
            title: Text(places[index].description!),
            trailing: IconButton(
              onPressed: () async {
                var placeDetails = await mapsServices.getPlaceDetails(
                  placeId: places[index].placeId.toString(),
                );
                onPlaceSelected(placeDetails);
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 0);
        },
        itemCount: places.length,
      ),
    );
  }
}
