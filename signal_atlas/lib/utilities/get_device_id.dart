import 'dart:async';
import 'package:flutter/material.dart';
import '../services/device_service.dart';

Future<String> waitForDeviceId() async {
  if (DeviceService.deviceId.value != null) {
    return DeviceService.deviceId.value!;
  }

  final completer = Completer<String>();

  late VoidCallback listener;
  listener = () {
    final id = DeviceService.deviceId.value;
    if (id != null) {
      DeviceService.deviceId.removeListener(listener);
      completer.complete(id);
    }
  };

  DeviceService.deviceId.addListener(listener);

  return completer.future;
}
