// This provider is responsible for updating UI related to network readings
// It is subscribed to the readingStream and updates UI when new data is added to stream

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/network_reading.dart';
import '../services/network_readings_service.dart';

class CurrentNetworkReadingProvider extends ChangeNotifier {
  final NetworkReadingsService _service = NetworkReadingsService();
  late final StreamSubscription _subscription;

  List<NetworkReading> get readings => _service.readings;
  NetworkReading? get latestReading => _service.latestReading;

  CurrentNetworkReadingProvider() {
    _subscription = _service.readingStream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

}
