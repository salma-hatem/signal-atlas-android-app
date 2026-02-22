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

    // Create model
    final reading = NetworkReading(
      deviceId: rawData["ID"],
      latitude: rawData["Latitude"],
      longitude: rawData["Longitude"],
      altitude: rawData["Altitude"],
      city: locationData['city'],
      country: locationData['country'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(rawData["Timestamp"]),
      level: rawData["Level"],
      rsrp: rawData["RSRP"],
      asu: rawData["ASU Level"],
      rssi: rawData["RSSI"],
      rsrq: rawData["RSRQ"],
      networkType: rawData["NetworkType"],
      operatorName: rawData["Operator"],
      physicalCellId: rawData["PCI"],
      trackingAreaCode: rawData["TAC"],
    );

    // Store it
    _readings.add(reading);
    // Add to stream
    _readingController.add(reading);
  }

}
