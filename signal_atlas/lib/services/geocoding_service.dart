import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static const int _precision = 1000;
  static const int _maxCacheSize = 200;

  static final Map<String, CacheEntry> _cache = {};

  static Future<Map<String, String?>> getCityCountry(double lat, double lon) async {
    final key = _cacheKey(lat, lon);

    final cached = _cache[key];
    if (cached != null && !cached.isExpired()) {
      return cached.data;
    }

    final placemarks = await placemarkFromCoordinates(lat, lon);
    Map<String, String?> result;

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      result = {
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
    } else {
      result = {'city': null, 'country': null};
    }

    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache[key] = CacheEntry(result);
    return result;
  }

  static String _cacheKey(double lat, double lon) {
    return "${(lat * _precision).round()},${(lon * _precision).round()}";
  }
}

class CacheEntry {
  final Map<String, String?> data;
  final DateTime timestamp;

  CacheEntry(this.data) : timestamp = DateTime.now();

  bool isExpired() {
    return DateTime.now().difference(timestamp).inHours >= 1;
  }
}
