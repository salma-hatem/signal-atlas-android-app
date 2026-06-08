import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../live_data/live_data_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../data_hub/data_hub_screen.dart';
import '../coverage_requests/coverage_requests_screen.dart';
import '../../pages/login_page.dart';
import '../../providers/auth_provider.dart';
import 'package:signal_atlas/widgets/navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    LiveDataPage(),
    DashboardPage(),
    DataHubPage(),
    CoverageRequestsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isAuthenticated) {
          return const LoginPage();
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: _screens,
          ),
          bottomNavigationBar: CustomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        );
      },
    );
  }
}
