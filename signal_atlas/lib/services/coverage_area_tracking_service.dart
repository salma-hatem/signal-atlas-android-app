import 'dart:async';
import 'package:geodesy/geodesy.dart';
import '../models/network_reading.dart';

class CoverageAreaTrackingService {
  final Stream<NetworkReading> readingStream;
  final geodesy = Geodesy();

  CoverageAreaTrackingService({
    required this.readingStream,
  });

  StreamSubscription? _subscription;

  List<LatLng>? _polygon;

  bool _isInside = false;
  bool get isInside => _isInside;

  final _insideController = StreamController<bool>.broadcast();
  Stream<bool> get insideStream => _insideController.stream;

  void startTracking(List<LatLng> polygon) {
    _polygon = polygon;

    _subscription?.cancel();

    _subscription = readingStream.listen((reading) {
      final inside = geodesy.isGeoPointInPolygon(
        LatLng(reading.latitude, reading.longitude),
        _polygon!,
      );

      if (inside != _isInside) {
        _isInside = inside;
        _insideController.add(inside);
      }
    });
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    _polygon = null;
  }

  void dispose() {
    _subscription?.cancel();
    _insideController.close();
  }
}
