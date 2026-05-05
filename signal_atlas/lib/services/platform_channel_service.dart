import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:signal_atlas/services/permission_service.dart';

import '../utilities/constants.dart';
import 'network_readings_service.dart';

class PlatformChannelService {
  final NetworkReadingsService readingsService;
  final PermissionService permissionService;

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
          await permissionService.requestAll();
          await AndroidChannel.channel.invokeMethod("startService");
          break;

        case "newNetworkReading":
          final rawData = Map<String, dynamic>.from(call.arguments ?? {});
          await readingsService.addReadingFromRawData(rawData);
          break;
      }
    } catch (e) {
      debugPrint("METHOD CHANNEL ERROR: $e");
    }
  }

  Future<void> startSetupFlow() async {
    await readingsService.requestBatteryOptimization();
  }
}
