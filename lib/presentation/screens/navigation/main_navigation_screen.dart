import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../device/device_screen.dart';
import '../profile/profile_screen.dart';

/// MainNavigationScreen
/// --------------------
/// Holds bottom navigation bar and switches
/// between Dashboard, Device, and Profile screens.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = const [
    DashboardScreen(),
    DeviceScreen(),
    ProfileScreen(),
  ];

  /// Get title for current tab
  String get _currentTitle {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Device Information';
      case 2:
        return 'Profile';
      default:
        return 'Westo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Future: show notifications
            },
          ),
          if (_currentIndex == 2) // Show settings gear on profile tab
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory),
            label: 'Device',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
