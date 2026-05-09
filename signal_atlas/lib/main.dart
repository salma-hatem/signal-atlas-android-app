import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:provider/provider.dart';
import 'package:signal_atlas/services/device_service.dart';
import 'package:signal_atlas/services/dashboard_service.dart';
import 'package:signal_atlas/services/location_tracking_service.dart';
import 'package:signal_atlas/services/platform_channel_service.dart';
import 'package:signal_atlas/services/sessions_service.dart';
import 'package:signal_atlas/services/permission_service.dart';
import 'providers/network_reading_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/server_health_provider.dart';
import 'providers/logging_provider.dart';
import 'providers/sessions_provider.dart';
import 'services/network_readings_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final readingsService = NetworkReadingsService();
  final dashboardService = DashboardService();
  final sessionsService = SessionsService();

  DeviceService.init(readingsService);

  final sessionProvider = SessionProvider(sessionsService);
  final serverHealthProvider = ServerHealthProvider();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  await notificationsPlugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  final permissionService = PermissionService(notificationsPlugin);
  final platformService = PlatformChannelService(
    readingsService: readingsService,
    permissionService: permissionService,
  );
  final locationService = LocationTrackingService();
  await locationService.start();

  platformService.init();
  await platformService.startSetupFlow();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sessionProvider),
        ChangeNotifierProvider(create: (_) => serverHealthProvider),
        ChangeNotifierProvider(create: (_) => LoggingProvider(
          readingsService,
          sessionProvider,
          serverHealthProvider,
          locationService,
          notificationsPlugin,
        )),
        ChangeNotifierProvider(create: (_) => CurrentNetworkReadingProvider(readingsService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(service: dashboardService)),
      ],
      child: const App(),
    ),
  );
}
