import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route_tracker/models/router_body_model/router_body_model.dart';
import 'package:route_tracker/models/routes_model/routes_model.dart';
import 'package:route_tracker/utils/constants/constants.dart';

class RoutesService {
  Future<RoutesModel> fetchRoutes({required RouterBodyModel routerBody}) async {
    Uri url = Uri.parse(routersApiBaseUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };

    Map<String, dynamic> body = routerBody.toJson();

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return RoutesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load routes');
    }
  }
}
