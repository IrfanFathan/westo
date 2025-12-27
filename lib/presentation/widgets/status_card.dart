import 'package:flutter/material.dart';

import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/core/theme/app_theme.dart';

/// A reusable card widget to display device and waste status
///
/// This widget:
/// - Displays waste level
/// - Displays connection status
/// - Displays compressor state
/// - Contains NO logic or API calls
class StatusCard extends StatelessWidget {
  final int wasteLevel;
  final bool isConnected;
  final bool isCompressorActive;

  const StatusCard({
    super.key,
    required this.wasteLevel,
    required this.isConnected,
    required this.isCompressorActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Bin Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            // Waste level
            _StatusRow(
              label: 'Waste Level',
              value: '$wasteLevel%',
            ),

            const SizedBox(height: 8),

            // Connection status
            _StatusRow(
              label: 'Connection',
              value: isConnected ? 'Connected' : 'Disconnected',
              valueColor:
              isConnected ? AppColors.success : AppColors.error,
            ),

            const SizedBox(height: 8),

            // Compressor status
            _StatusRow(
              label: 'Compressor',
              value: isCompressorActive ? 'Running' : 'Idle',
              valueColor:
              isCompressorActive ? AppColors.warning : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Private helper widget to display a single status row
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
