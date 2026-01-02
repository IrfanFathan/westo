import 'dart:async';
import 'package:flutter/material.dart';

import '../device/device_connect_screen.dart';

/// SplashScreen
/// -------------
/// Entry screen of the app.
/// Shows logo for 2 seconds and navigates to DeviceConnectScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay navigation for splash effect
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return; // ✅ prevents async context error

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DeviceConnectScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 80),
            SizedBox(height: 16),
            Text(
              'WESTO',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
