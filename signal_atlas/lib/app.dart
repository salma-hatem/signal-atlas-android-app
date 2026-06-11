import 'package:flutter/material.dart';
import 'utilities/theme/app_theme.dart';
import 'screens/main/main_screen.dart';
import 'services/platform_channel_service.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.platformService,
  });

  final PlatformChannelService platformService;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.platformService.startSetupFlow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}