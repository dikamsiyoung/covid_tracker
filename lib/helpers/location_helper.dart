import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../lang/en.dart';
import '../models/report.dart';
import '../models/keys.dart';

class LocationHelper {
  static var errors = English.errors['location_helper_errors'];

  static String generateLocationPreviewImageUrl(LatLng locData) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${locData.latitude + 0.00113},+${locData.longitude + 0.0001}&zoom=18&scale=1&size=2560x2000&maptype=roadmap&key=$GOOGLE_API_KEY&format=png&visual_refresh=true&markers=size:lar%7Ccolor:0xff0000%7Clabel:A%7C${locData.latitude},+${locData.longitude}';
  }

  static String generateLocationAddressUrl(double latitude, double longitude) {
    return 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static LatLng convertToLatLng(LocationData locData) {
    return LatLng(locData.latitude, locData.longitude);
  }

  static Future<IncidentLocation> getLocationAddress(
      double latitude, double longitude) async {
    final url = LocationHelper.generateLocationAddressUrl(latitude, longitude);
    IncidentLocation locationData;
    try {
      final getResponse = json.decode((await http.get(url)).body);
      if (getResponse['status'] == 'OK') {
        final formattedAddress = getResponse['results'][0]['formatted_address'];
        List<dynamic> addressComponents =
            getResponse['results'][0]['address_components'];
        final locality = addressComponents.firstWhere(
            (entry) => entry['types'].contains('locality'))['long_name'];
        final state = addressComponents.firstWhere((entry) => entry['types']
            .contains('administrative_area_level_1'))['long_name'];
        final country = addressComponents.firstWhere(
            (entry) => entry['types'].contains('country'))['long_name'];
        locationData = IncidentLocation(
          latitude: latitude,
          longitude: longitude,
          address: formattedAddress,
          locatity: locality,
          state: state,
          country: country,
        );
      } else if (getResponse['status'] == 'REQUEST_DENIED') {
        throw errors['PERMISSION_DENIED'];
      } else {
        throw errors['CONNECTION_FAILED'];
      }
    } catch (error) {
      print(error);
      throw errors['LOCATION_FETCH_ERROR'];
    }
    return locationData;
  }
}
