// reverse geocoding for latitude and longitude values to get country and city names

import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static Future<Map<String, String?>> getCityCountry(double lat, double lon) async {
    final placemarks = await placemarkFromCoordinates(lat, lon);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return {
        'city': (place.locality != null && place.locality!.isNotEmpty)
                ? place.locality
                : (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty)
                ? place.subAdministrativeArea
                : (place.name != null && place.name!.isNotEmpty)
                ? place.name
                : "Unknown",
        'country': (place.country != null && place.country!.isNotEmpty)
                    ? place.country
                    : "Unknown",
      };
    }

    return {'city': null, 'country': null};
  }
}