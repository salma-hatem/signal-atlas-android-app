import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../live_data/live_data_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../data_hub/data_hub_screen.dart';
import '../profile/profile_screen.dart';
import '../coverage_requests/coverage_requests_screen.dart';
import 'package:signal_atlas/widgets/navigation_bar.dart';
import 'package:signal_atlas/providers/navigation_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    LiveDataPage(),
    DashboardPage(),
    DataHubPage(),
    CoverageRequestsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().attachController(_pageController);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Update nav bar when swiping
        onPageChanged: (index) {
          nav.setIndex(index);
        },

        children: _screens,
      ),

      bottomNavigationBar: CustomNavigationBar(
        currentIndex: nav.index,

        onTap: (index) {
          // Update nav bar and animate PageView
          nav.setIndex(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}