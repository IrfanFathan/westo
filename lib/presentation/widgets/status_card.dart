import 'package:flutter/material.dart';

import 'package:westo/core/constants/app_colors.dart';

/// A reusable card widget to display device and waste status
///
/// This widget:
/// - Displays waste level
/// - Displays ESP32 connection status
/// - Displays compressor state
/// - Contains NO business logic or API calls
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              'Bin Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            /// Waste level
            _StatusRow(
              label: 'Waste Level',
              value: '$wasteLevel%',
            ),

            const SizedBox(height: 12),

            /// ESP32 connection status (IMPORTANT)
            _StatusRow(
              label: 'Connection',
              value: isConnected ? 'ESP32 Connected' : 'ESP32 Disconnected',
              valueColor:
              isConnected ? AppColors.success : AppColors.error,
              showIndicator: true,
              indicatorColor:
              isConnected ? AppColors.success : AppColors.error,
            ),

            const SizedBox(height: 12),

            /// Compressor status
            _StatusRow(
              label: 'Compressor',
              value: isCompressorActive ? 'Running' : 'Idle',
              valueColor: isCompressorActive
                  ? AppColors.warning
                  : AppColors.textSecondary,
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

  /// Optional status indicator (used for connection)
  final bool showIndicator;
  final Color? indicatorColor;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showIndicator = false,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Left label
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        /// Right value + optional indicator
        Row(
          children: [
            if (showIndicator)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: valueColor),
            ),
          ],
        ),
      ],
    );
  }
}
