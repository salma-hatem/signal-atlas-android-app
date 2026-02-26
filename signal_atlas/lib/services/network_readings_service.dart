// This class handles business logic related to network readings
// It holds a list of NetworkReading and uses a Stream to notify provider(s) when new data is available

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/network_reading.dart';
import '../services/geocoding_service.dart';

class NetworkReadingsService {
  final List<NetworkReading> _readings = [];  // private list
  List<NetworkReading> get readings => List.unmodifiable(_readings); // public getter
  NetworkReading? get latestReading => _readings.isNotEmpty ? _readings.last : null;

  // A stream is used to notify subscribers when new data is available
  final _readingController = StreamController<NetworkReading>.broadcast();
  Stream<NetworkReading> get readingStream => _readingController.stream;

  static const _channel = MethodChannel('com.example.signal_atlas');

  NetworkReadingsService() {
    requestPermissions();
    setupChannelListener();
  }

  // Set up channel for communication with Android (for data collecting using APIS)
  void setupChannelListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'newNetworkReading') {
        final rawData = Map<String, dynamic>.from(call.arguments);
        await addReadingFromRawData(rawData);

      }
    });
  }

  // Request permissions required by the data collecting APIs
  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.phone,
    ].request();
  }

  // Append list
  void addReading(NetworkReading reading) {
    _readings.add(reading);
  }

  // Add reading from Raw Data
  Future<void> addReadingFromRawData(Map<String, dynamic> rawData) async {

    // Reverse geocode
    final locationData = await GeocodingService.getCityCountry(rawData["Latitude"], rawData["Longitude"]);

    // Merge location info into rawData
    final completeRawData = {
      ...rawData, // existing raw fields
      'city': locationData['city'],   // add city
      'country': locationData['country'], // add country
    };

    // Create model
    final reading = NetworkReading.fromRaw(completeRawData);

    // Store it
    _readings.add(reading);
    // Add to stream
    _readingController.add(reading);
  }

}
