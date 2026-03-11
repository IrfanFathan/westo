import 'package:flutter/material.dart';

import 'package:westo/core/constants/app_colors.dart';

/// A reusable card widget to display device and waste status
///
/// Features:
/// - Icon-based status rows
/// - Animated connection indicator (pulsing dot)
/// - Subtle dividers between rows
/// - Contains NO business logic or API calls
class StatusCard extends StatelessWidget {
  final int wasteLevel;
  final bool isConnected;
  final bool isCompressorActive;
  final bool isTriggerEnabled;

  const StatusCard({
    super.key,
    required this.wasteLevel,
    required this.isConnected,
    required this.isCompressorActive,
    this.isTriggerEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Waste level row
            _StatusRow(
              icon: Icons.delete_outline,
              iconColor: _getWasteLevelColor(wasteLevel),
              label: 'Waste Level',
              value: '$wasteLevel%',
              valueColor: _getWasteLevelColor(wasteLevel),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),

            /// Connection row
            _StatusRow(
              icon: isConnected ? Icons.wifi : Icons.wifi_off,
              iconColor: isConnected ? AppColors.connected : AppColors.disconnected,
              label: 'ESP32 Device',
              value: isConnected ? 'Connected' : 'Disconnected',
              valueColor: isConnected ? AppColors.connected : AppColors.disconnected,
              showPulse: isConnected,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),

            /// Compressor row
            _StatusRow(
              icon: isCompressorActive
                  ? Icons.engineering
                  : Icons.engineering_outlined,
              iconColor: isCompressorActive
                  ? AppColors.warning
                  : AppColors.textDisabled,
              label: 'Compressor',
              value: isCompressorActive ? 'Running' : 'Idle',
              valueColor: isCompressorActive
                  ? AppColors.warning
                  : AppColors.textDisabled,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),

            /// Trigger row
            _StatusRow(
              icon: isTriggerEnabled
                  ? Icons.power_settings_new
                  : Icons.power_off_outlined,
              iconColor: isTriggerEnabled
                  ? AppColors.triggerEnabled
                  : AppColors.triggerDisabled,
              label: 'Trigger',
              value: isTriggerEnabled ? 'Enabled' : 'Disabled',
              valueColor: isTriggerEnabled
                  ? AppColors.triggerEnabled
                  : AppColors.triggerDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Color _getWasteLevelColor(int level) {
    if (level >= 90) return AppColors.error;
    if (level >= 60) return AppColors.warning;
    return AppColors.success;
  }
}

/// Private helper widget for individual status rows with icons
class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool showPulse;

  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Icon
        Icon(icon, size: 20, color: iconColor),

        const SizedBox(width: 12),

        /// Label
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
          ),
        ),

        /// Value with optional pulse
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPulse)
              _PulsingDot(color: iconColor),
            if (showPulse) const SizedBox(width: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated pulsing dot indicator for connection status
class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(
              alpha: 0.4 + (_controller.value * 0.6),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
