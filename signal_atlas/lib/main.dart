import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signal_atlas/providers/coverage_requests_provider.dart';

import 'services/device_service.dart';
import 'services/dashboard_service.dart';
import 'services/location_tracking_service.dart';
import 'services/platform_channel_service.dart';
import 'services/sessions_service.dart';
import 'services/permission_service.dart';
import 'providers/network_reading_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/server_health_provider.dart';
import 'providers/logging_provider.dart';
import 'providers/sessions_provider.dart';
import 'providers/auth_provider.dart';
import 'services/network_readings_service.dart';
import 'utilities/constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

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

  final loggingProvider = LoggingProvider(
    readingsService,
    sessionProvider,
    serverHealthProvider,
    locationService,
    notificationsPlugin,
  );

  platformService.batterySetupComplete.listen((_) {
    loggingProvider.toggleLogging();
  });

  platformService.init();
  await platformService.startSetupFlow();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => sessionProvider),
        ChangeNotifierProvider(create: (_) => serverHealthProvider),
        ChangeNotifierProvider.value(value: loggingProvider),
        ChangeNotifierProvider(create: (_) => CurrentNetworkReadingProvider(readingsService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(service: dashboardService)),
        ChangeNotifierProvider(create: (_) => CoverageRequestsProvider()..loadRequests()),
        Provider<NetworkReadingsService>.value(value: readingsService),
      ],
      child: const App(),
    ),
  );
}
