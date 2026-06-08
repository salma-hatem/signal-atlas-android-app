import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  StreamSubscription<Position>? _positionSub;

  final ValueNotifier<double> speedMps = ValueNotifier(0);
  final List<int> speedHistory = [];

  double? lastLat;
  double? lastLon;
  double? lastAlt;

  Future<void> start() async {
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((position) {
      speedMps.value = position.speed;

      speedHistory.add(position.speed.toInt());

      lastLat = position.latitude;
      lastLon = position.longitude;
      lastAlt = position.altitude;
    });
  }

  Future<void> dispose() async {
    await _positionSub?.cancel();
  }
}
