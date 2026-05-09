import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:signal_atlas/services/permission_service.dart';

import '../utilities/constants.dart';
import 'network_readings_service.dart';

class PlatformChannelService {
  final NetworkReadingsService readingsService;
  final PermissionService permissionService;

  Completer<void>? _batteryOptCompleter;

  PlatformChannelService({
    required this.readingsService,
    required this.permissionService,
  });

  void init() {
    AndroidChannel.channel.setMethodCallHandler(_handleCall);
  }

  Future<void> _handleCall(MethodCall call) async {
    try {
      switch (call.method) {
        case "batterySettingsClosed":
          if (_batteryOptCompleter != null) {
            await AndroidChannel.channel.invokeMethod("startService");
            _batteryOptCompleter?.complete();
            _batteryOptCompleter = null;
          }
          break;

        case "newNetworkReading":
          final rawData = Map<String, dynamic>.from(call.arguments ?? {});
          await readingsService.addReadingFromRawData(rawData);
          break;

        case "samplesCount":
          final count = call.arguments as int;
          readingsService.updateSamplesCount(count);
          break;
      }
    } catch (e) {
      debugPrint("METHOD CHANNEL ERROR: $e");
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await AndroidChannel.channel.invokeMethod<bool>("checkBatteryOptimization");
      return result ?? false;
    } catch (e) {
      debugPrint("Failed to check battery optimization: $e");
      return false;
    }
  }

  Future<void> requestBatteryOptimizationAndWait() async {
    _batteryOptCompleter = Completer<void>();
    try {
      await AndroidChannel.channel.invokeMethod("requestBatteryOptimization");
      await _batteryOptCompleter!.future.timeout(const Duration(minutes: 5));
    } on TimeoutException {
      _batteryOptCompleter = null;
    } catch (e) {
      _batteryOptCompleter = null;
      rethrow;
    }
  }
}
