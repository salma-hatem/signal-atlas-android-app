// This class handles business logic related to network readings
// It holds a list of NetworkReading and uses a Stream to notify provider(s) when new data is available

import 'dart:async';
import '../models/network_reading.dart';
import '../services/geocoding_service.dart';

class NetworkReadingsService {
  final List<NetworkReading> _readings = [];  // private list
  List<NetworkReading> get readings => List.unmodifiable(_readings); // public getter
  NetworkReading? get latestReading => _readings.isNotEmpty ? _readings.last : null;

  // A stream is used to notify subscribers when new data is available
  final _readingController = StreamController<NetworkReading>.broadcast();
  Stream<NetworkReading> get readingStream => _readingController.stream;

  // Append list
  void addReading(NetworkReading reading) {
    _readings.add(reading);
  }

  // Add reading from Raw Data
  Future<void> addReadingFromRawData({
    required String deviceId,
    required double latitude,
    required double longitude,
    required double altitude,
    required DateTime timestamp,
    required int level,
    required int rsrp,
    required int asu,
    required int rssi,
    required int rsrq,
    required String networkType,
    required String operatorName,
    required int physicalCellId,
    required int trackingAreaCode,
  }) async {

    // Reverse geocode
    final locationData = await GeocodingService.getCityCountry(latitude, longitude);

    // Create model
    final reading = NetworkReading(
      deviceId: deviceId,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      city: locationData['city'],
      country: locationData['country'],
      timestamp: timestamp,
      level: level,
      rsrp: rsrp,
      asu: asu,
      rssi: rssi,
      rsrq: rsrq,
      networkType: networkType,
      operatorName: operatorName,
      physicalCellId: physicalCellId,
      trackingAreaCode: trackingAreaCode,
    );

    // Store it
    _readings.add(reading);
    // Add to stream
    _readingController.add(reading);
  }

  // for testing
  NetworkReadingsService() {
    addReadingFromRawData(
      deviceId: "123456",
      latitude: 10.5,
      longitude: 30.5,
      altitude: 100,
      timestamp: DateTime.now(),
      level: 2,
      rsrp: -90,
      asu: 20,
      rssi: -70,
      rsrq: -15,
      networkType: "LTE",
      operatorName: "Operator Name",
      physicalCellId: 10,
      trackingAreaCode: 12,
    );
  }

}
