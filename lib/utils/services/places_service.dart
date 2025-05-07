import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/models/place_details_model/place_details_model.dart';
import 'package:route_tracker/utils/constants/constants.dart';

class PlacesService {
  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
    required String sessionToken,
  }) async {
    var response = await http.get(
      Uri.parse(
        '$placesApiBaseUrl/autocomplete/json?key=$apiKey&input=$input&sessiontoken=$sessionToken',
      ),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceAutocompleteModel> places = [];
      for (var item in data) {
        places.add(PlaceAutocompleteModel.fromJson(item));
      }
      return places;
    } else {
      throw Exception();
    }
  }

  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    var response = await http.get(
      Uri.parse('$placesApiBaseUrl/details/json?key=$apiKey&place_id=$placeId'),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['result'];
      return PlaceDetailsModel.fromJson(data);
    } else {
      throw Exception();
    }
  }
}
