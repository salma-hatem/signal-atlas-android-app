// This class is responsible for holding the device ID so other services can easily access
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'network_readings_service.dart';

class DeviceService {
  static final ValueNotifier<String?> deviceId =
  ValueNotifier<String?>(null);

  static void init(NetworkReadingsService service) {
    final existing = service.latestReading?.deviceId;
    if (existing != null) {
      deviceId.value = existing;
    }

    service.readingStream.listen((reading) {
      final id = reading.deviceId;

      if (id != null && deviceId.value != id) {
        deviceId.value = id;
      }
    });
  }
}