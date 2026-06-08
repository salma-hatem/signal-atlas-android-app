// This class handles business logic related to network readings
// It holds a list of NetworkReading and uses a Stream to notify provider(s) when new data is available

import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../models/network_reading.dart';
import '../services/geocoding_service.dart';
import 'package:signal_atlas/utilities/constants.dart';

class NetworkReadingsService {
  final List<NetworkReading> _readings = [];  // private list
  List<NetworkReading> get readings => List.unmodifiable(_readings); // public getter
  NetworkReading? get latestReading => _readings.isNotEmpty ? _readings.last : null;

  // A stream is used to notify subscribers when new data is available
  final _readingController = StreamController<NetworkReading>.broadcast();
  Stream<NetworkReading> get readingStream => _readingController.stream;


  // Set up background service to collect data in the background
  Future<void> startBackgroundService() async {
    try {
      await AndroidChannel.channel.invokeMethod("startService");
    } catch (e) {
      debugPrint("Failed to start service: $e");
    }
  }

  // Stop data collection in the background
  Future<void> stopBackgroundService() async {
    try {
      await AndroidChannel.channel.invokeMethod('stopService');
    } catch (e) {
      debugPrint("Failed to stop service: $e");
    }
  }

  // Request battery optimization
  Future<void> requestBatteryOptimization() async {
    await AndroidChannel.channel.invokeMethod("requestBatteryOptimization");
  }


  // Append list
  void addReading(NetworkReading reading) {
    _readings.add(reading);
  }

  // Add reading from Raw Data
  Future<void> addReadingFromRawData(Map<String, dynamic> rawData) async {

    // Skip geocoding if coordinates are missing
    if (rawData["Latitude"] == null || rawData["Longitude"] == null) {
      final reading = NetworkReading.fromRaw(rawData);
      _readings.add(reading);
      _readingController.add(reading);
      return;
    }

    // Reverse geocode
    final locationData = await GeocodingService.getCityCountry(rawData["Latitude"], rawData["Longitude"]);

    // Merge location info into rawData
    final completeRawData = {
      ...rawData, // existing raw fields
      'city': locationData['city'],   // add city
      'country': locationData['country'], // add country
    };

    // Create model
    try {
      final reading = NetworkReading.fromRaw(completeRawData);

      // Store it
      _readings.add(reading);
      // Add to stream
      _readingController.add(reading);

    } catch (e) {
      debugPrint("MODEL CRASH: $e");
    }
  }
}
