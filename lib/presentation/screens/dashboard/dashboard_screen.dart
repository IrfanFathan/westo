import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/presentation/viewmodels/waste_viewmodel.dart';
import 'package:westo/presentation/widgets/status_card.dart';
import 'package:westo/presentation/widgets/waste_gauge.dart';
import 'package:westo/presentation/widgets/trigger_card.dart';

/// Dashboard screen for monitoring waste-bin status
///
/// Responsibilities:
/// - Display waste level and compressor status
/// - Show accurate ESP32 connection state (HTTP-based)
/// - Always display trigger button (enable/disable)
/// - Confirmation dialog if waste < 75% before enabling trigger
/// - Success alert after trigger activation
/// - Warn user at 90% and 100% waste level
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _shownWarningDialog = false;
  bool _shownCriticalDialog = false;

  @override
  void initState() {
    super.initState();

    final viewModel =
        Provider.of<WasteViewModel>(context, listen: false);

    // Start polling REST data periodically
    viewModel.startPolling();

    // Add listener for dialog popups side-effects
    viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    final viewModel = Provider.of<WasteViewModel>(context, listen: false);
    viewModel.removeListener(_onViewModelChange);
    viewModel.stopPolling();
    super.dispose();
  }

  void _onViewModelChange() {
    if (!mounted) return;
    final viewModel = Provider.of<WasteViewModel>(context, listen: false);
    final status = viewModel.wasteStatus;

    if (status != null) {
      if (status.wasteLevel >= 90 &&
          status.wasteLevel < 100 &&
          !_shownWarningDialog) {
        _shownWarningDialog = true;
        _showWarningDialog(context, viewModel);
      } else if (status.wasteLevel >= 100 && !_shownCriticalDialog) {
        _shownCriticalDialog = true;
        _showCriticalDialog(context);
      } else if (status.wasteLevel < 90) {
        _shownWarningDialog = false;
        _shownCriticalDialog = false;
      }
    }
  }

  /// Handle trigger button toggle
  ///
  /// - Disable: local-only state change (no HTTP call)
  /// - Enable: sends POST /compress {"trigger": 1}, then starts 30s cooldown
  Future<void> _handleTriggerToggle(WasteViewModel viewModel) async {
    final status = viewModel.wasteStatus;
    final currentlyEnabled = viewModel.isTriggerEnabled;

    // If disabling — local-only, no HTTP call
    if (currentlyEnabled) {
      viewModel.toggleTrigger(false);
      return;
    }

    // If enabling and waste < 75%, show confirmation
    if (status != null && status.wasteLevel < 75) {
      if (!mounted) return;
      final confirmed = await _showConfirmationDialog(context);
      if (confirmed != true) return; // User cancelled
    }

    // Proceed to enable — sends HTTP and starts cooldown
    final success = await viewModel.toggleTrigger(true);
    if (mounted) {
      if (success) {
        _showSuccessDialog(context);
      } else {
        _showErrorDialog(context, viewModel.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WasteViewModel>(
      builder: (context, viewModel, _) {
        // Loading state (first load)
        if (viewModel.isLoading && viewModel.wasteStatus == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ESP32 unreachable (HTTP failed)
        if (!viewModel.isEsp32Connected && viewModel.wasteStatus == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ESP32 Disconnected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure your phone is connected\nto the WESTO ESP32 Wi-Fi hotspot.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.loadInitialStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Connection'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final status = viewModel.wasteStatus!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Waste Gauge (with gradient header)
              WasteGauge(
                wasteLevel: status.wasteLevel,
              ),

              const SizedBox(height: 20),

              /// Trigger Card (always visible)
              TriggerCard(
                isEnabled: viewModel.isTriggerEnabled,
                isLoading: viewModel.isTriggerLoading,
                isConnected: viewModel.isEsp32Connected,
                isInCooldown: viewModel.isInCooldown,
                cooldownRemaining: viewModel.cooldownRemaining,
                onToggle: () => _handleTriggerToggle(viewModel),
              ),

              const SizedBox(height: 16),

              /// Status Card
              StatusCard(
                wasteLevel: status.wasteLevel,
                isConnected: viewModel.isEsp32Connected,
                isCompressorActive: status.isCompressorActive,
                isTriggerEnabled: viewModel.isTriggerEnabled,
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------------------------
  // Dialogs
  // -----------------------------------------------

  /// Confirmation dialog when waste < 75%
  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 32,
          ),
        ),
        title: const Text('Low Waste Level'),
        content: const Text(
          'Waste level is below 75%. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Success alert after trigger activation
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 32,
          ),
        ),
        title: const Text('Trigger Activated'),
        content: const Text(
          'The trigger system has been activated successfully. '
          'The system has started the operation.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Error dialog when ESP32 doesn't respond
  void _showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32,
          ),
        ),
        title: const Text('Operation Failed'),
        content: Text(
          message ?? 'ESP32 did not respond. Please check the connection and try again.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 90% Warning Dialog
  void _showWarningDialog(
    BuildContext context,
    WasteViewModel viewModel,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 32,
          ),
        ),
        title: const Text('Waste Almost Full'),
        content: const Text(
          'Waste level has reached 90%.\n'
          'Would you like to activate the trigger?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Use the unified trigger toggle (sends HTTP + starts cooldown)
              _handleTriggerToggle(viewModel);
            },
            child: const Text('Trigger'),
          ),
        ],
      ),
    );
  }

  /// 100% Critical Dialog
  void _showCriticalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.dangerous_outlined,
            color: AppColors.error,
            size: 32,
          ),
        ),
        title: const Text('⚠ Bin Fully Loaded'),
        content: const Text(
          'Waste bin is 100% full.\n'
          'Immediate action is required.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
