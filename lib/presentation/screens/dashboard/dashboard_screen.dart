import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/presentation/viewmodels/waste_viewmodel.dart';
import 'package:westo/presentation/widgets/status_card.dart';
import 'package:westo/presentation/widgets/waste_gauge.dart';

/// Dashboard screen for monitoring waste-bin status
///
/// This screen:
/// - Observes WasteViewModel
/// - Displays waste status and gauge
/// - Triggers compressor action
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Load initial data & start real-time updates
    final viewModel =
    Provider.of<WasteViewModel>(context, listen: false);

    viewModel.loadInitialStatus();
    viewModel.startRealtimeUpdates();
  }

  @override
  void dispose() {
    // Stop MQTT updates when leaving screen
    Provider.of<WasteViewModel>(context, listen: false)
        .disposeRealtimeUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<WasteViewModel>(
        builder: (context, viewModel, _) {
          // Loading state
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final status = viewModel.wasteStatus;

          if (status == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Waste gauge
                WasteGauge(
                  wasteLevel: status.wasteLevel,
                ),

                const SizedBox(height: 24),

                // Status information card
                StatusCard(
                  wasteLevel: status.wasteLevel,
                  isConnected: status.isConnected,
                  isCompressorActive: status.isCompressorActive,
                ),

                const SizedBox(height: 24),

                // Trigger compressor button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: status.isCompressorActive
                        ? null
                        : () async {
                      await viewModel.compressWaste();
                    },
                    child: const Text('Trigger Compressor'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
