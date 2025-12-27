import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const WestoApp());
}
class WestoApp extends StatelessWidget {
  const WestoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Westo',

      // Removes the debug banner from top-right corner
      debugShowCheckedModeBanner: false,

      // Apply the global light theme created
      theme: AppTheme.lightTheme,

      // Temporary home screen (replace later with Login/Dashboard)
      home: const HomePlaceholder(),
    );
  }
}

// Temporary screen to verify theme is working
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Westo Dashboard'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Theme Applied Successfully',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Test Button'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
