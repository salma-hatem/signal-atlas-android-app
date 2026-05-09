import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../models/network_reading.dart';
import '../services/geocoding_service.dart';
import 'package:signal_atlas/utilities/constants.dart';

class NetworkReadingsService {
  final List<NetworkReading> _readings = [];
  static const int _maxReadings = 500;
  List<NetworkReading> get readings => List.unmodifiable(_readings);
  NetworkReading? get latestReading => _readings.isNotEmpty ? _readings.last : null;

  final _readingController = StreamController<NetworkReading>.broadcast();
  Stream<NetworkReading> get readingStream => _readingController.stream;

  int _samplesSentCount = 0;
  int get samplesSentCount => _samplesSentCount;
  final _samplesCountController = StreamController<int>.broadcast();
  Stream<int> get samplesCountStream => _samplesCountController.stream;

  Future<void> startBackgroundService() async {
    try {
      await AndroidChannel.channel.invokeMethod("startService");
    } catch (e) {
      debugPrint("Failed to start service: $e");
    }
  }

  Future<void> stopBackgroundService() async {
    try {
      await AndroidChannel.channel.invokeMethod('stopService');
    } catch (e) {
      debugPrint("Failed to stop service: $e");
    }
  }

  Future<void> startBatching() async {
    try {
      await AndroidChannel.channel.invokeMethod("startBatching", {
        "baseUrl": ApiConfig.baseUrl,
        "apiKey": ApiConfig.apiKey,
      });
    } catch (e) {
      debugPrint("Failed to start batching: $e");
    }
  }

  Future<int> stopBatching() async {
    try {
      final count = await AndroidChannel.channel.invokeMethod<int>("stopBatching");
      _samplesSentCount = count ?? _samplesSentCount;
      _samplesCountController.add(_samplesSentCount);
      return _samplesSentCount;
    } catch (e) {
      debugPrint("Failed to stop batching: $e");
      return _samplesSentCount;
    }
  }

  Future<void> requestBatteryOptimization() async {
    await AndroidChannel.channel.invokeMethod("requestBatteryOptimization");
  }

  void updateSamplesCount(int count) {
    _samplesSentCount = count;
    _samplesCountController.add(count);
  }

  void addReading(NetworkReading reading) {
    _readings.add(reading);
    if (_readings.length > _maxReadings) {
      _readings.removeRange(0, _readings.length - _maxReadings);
    }
  }

  Future<void> addReadingFromRawData(Map<String, dynamic> rawData) async {
    final locationData = await GeocodingService.getCityCountry(
        rawData["Latitude"], rawData["Longitude"]);

    final completeRawData = {
      ...rawData,
      'city': locationData['city'],
      'country': locationData['country'],
    };

    try {
      final reading = NetworkReading.fromRaw(completeRawData);
      _readings.add(reading);
      if (_readings.length > _maxReadings) {
        _readings.removeRange(0, _readings.length - _maxReadings);
      }
      _readingController.add(reading);
    } catch (e) {
      debugPrint("MODEL CRASH: $e");
    }
  }
}
